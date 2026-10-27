import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/db';
import { notificationCampaigns, pushDevices, notificationDeliveries } from '@/db/schema';
import { eq, desc, and } from 'drizzle-orm';
import { verifyAdminSession, AuthError } from '@/lib/auth';
import { firebaseAdmin } from '@/lib/firebase-admin';
import { logAdminAction } from '@/lib/audit';

export async function GET(request: NextRequest) {
  try {
    await verifyAdminSession(request, ['superadmin', 'editor', 'viewer']);

    const campaigns = await db
      .select()
      .from(notificationCampaigns)
      .orderBy(desc(notificationCampaigns.createdAt))
      .limit(50);

    const activeDevices = await db
      .select({ count: pushDevices.id })
      .from(pushDevices)
      .where(eq(pushDevices.isActive, true));

    return NextResponse.json({
      success: true,
      totalActiveDevices: activeDevices.length,
      data: campaigns,
    });
  } catch (err: unknown) {
    if (err instanceof AuthError) {
      return NextResponse.json({ error: err.message }, { status: err.statusCode });
    }
    return NextResponse.json({ error: 'Failed to fetch campaigns' }, { status: 500 });
  }
}

export async function POST(request: NextRequest) {
  try {
    const admin = await verifyAdminSession(request, ['superadmin', 'editor']);
    const body = await request.json();
    const { title, body: msgBody, targetTopic, dataPayload, scheduledAt, sendImmediately } = body;

    if (!title || !msgBody) {
      return NextResponse.json(
        { error: 'Campaign title and message body are required.' },
        { status: 400 }
      );
    }

    const scheduledDate = scheduledAt ? new Date(scheduledAt) : null;
    const initialStatus = sendImmediately ? 'processing' : scheduledDate ? 'scheduled' : 'draft';

    const [campaign] = await db
      .insert(notificationCampaigns)
      .values({
        title,
        body: msgBody,
        targetTopic: targetTopic || 'general_announcements',
        dataPayload: dataPayload || {},
        status: initialStatus,
        scheduledAt: scheduledDate,
        createdBy: admin.id,
      })
      .returning();

    await logAdminAction({
      adminUserId: admin.id,
      action: 'CAMPAIGN_CREATE',
      entityType: 'notification_campaign',
      entityId: campaign.id,
      metadata: { title, targetTopic, sendImmediately },
    });

    // If sendImmediately, trigger immediate dispatch
    if (sendImmediately) {
      // Background dispatch in serverless handler
      (async () => {
        try {
          // If sending to topic
          if (targetTopic) {
            const fcmResponse = await firebaseAdmin.messaging().send({
              topic: targetTopic,
              notification: {
                title,
                body: msgBody,
              },
              data: {
                campaignId: campaign.id,
                clickAction: 'FLUTTER_NOTIFICATION_CLICK',
                ...Object.fromEntries(
                  Object.entries(dataPayload || {}).map(([k, v]) => [k, String(v)])
                ),
              },
            });

            await db
              .update(notificationCampaigns)
              .set({
                status: 'completed',
                sentCount: 1, // Represents topic broadcast
              })
              .where(eq(notificationCampaigns.id, campaign.id));
          } else {
            // Direct device batch send
            const devices = await db
              .select()
              .from(pushDevices)
              .where(eq(pushDevices.isActive, true))
              .limit(500);

            if (devices.length > 0) {
              const tokens = devices.map((d) => d.fcmToken);
              const multicastRes = await firebaseAdmin.messaging().sendEachForMulticast({
                tokens,
                notification: { title, body: msgBody },
                data: {
                  campaignId: campaign.id,
                  clickAction: 'FLUTTER_NOTIFICATION_CLICK',
                },
              });

              let sent = 0;
              let failed = 0;

              for (let i = 0; i < multicastRes.responses.length; i++) {
                const res = multicastRes.responses[i];
                const device = devices[i];

                if (res.success) {
                  sent++;
                  await db
                    .insert(notificationDeliveries)
                    .values({
                      campaignId: campaign.id,
                      deviceId: device.id,
                      fcmMessageId: res.messageId,
                      status: 'sent',
                    })
                    .onConflictDoNothing();
                } else {
                  failed++;
                  const errorCode = res.error?.code || 'UNKNOWN';
                  await db
                    .insert(notificationDeliveries)
                    .values({
                      campaignId: campaign.id,
                      deviceId: device.id,
                      status: 'failed',
                      errorCode,
                    })
                    .onConflictDoNothing();

                  if (
                    errorCode === 'messaging/registration-token-not-registered' ||
                    errorCode === 'messaging/invalid-registration-token'
                  ) {
                    await db
                      .update(pushDevices)
                      .set({ isActive: false })
                      .where(eq(pushDevices.id, device.id));
                  }
                }
              }

              await db
                .update(notificationCampaigns)
                .set({
                  status: 'completed',
                  sentCount: sent,
                  failedCount: failed,
                })
                .where(eq(notificationCampaigns.id, campaign.id));
            } else {
              await db
                .update(notificationCampaigns)
                .set({ status: 'completed' })
                .where(eq(notificationCampaigns.id, campaign.id));
            }
          }
        } catch (dispatchErr) {
          console.error('Immediate campaign dispatch failed:', dispatchErr);
          await db
            .update(notificationCampaigns)
            .set({ status: 'failed' })
            .where(eq(notificationCampaigns.id, campaign.id));
        }
      })();
    }

    return NextResponse.json({ success: true, campaign }, { status: 201 });
  } catch (err: unknown) {
    if (err instanceof AuthError) {
      return NextResponse.json({ error: err.message }, { status: err.statusCode });
    }
    console.error('Error creating notification campaign:', err);
    return NextResponse.json({ error: 'Failed to create campaign' }, { status: 500 });
  }
}
