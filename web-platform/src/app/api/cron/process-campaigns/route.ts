import { NextRequest, NextResponse } from 'next/server';
import { executeDurableCampaigns } from '@/lib/campaign-processor';

export async function GET(request: NextRequest) {
  try {
    const authHeader = request.headers.get('authorization');
    const cronSecret = process.env.CRON_SECRET;

    // Strict security check: reject requests whenever CRON_SECRET is missing or invalid
    if (!cronSecret || authHeader !== `Bearer ${cronSecret}`) {
      return NextResponse.json(
        { error: 'Unauthorized: Missing or invalid CRON_SECRET.' },
        { status: 401 }
      );
    }

    const results = await executeDurableCampaigns();

    return NextResponse.json({
      success: true,
      processedCampaigns: results.length,
      results,
      timestamp: new Date().toISOString(),
    });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : 'Unknown error';
    console.error('Error in cron campaign processor:', err);
    return NextResponse.json(
      { error: 'Cron execution failed', details: message },
      { status: 500 }
    );
  }
}
