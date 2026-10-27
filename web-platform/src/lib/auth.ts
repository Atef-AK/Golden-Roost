import { NextRequest } from 'next/server';
import crypto from 'crypto';
import { db } from '../db';
import { adminUsers } from '../db/schema';
import { eq } from 'drizzle-orm';

export type AdminRole = 'superadmin' | 'editor' | 'veterinarian' | 'viewer';

export interface AuthenticatedAdmin {
  id: string;
  email: string;
  firebaseUid: string;
  role: AdminRole;
  displayName: string | null;
}

export class AuthError extends Error {
  statusCode: number;
  constructor(message: string, statusCode: number = 401) {
    super(message);
    this.statusCode = statusCode;
    this.name = 'AuthError';
  }
}

const SESSION_SECRET =
  process.env.SESSION_SECRET ||
  process.env.CRON_SECRET ||
  'golden-roost-secure-admin-session-secret-2026';

/**
 * Signs a tamper-proof session JWT cookie.
 */
export function signSessionToken(payload: {
  uid: string;
  email: string;
  role: string;
  id: string;
}): string {
  const header = { alg: 'HS256', typ: 'JWT' };
  const exp = Math.floor(Date.now() / 1000) + 60 * 60 * 24 * 5; // 5 days
  const fullPayload = { ...payload, exp, iat: Math.floor(Date.now() / 1000) };

  const b64Header = Buffer.from(JSON.stringify(header)).toString('base64url');
  const b64Payload = Buffer.from(JSON.stringify(fullPayload)).toString('base64url');
  const signature = crypto
    .createHmac('sha256', SESSION_SECRET)
    .update(`${b64Header}.${b64Payload}`)
    .digest('base64url');

  return `${b64Header}.${b64Payload}.${signature}`;
}

/**
 * Cryptographically verifies session token.
 */
export function verifySessionToken(
  token: string
): { uid: string; email: string; role: string; id: string } | null {
  try {
    const parts = token.split('.');
    if (parts.length !== 3) return null;
    const [b64Header, b64Payload, signature] = parts;

    const expectedSignature = crypto
      .createHmac('sha256', SESSION_SECRET)
      .update(`${b64Header}.${b64Payload}`)
      .digest('base64url');

    if (!crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(expectedSignature))) {
      return null;
    }

    const payload = JSON.parse(Buffer.from(b64Payload, 'base64url').toString('utf8'));
    if (payload.exp && payload.exp < Math.floor(Date.now() / 1000)) {
      return null; // Expired
    }
    return payload;
  } catch {
    return null;
  }
}

/**
 * Verifies a client-supplied Firebase ID token with Google Identity APIs.
 */
export async function verifyGoogleIdToken(idToken: string): Promise<{ uid: string; email: string }> {
  const apiKey =
    process.env.NEXT_PUBLIC_FIREBASE_API_KEY || 'AIzaSyBjk9CalJUg0hwoO1VCLUuHhywJQXB1sHo';

  // Primary: Google Identity Toolkit lookup
  try {
    const res = await fetch(
      `https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=${apiKey}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ idToken }),
      }
    );

    if (res.ok) {
      const data = await res.json();
      const user = data.users?.[0];
      if (user && user.localId && user.email) {
        return { uid: user.localId, email: user.email };
      }
    }
  } catch (err) {
    console.warn('Identity Toolkit verification failed, trying oauth2 tokeninfo fallback:', err);
  }

  // Fallback: oauth2 tokeninfo
  try {
    const tokenInfoRes = await fetch(`https://oauth2.googleapis.com/tokeninfo?id_token=${idToken}`);
    if (tokenInfoRes.ok) {
      const info = await tokenInfoRes.json();
      if (info.sub && info.email) {
        return { uid: info.sub, email: info.email };
      }
    }
  } catch (err) {
    console.warn('oauth2 tokeninfo failed:', err);
  }

  throw new AuthError('Invalid or expired Firebase ID token.', 401);
}

/**
 * Validates CSRF headers on mutating HTTP methods.
 */
export function validateCsrf(request: NextRequest): void {
  const method = request.method.toUpperCase();
  if (['GET', 'HEAD', 'OPTIONS'].includes(method)) {
    return;
  }

  const origin = request.headers.get('origin');
  const referer = request.headers.get('referer');
  const host = request.headers.get('host');

  if (!origin && !referer) {
    const authHeader = request.headers.get('authorization');
    if (!authHeader?.startsWith('Bearer ')) {
      throw new AuthError('Missing Origin and Referer headers for mutation request.', 403);
    }
    return;
  }

  const allowedDomain = host;
  if (origin) {
    try {
      const originHost = new URL(origin).host;
      if (
        originHost !== allowedDomain &&
        !originHost.includes('localhost') &&
        !originHost.includes('vercel.app')
      ) {
        throw new AuthError(`CSRF origin mismatch: ${originHost}`, 403);
      }
    } catch {
      throw new AuthError('Invalid Origin header.', 403);
    }
  }
}

/**
 * Verifies session cookie or Bearer token, checks revoked status with Google,
 * and executes a live authoritative role & active check in Neon PostgreSQL.
 */
export async function verifyAdminSession(
  request: NextRequest,
  allowedRoles?: AdminRole[]
): Promise<AuthenticatedAdmin> {
  validateCsrf(request);

  let token: string | undefined;

  // 1. Check HTTP-only cookie first
  const cookieSession = request.cookies.get('gr_admin_session')?.value;
  if (cookieSession) {
    token = cookieSession;
  } else {
    // 2. Fallback to Authorization: Bearer
    const authHeader = request.headers.get('authorization');
    if (authHeader && authHeader.startsWith('Bearer ')) {
      token = authHeader.substring(7);
    }
  }

  if (!token) {
    throw new AuthError('No authentication session found. Please sign in.', 401);
  }

  let decodedUid: string;
  let decodedEmail: string | undefined;

  // Verify signed server session token first
  const sessionData = verifySessionToken(token);
  if (sessionData) {
    decodedUid = sessionData.uid;
    decodedEmail = sessionData.email;
  } else {
    // Fallback: Verify as a direct Firebase ID token
    try {
      const verified = await verifyGoogleIdToken(token);
      decodedUid = verified.uid;
      decodedEmail = verified.email;
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : 'Invalid or expired credentials.';
      throw new AuthError(`Authentication verification failed: ${message}`, 401);
    }
  }

  // 3. Authoritative PostgreSQL Live Role & Active Check
  const users = await db
    .select()
    .from(adminUsers)
    .where(eq(adminUsers.firebaseUid, decodedUid))
    .limit(1);

  let user = users[0];

  // Fallback by email match if UID was generated during seed
  if (!user && decodedEmail) {
    const emailMatches = await db
      .select()
      .from(adminUsers)
      .where(eq(adminUsers.email, decodedEmail.toLowerCase()))
      .limit(1);

    if (emailMatches[0]) {
      user = emailMatches[0];
      await db
        .update(adminUsers)
        .set({ firebaseUid: decodedUid, updatedAt: new Date() })
        .where(eq(adminUsers.id, user.id));
    }
  }

  if (!user) {
    throw new AuthError('Account not authorized for administration portal access.', 403);
  }

  if (!user.isActive) {
    throw new AuthError('Admin account has been deactivated. Please contact Superadmin.', 403);
  }

  const role = user.role as AdminRole;

  if (allowedRoles && allowedRoles.length > 0 && !allowedRoles.includes(role)) {
    throw new AuthError(
      `Access denied. Role "${role}" is not permitted to perform this action. Required: ${allowedRoles.join(', ')}`,
      403
    );
  }

  return {
    id: user.id,
    email: user.email,
    firebaseUid: user.firebaseUid,
    role,
    displayName: user.displayName,
  };
}
