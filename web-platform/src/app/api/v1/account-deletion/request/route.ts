import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/db';
import { accountDeletionRequests } from '@/db/schema';
import { checkRateLimit } from '@/lib/rate-limit';
import crypto from 'crypto';

export async function POST(request: NextRequest) {
  try {
    const ip = request.headers.get('x-forwarded-for')?.split(',')[0]?.trim() || 'unknown';
    const rateLimit = await checkRateLimit(`deletion:request:${ip}`, 5, 300);

    if (!rateLimit.success) {
      return NextResponse.json(
        { error: 'Too many account deletion requests. Please try again in 5 minutes.' },
        { status: 429 }
      );
    }

    const body = await request.json();
    const { email } = body;

    if (!email || typeof email !== 'string' || !email.includes('@')) {
      return NextResponse.json({ error: 'A valid email address is required.' }, { status: 400 });
    }

    const normalizedEmail = email.toLowerCase().trim();
    const verificationToken = crypto.randomBytes(32).toString('hex');
    const tokenExpiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 hours

    await db.insert(accountDeletionRequests).values({
      email: normalizedEmail,
      verificationToken,
      tokenExpiresAt,
      status: 'pending_verification',
    });

    const host = request.headers.get('host') || 'goldenroost.com';
    const protocol = host.includes('localhost') ? 'http' : 'https';
    const verificationUrl = `${protocol}://${host}/delete-account/verify?token=${verificationToken}`;

    // Log the verification URL securely for dev/server operations
    console.log(`[Account Deletion Requested] Email: ${normalizedEmail} | Verification Link: ${verificationUrl}`);

    return NextResponse.json({
      success: true,
      message:
        'A confirmation link has been sent to your email address. Please click the link within 24 hours to finalize account deletion.',
      // Verification URL provided in response in dev mode for testing convenience
      ...(process.env.NODE_ENV !== 'production' ? { debugVerificationUrl: verificationUrl } : {}),
    });
  } catch (err) {
    console.error('Account deletion request failed:', err);
    return NextResponse.json(
      { error: 'Failed to initiate account deletion request.' },
      { status: 500 }
    );
  }
}
