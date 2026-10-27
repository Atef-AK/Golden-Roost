import { NextRequest, NextResponse } from 'next/server';
import { firebaseAdmin } from './firebase-admin';
import { db } from '../db';
import { adminUsers } from '../db/schema';
import { eq } from 'drizzle-orm';

export interface AuthenticatedAdmin {
  id: string;
  email: string;
  firebaseUid: string;
  role: 'superadmin' | 'editor' | 'viewer';
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
    // If neither header is present, check if an explicit Bearer authorization header is used (e.g. CLI/automation)
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
      if (originHost !== allowedDomain && !originHost.includes('localhost') && !originHost.includes('vercel.app')) {
        throw new AuthError(`CSRF origin mismatch: ${originHost}`, 403);
      }
    } catch {
      throw new AuthError('Invalid Origin header.', 403);
    }
  }
}

/**
 * Verifies session cookie or Bearer token, checks revoked status with Firebase,
 * and executes a live authoritative role & active check in Neon PostgreSQL.
 */
export async function verifyAdminSession(
  request: NextRequest,
  allowedRoles?: ('superadmin' | 'editor' | 'viewer')[]
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

  try {
    // First try session cookie verification (for HTTP-only cookies)
    try {
      const decodedCookie = await firebaseAdmin.auth().verifySessionCookie(token, true);
      decodedUid = decodedCookie.uid;
      decodedEmail = decodedCookie.email;
    } catch {
      // Fallback to ID token verification
      const decodedToken = await firebaseAdmin.auth().verifyIdToken(token, true);
      decodedUid = decodedToken.uid;
      decodedEmail = decodedToken.email;
    }
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : 'Invalid or expired credentials.';
    throw new AuthError(`Authentication verification failed: ${message}`, 401);
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
      // Link the real Firebase UID
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

  const role = user.role as 'superadmin' | 'editor' | 'viewer';

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
