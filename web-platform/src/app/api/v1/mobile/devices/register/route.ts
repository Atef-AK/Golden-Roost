import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/db';
import { pushDevices } from '@/db/schema';
import { eq } from 'drizzle-orm';
import { firebaseAdmin } from '@/lib/firebase-admin';
import { checkRateLimit } from '@/lib/rate-limit';

export async function POST(request: NextRequest) {
  try {
    const ip = request.headers.get('x-forwarded-for')?.split(',')[0]?.trim() || 'unknown';
    const rateLimit = await checkRateLimit(`device:register:${ip}`, 30, 60);

    if (!rateLimit.success) {
      return NextResponse.json(
        { error: 'Rate limit exceeded. Too many registration requests.' },
        { status: 429 }
      );
    }

    const body = await request.json();
    const { fcmToken, deviceId, platform, locale, topics } = body;

    if (!fcmToken || typeof fcmToken !== 'string') {
      return NextResponse.json({ error: 'Missing fcmToken' }, { status: 400 });
    }

    const userTopics: string[] = Array.isArray(topics) ? topics : ['general_announcements', 'poultry_tips'];

    // Upsert into Neon PostgreSQL
    const [device] = await db
      .insert(pushDevices)
      .values({
        fcmToken,
        deviceId: deviceId || null,
        platform: platform || 'android',
        locale: locale || 'en',
        topics: userTopics,
        isActive: true,
        lastSeenAt: new Date(),
      })
      .onConflictDoUpdate({
        target: pushDevices.fcmToken,
        set: {
          deviceId: deviceId || null,
          platform: platform || 'android',
          locale: locale || 'en',
          topics: userTopics,
          isActive: true,
          lastSeenAt: new Date(),
        },
      })
      .returning();

    // Subscribe to Firebase topics if Firebase Admin messaging is configured
    try {
      for (const topic of userTopics) {
        await firebaseAdmin.messaging().subscribeToTopic([fcmToken], topic);
      }
    } catch (fcmErr) {
      console.warn('FCM topic subscription warning:', fcmErr);
    }

    return NextResponse.json({
      success: true,
      deviceId: device.id,
      topics: userTopics,
    });
  } catch (err) {
    console.error('Device registration failed:', err);
    return NextResponse.json(
      { error: 'Failed to register push device' },
      { status: 500 }
    );
  }
}
