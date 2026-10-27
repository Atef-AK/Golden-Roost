import { db } from '@/db';
import { notificationCampaigns, pushDevices, notificationDeliveries } from '@/db/schema';
import { eq, and, or, lte, lt, sql, SQL } from 'drizzle-orm';
import { firebaseAdmin } from '@/lib/firebase-admin';

export interface CampaignProcessingResult {
  campaignId: string;
  status: 'completed' | 'in_progress' | 'failed' | 'skipped';
  sentInRun: number;
  failedInRun: number;
  message?: string;
}

/**
 * Atomically claims a campaign using a database lease.
 * A campaign can be claimed if:
 * 1. status is 'scheduled' AND scheduledAt <= now (or scheduledAt is null)
 * 2. status is 'processing' AND lockedAt < (now - 5 minutes) [stale lock recovery]
 */
export async function claimCampaign(campaignId: string): Promise<boolean> {
  const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000);

  const claimed = await db
    .update(notificationCampaigns)
    .set({
      status: 'processing',
      lockedAt: new Date(),
    })
    .where(
      and(
        eq(notificationCampaigns.id, campaignId),
        or(
          eq(notificationCampaigns.status, 'scheduled'),
          and(
            eq(notificationCampaigns.status, 'processing'),
            or(
              sql`${notificationCampaigns.lockedAt} IS NULL`,
              lt(notificationCampaigns.lockedAt, fiveMinutesAgo)
            )
          )
        )
      )
    )
    .returning({ id: notificationCampaigns.id });

  return claimed.length > 0;
}

/**
 * Finds pending campaigns ready to be claimed and processed.
 */
export async function findEligibleCampaignIds(limit: number = 5): Promise<string[]> {
  const now = new Date();
  const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000);

  const eligible = await db
    .select({ id: notificationCampaigns.id })
    .from(notificationCampaigns)
    .where(
      or(
        and(
          eq(notificationCampaigns.status, 'scheduled'),
          or(
            sql`${notificationCampaigns.scheduledAt} IS NULL`,
            lte(notificationCampaigns.scheduledAt, now)
          )
        ),
        and(
          eq(notificationCampaigns.status, 'processing'),
          or(
            sql`${notificationCampaigns.lockedAt} IS NULL`,
            lt(notificationCampaigns.lockedAt, fiveMinutesAgo)
          )
        )
      )
    )
    .limit(limit);

  return eligible.map((c) => c.id);
}

/**
 * Processes a single campaign durably with pagination, recipient filtering,
 * and delivery tracking.
 *
 * Firebase Cloud Messaging multicast supports up to 500 tokens per call.
 * This durable processor loops in batches of up to 500 until all eligible recipients
 * have been notified, or pauses if approaching time budget.
 */
export async function processSingleCampaignDurable(
  campaignId: string,
  maxBatchesPerRun: number = 10
): Promise<CampaignProcessingResult> {
  const [campaign] = await db
    .select()
    .from(notificationCampaigns)
    .where(eq(notificationCampaigns.id, campaignId))
    .limit(1);

  if (!campaign) {
    return { campaignId, status: 'skipped', sentInRun: 0, failedInRun: 0, message: 'Campaign not found' };
  }

  // Construct target filters
  const conditions: SQL[] = [eq(pushDevices.isActive, true)];

  // 1. Target Locale filter
  if (campaign.targetLocale && campaign.targetLocale !== 'all') {
    conditions.push(eq(pushDevices.locale, campaign.targetLocale));
  }

  // 2. Opt-in consent filter
  if (campaign.campaignType === 'marketing') {
    conditions.push(eq(pushDevices.marketingOptIn, true));
  } else if (campaign.campaignType === 'article_alert') {
    conditions.push(eq(pushDevices.articleAlertsOptIn, true));
  } else if (campaign.campaignType === 'disease_alert') {
    conditions.push(eq(pushDevices.diseaseAlertsOptIn, true));
  }

  // 3. Target topic filter
  if (campaign.targetTopic && campaign.targetTopic !== 'all' && campaign.targetTopic !== 'general_announcements') {
    conditions.push(sql`${pushDevices.topics} @> ${JSON.stringify([campaign.targetTopic])}::jsonb`);
  }

  let totalSentInRun = 0;
  let totalFailedInRun = 0;
  let batchCount = 0;

  try {
    while (batchCount < maxBatchesPerRun) {
      batchCount++;

      // Find up to 500 eligible devices that have NOT yet received this campaign
      const devices = await db
        .select({
          id: pushDevices.id,
          fcmToken: pushDevices.fcmToken,
        })
        .from(pushDevices)
        .where(
          and(
            ...conditions,
            sql`${pushDevices.id} NOT IN (
              SELECT device_id FROM ${notificationDeliveries} 
              WHERE campaign_id = ${campaign.id}
            )`
          )
        )
        .limit(500);

      if (devices.length === 0) {
        // All eligible devices have received the notification!
        await db
          .update(notificationCampaigns)
          .set({
            status: 'completed',
            completedAt: new Date(),
            lockedAt: null,
          })
          .where(eq(notificationCampaigns.id, campaign.id));

        return {
          campaignId,
          status: 'completed',
          sentInRun: totalSentInRun,
          failedInRun: totalFailedInRun,
          message: 'All eligible recipients notified successfully.',
        };
      }

      // Prepare FCM multicast payload
      const tokens = devices.map((d) => d.fcmToken);
      const dataPayload: Record<string, string> = {
        campaignId: campaign.id,
        campaignType: campaign.campaignType,
        clickAction: 'FLUTTER_NOTIFICATION_CLICK',
      };

      if (campaign.dataPayload && typeof campaign.dataPayload === 'object') {
        for (const [k, v] of Object.entries(campaign.dataPayload)) {
          if (v !== undefined && v !== null) {
            dataPayload[k] = String(v);
          }
        }
      }

      const multicastRes = await firebaseAdmin.messaging().sendEachForMulticast({
        tokens,
        notification: {
          title: campaign.title,
          body: campaign.body,
        },
        data: dataPayload,
      });

      let batchSent = 0;
      let batchFailed = 0;

      for (let i = 0; i < multicastRes.responses.length; i++) {
        const res = multicastRes.responses[i];
        const device = devices[i];

        if (res.success) {
          batchSent++;
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
          batchFailed++;
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

          // Automatically deactivate stale or unregistered FCM tokens
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

      totalSentInRun += batchSent;
      totalFailedInRun += batchFailed;

      // Update progress & refresh lease lock
      await db
        .update(notificationCampaigns)
        .set({
          sentCount: sql`${notificationCampaigns.sentCount} + ${batchSent}`,
          failedCount: sql`${notificationCampaigns.failedCount} + ${batchFailed}`,
          lockedAt: new Date(),
        })
        .where(eq(notificationCampaigns.id, campaign.id));

      // If this batch was under 500, no more devices remain for this campaign
      if (devices.length < 500) {
        await db
          .update(notificationCampaigns)
          .set({
            status: 'completed',
            completedAt: new Date(),
            lockedAt: null,
          })
          .where(eq(notificationCampaigns.id, campaign.id));

        return {
          campaignId,
          status: 'completed',
          sentInRun: totalSentInRun,
          failedInRun: totalFailedInRun,
          message: 'All eligible recipients notified successfully.',
        };
      }
    }

    // Hit batch limit in this run; campaign remains in 'processing' status to be continued
    return {
      campaignId,
      status: 'in_progress',
      sentInRun: totalSentInRun,
      failedInRun: totalFailedInRun,
      message: 'Batch limit reached for this run. More recipients pending.',
    };
  } catch (err: unknown) {
    const errorMsg = err instanceof Error ? err.message : String(err);
    console.error(`Error processing campaign ${campaignId}:`, err);
    await db
      .update(notificationCampaigns)
      .set({
        status: 'failed',
        lockedAt: null,
      })
      .where(eq(notificationCampaigns.id, campaign.id));

    return {
      campaignId,
      status: 'failed',
      sentInRun: totalSentInRun,
      failedInRun: totalFailedInRun,
      message: errorMsg,
    };
  }
}

/**
 * Claims and runs all eligible scheduled or in-progress campaigns durably.
 */
export async function executeDurableCampaigns(): Promise<CampaignProcessingResult[]> {
  const candidateIds = await findEligibleCampaignIds(5);
  const results: CampaignProcessingResult[] = [];

  for (const id of candidateIds) {
    const claimed = await claimCampaign(id);
    if (!claimed) {
      continue; // Claim collision; another worker acquired the lease
    }

    const result = await processSingleCampaignDurable(id);
    results.push(result);
  }

  return results;
}
