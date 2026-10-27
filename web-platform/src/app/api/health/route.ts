import { NextResponse } from 'next/server';
import { db } from '@/db';
import { monetizationSettings, articles } from '@/db/schema';
import { count } from 'drizzle-orm';

export async function GET() {
  try {
    const [settings] = await db.select().from(monetizationSettings).limit(1);
    const [articleCount] = await db.select({ total: count() }).from(articles);

    return NextResponse.json({
      status: 'healthy',
      time: new Date().toISOString(),
      database: 'connected',
      articlesCount: articleCount?.total || 0,
      monetization: settings || null,
    });
  } catch (err: unknown) {
    const errorObj = err as any;
    return NextResponse.json({
      status: 'error',
      message: err instanceof Error ? err.message : String(err),
      cause: errorObj?.cause ? (errorObj.cause.message || String(errorObj.cause)) : undefined,
    }, { status: 500 });
  }
}
