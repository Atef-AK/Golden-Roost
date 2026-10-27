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

    const ALLOWED_TOPICS = [
      'general_announcements',
      'poultry_tips',
      'disease_alerts',
      'article_alerts',
      'marketing_offers',
    ] as const;

    // Explicit consent booleans (strict default: marketing is opt-in only)
    const marketingOptIn = Boolean(body.marketingOptIn === true);
    const articleAlertsOptIn = body.articleAlertsOptIn !== undefined ? Boolean(body.articleAlertsOptIn) : true;
    const diseaseAlertsOptIn = body.diseaseAlertsOptIn !== undefined ? Boolean(body.diseaseAlertsOptIn) : true;

    // Whitelist and filter user topics based on explicit consent
    let requestedTopics: string[] = Array.isArray(topics) ? topics : ['general_announcements', 'poultry_tips'];
    const sanitizedTopics = requestedTopics.filter((t): t is string =>
      typeof t === 'string' && (ALLOWED_TOPICS as readonly string[]).includes(t)
    );

    // Apply strict consent filters
    const userTopics = sanitizedTopics.filter((t) => {
      if (t === 'marketing_offers' && !marketingOptIn) return false;
      if (t === 'article_alerts' && !articleAlertsOptIn) return false;
      if (t === 'disease_alerts' && !diseaseAlertsOptIn) return false;
      return true;
    });

    if (userTopics.length === 0) {
      userTopics.push('general_announcements');
    }

    const validPlatform = ['android', 'ios', 'web'].includes(platform) ? platform : 'android';
    const validLocale = ['en', 'fr', 'ar'].includes(locale) ? locale : 'en';

    // Upsert into Neon PostgreSQL
    const [device] = await db
      .insert(pushDevices)
      .values({
        fcmToken,
        deviceId: deviceId || null,
        platform: validPlatform,
        locale: validLocale,
        topics: userTopics,
        marketingOptIn,
        articleAlertsOptIn,
        diseaseAlertsOptIn,
        isActive: true,
        lastSeenAt: new Date(),
      })
      .onConflictDoUpdate({
        target: pushDevices.fcmToken,
        set: {
          deviceId: deviceId || null,
          platform: validPlatform,
          locale: validLocale,
          topics: userTopics,
          marketingOptIn,
          articleAlertsOptIn,
          diseaseAlertsOptIn,
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
      consent: {
        marketingOptIn,
        articleAlertsOptIn,
        diseaseAlertsOptIn,
      },
    });
  } catch (err) {
    console.error('Device registration failed:', err);
    return NextResponse.json(
      { error: 'Failed to register push device' },
      { status: 500 }
    );
  }
}
