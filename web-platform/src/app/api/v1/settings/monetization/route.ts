import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/db';
import { monetizationSettings } from '@/db/schema';
import { eq } from 'drizzle-orm';
import { verifyAdminSession, AuthError } from '@/lib/auth';
import { logAdminAction } from '@/lib/audit';

export async function GET() {
  try {
    const [settings] = await db
      .select()
      .from(monetizationSettings)
      .where(eq(monetizationSettings.id, 'global'))
      .limit(1);

    return NextResponse.json({
      success: true,
      data: settings || {
        adsenseEnabled: false,
        adsensePublisherId: '',
        admobEnabled: true,
        admobBannerId: 'ca-app-pub-3940256099942544/6300978111',
        admobInterstitialId: 'ca-app-pub-3940256099942544/1033173712',
      },
    });
  } catch (err) {
    console.error('Failed to get monetization settings:', err);
    return NextResponse.json({ error: 'Failed to get settings' }, { status: 500 });
  }
}

export async function PUT(request: NextRequest) {
  try {
    const admin = await verifyAdminSession(request, ['superadmin']);
    const body = await request.json();
    const { adsenseEnabled, adsensePublisherId, admobEnabled, admobBannerId, admobInterstitialId } =
      body;

    const [updated] = await db
      .insert(monetizationSettings)
      .values({
        id: 'global',
        adsenseEnabled: !!adsenseEnabled,
        adsensePublisherId: adsensePublisherId || null,
        admobEnabled: admobEnabled !== undefined ? !!admobEnabled : true,
        admobBannerId: admobBannerId || null,
        admobInterstitialId: admobInterstitialId || null,
        updatedAt: new Date(),
      })
      .onConflictDoUpdate({
        target: monetizationSettings.id,
        set: {
          adsenseEnabled: !!adsenseEnabled,
          adsensePublisherId: adsensePublisherId || null,
          admobEnabled: admobEnabled !== undefined ? !!admobEnabled : true,
          admobBannerId: admobBannerId || null,
          admobInterstitialId: admobInterstitialId || null,
          updatedAt: new Date(),
        },
      })
      .returning();

    await logAdminAction({
      adminUserId: admin.id,
      action: 'SETTINGS_UPDATE_MONETIZATION',
      entityType: 'settings',
      entityId: 'global',
      metadata: { adsenseEnabled, admobEnabled },
    });

    return NextResponse.json({ success: true, data: updated });
  } catch (err: unknown) {
    if (err instanceof AuthError) {
      return NextResponse.json({ error: err.message }, { status: err.statusCode });
    }
    return NextResponse.json({ error: 'Failed to update monetization settings' }, { status: 500 });
  }
}
