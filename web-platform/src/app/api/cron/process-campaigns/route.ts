import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/db';
import { notificationCampaigns, pushDevices, notificationDeliveries } from '@/db/schema';
import { eq, and, lte, or } from 'drizzle-orm';
import { firebaseAdmin } from '@/lib/firebase-admin';

export async function GET(request: NextRequest) {
  try {
    const authHeader = request.headers.get('authorization');
    const cronSecret = process.env.CRON_SECRET;

    if (cronSecret && authHeader !== `Bearer ${cronSecret}`) {
      return NextResponse.json({ error: 'Unauthorized cron invocation' }, { status: 401 });
    }

    const now = new Date();

    // Find scheduled campaigns ready for processing
    const pendingCampaigns = await db
      .select()
      .from(notificationCampaigns)
      .where(
        or(
          and(
            eq(notificationCampaigns.status, 'scheduled'),
            lte(notificationCampaigns.scheduledAt, now)
          ),
          eq(notificationCampaigns.status, 'processing')
        )
      )
      .limit(5);

    if (pendingCampaigns.length === 0) {
      return NextResponse.json({ success: true, processed: 0, message: 'No campaigns pending.' });
    }

    let processedCount = 0;

    for (const campaign of pendingCampaigns) {
      // Lock campaign
      await db
        .update(notificationCampaigns)
        .set({ status: 'processing' })
        .where(eq(notificationCampaigns.id, campaign.id));

      try {
        if (campaign.targetTopic) {
          // Topic broadcast
          await firebaseAdmin.messaging().send({
            topic: campaign.targetTopic,
            notification: {
              title: campaign.title,
              body: campaign.body,
            },
            data: {
              campaignId: campaign.id,
              clickAction: 'FLUTTER_NOTIFICATION_CLICK',
            },
          });

          await db
            .update(notificationCampaigns)
            .set({ status: 'completed', sentCount: 1 })
            .where(eq(notificationCampaigns.id, campaign.id));
        } else {
          // Direct token multicast in batches of 500
          const devices = await db
            .select()
            .from(pushDevices)
            .where(eq(pushDevices.isActive, true))
            .limit(500);

          if (devices.length > 0) {
            const tokens = devices.map((d) => d.fcmToken);
            const multicastRes = await firebaseAdmin.messaging().sendEachForMulticast({
              tokens,
              notification: {
                title: campaign.title,
                body: campaign.body,
              },
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
        processedCount++;
      } catch (procErr) {
        console.error(`Error processing campaign ${campaign.id}:`, procErr);
        await db
          .update(notificationCampaigns)
          .set({ status: 'failed' })
          .where(eq(notificationCampaigns.id, campaign.id));
      }
    }

    return NextResponse.json({
      success: true,
      processed: processedCount,
      timestamp: new Date().toISOString(),
    });
  } catch (err) {
    console.error('Cron campaign processing failed:', err);
    return NextResponse.json({ error: 'Internal cron processing failure' }, { status: 500 });
  }
}
