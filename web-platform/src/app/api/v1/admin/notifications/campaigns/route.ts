import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/db';
import { notificationCampaigns, pushDevices } from '@/db/schema';
import { eq, desc } from 'drizzle-orm';
import { verifyAdminSession, AuthError } from '@/lib/auth';
import { logAdminAction } from '@/lib/audit';
import { processSingleCampaignDurable } from '@/lib/campaign-processor';

export async function GET(request: NextRequest) {
  try {
    await verifyAdminSession(request, ['superadmin', 'editor', 'veterinarian', 'viewer']);

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
    const admin = await verifyAdminSession(request, ['superadmin', 'editor', 'veterinarian']);
    const body = await request.json();
    const {
      title,
      body: msgBody,
      campaignType = 'announcement',
      targetLocale = 'all',
      targetTopic,
      dataPayload,
      scheduledAt,
      sendImmediately,
    } = body;

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
        campaignType,
        targetLocale,
        targetTopic: targetTopic || 'general_announcements',
        dataPayload: dataPayload || {},
        status: initialStatus,
        scheduledAt: scheduledDate,
        lockedAt: sendImmediately ? new Date() : null,
        createdBy: admin.id,
      })
      .returning();

    await logAdminAction({
      adminUserId: admin.id,
      action: 'CAMPAIGN_CREATE',
      entityType: 'notification_campaign',
      entityId: campaign.id,
      metadata: { title, campaignType, targetLocale, targetTopic, sendImmediately },
    });

    // If sendImmediately, trigger durable execution
    if (sendImmediately) {
      // Run durable processing
      const processResult = await processSingleCampaignDurable(campaign.id);
      return NextResponse.json(
        {
          success: true,
          campaign,
          deliveryResult: processResult,
        },
        { status: 201 }
      );
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
