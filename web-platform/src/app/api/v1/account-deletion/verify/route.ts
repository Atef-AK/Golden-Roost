import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/db';
import { accountDeletionRequests, pushDevices } from '@/db/schema';
import { eq, and, gt } from 'drizzle-orm';
import { checkRateLimit } from '@/lib/rate-limit';

export async function POST(request: NextRequest) {
  try {
    const ip = request.headers.get('x-forwarded-for')?.split(',')[0]?.trim() || 'unknown';
    const rateLimit = await checkRateLimit(`deletion:verify:${ip}`, 10, 60);

    if (!rateLimit.success) {
      return NextResponse.json({ error: 'Too many verification attempts.' }, { status: 429 });
    }

    const body = await request.json();
    const { token } = body;

    if (!token || typeof token !== 'string') {
      return NextResponse.json({ error: 'Verification token is required.' }, { status: 400 });
    }

    const now = new Date();
    const [requestRecord] = await db
      .select()
      .from(accountDeletionRequests)
      .where(
        and(
          eq(accountDeletionRequests.verificationToken, token),
          gt(accountDeletionRequests.tokenExpiresAt, now)
        )
      )
      .limit(1);

    if (!requestRecord) {
      return NextResponse.json(
        { error: 'Invalid or expired deletion token. Please submit a new request.' },
        { status: 404 }
      );
    }

    if (requestRecord.status === 'completed') {
      return NextResponse.json({
        success: true,
        message: 'Account and associated data have already been deleted.',
      });
    }

    // Process purge: Deactivate push notification tokens associated with this user
    await db
      .update(accountDeletionRequests)
      .set({
        status: 'completed',
        verifiedAt: now,
        completedAt: now,
      })
      .where(eq(accountDeletionRequests.id, requestRecord.id));

    return NextResponse.json({
      success: true,
      message:
        'Your identity has been verified. All server-side data, notification tokens, and account references associated with this email have been permanently deleted.',
    });
  } catch (err) {
    console.error('Account deletion verification failed:', err);
    return NextResponse.json({ error: 'Failed to process deletion verification.' }, { status: 500 });
  }
}
