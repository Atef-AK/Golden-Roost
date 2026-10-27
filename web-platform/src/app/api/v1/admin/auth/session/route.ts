import { NextRequest, NextResponse } from 'next/server';
import { verifyGoogleIdToken, signSessionToken } from '@/lib/auth';
import { db } from '@/db';
import { adminUsers } from '@/db/schema';
import { eq } from 'drizzle-orm';
import { checkRateLimit } from '@/lib/rate-limit';
import { logAdminAction } from '@/lib/audit';

export async function POST(request: NextRequest) {
  try {
    const ip = request.headers.get('x-forwarded-for')?.split(',')[0]?.trim() || 'unknown';
    const rateLimit = await checkRateLimit(`auth:login:${ip}`, 10, 60);

    if (!rateLimit.success) {
      return NextResponse.json(
        { error: 'Too many authentication attempts. Please wait 60 seconds.' },
        { status: 429 }
      );
    }

    const body = await request.json();
    const { idToken } = body;

    if (!idToken) {
      return NextResponse.json({ error: 'Missing idToken.' }, { status: 400 });
    }

    // Verify token with Google Identity
    const { uid, email } = await verifyGoogleIdToken(idToken);

    if (!email) {
      return NextResponse.json({ error: 'Authentication token has no email.' }, { status: 400 });
    }

    // Lookup user in Neon PostgreSQL
    let [user] = await db
      .select()
      .from(adminUsers)
      .where(eq(adminUsers.firebaseUid, uid))
      .limit(1);

    if (!user) {
      const [emailMatch] = await db
        .select()
        .from(adminUsers)
        .where(eq(adminUsers.email, email.toLowerCase()))
        .limit(1);

      if (emailMatch) {
        user = emailMatch;
        await db
          .update(adminUsers)
          .set({ firebaseUid: uid, updatedAt: new Date() })
          .where(eq(adminUsers.id, user.id));
      }
    }

    if (!user) {
      return NextResponse.json(
        { error: 'Unauthorized. This account is not provisioned in Golden Roost Admin.' },
        { status: 403 }
      );
    }

    if (!user.isActive) {
      return NextResponse.json(
        { error: 'Admin account has been deactivated.' },
        { status: 403 }
      );
    }

    // Create server-signed session cookie valid for 5 days
    const expiresIn = 60 * 60 * 24 * 5 * 1000;
    const sessionCookie = signSessionToken({
      id: user.id,
      email: user.email,
      role: user.role,
      uid: user.firebaseUid,
    });

    const response = NextResponse.json({
      success: true,
      user: {
        id: user.id,
        email: user.email,
        displayName: user.displayName,
        role: user.role,
      },
    });

    response.cookies.set('gr_admin_session', sessionCookie, {
      maxAge: expiresIn / 1000,
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      path: '/',
    });

    await logAdminAction({
      adminUserId: user.id,
      action: 'ADMIN_SIGN_IN',
      entityType: 'admin_user',
      entityId: user.id,
      ipAddress: ip,
    });

    return response;
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : 'Authentication failed';
    return NextResponse.json({ error: message }, { status: 401 });
  }
}

export async function DELETE(request: NextRequest) {
  const response = NextResponse.json({ success: true, message: 'Logged out successfully.' });
  response.cookies.set('gr_admin_session', '', {
    maxAge: 0,
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'lax',
    path: '/',
  });
  return response;
}
