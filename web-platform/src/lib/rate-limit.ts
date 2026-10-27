import { db } from '../db';
import { rateLimitBuckets } from '../db/schema';
import { eq, sql, lt } from 'drizzle-orm';

export interface RateLimitResult {
  success: boolean;
  remaining: number;
  resetAt: Date;
}

/**
 * Serverless-safe atomic rate limiter using Neon PostgreSQL.
 *
 * @param key Unique rate limit key (e.g. `login:${ip}` or `register:${ip}`)
 * @param maxRequests Maximum requests allowed within the window
 * @param windowSeconds Window length in seconds
 */
export async function checkRateLimit(
  key: string,
  maxRequests: number = 60,
  windowSeconds: number = 60
): Promise<RateLimitResult> {
  const now = new Date();
  const resetAt = new Date(now.getTime() + windowSeconds * 1000);

  try {
    // Clean up expired buckets periodically (10% sample probability or on request)
    if (Math.random() < 0.1) {
      await db.delete(rateLimitBuckets).where(lt(rateLimitBuckets.expiresAt, now));
    }

    // Upsert rate limit bucket
    const result = await db
      .insert(rateLimitBuckets)
      .values({
        key,
        count: 1,
        expiresAt: resetAt,
      })
      .onConflictDoUpdate({
        target: rateLimitBuckets.key,
        set: {
          count: sql`CASE 
            WHEN ${rateLimitBuckets.expiresAt} < ${now} THEN 1 
            ELSE ${rateLimitBuckets.count} + 1 
          END`,
          expiresAt: sql`CASE 
            WHEN ${rateLimitBuckets.expiresAt} < ${now} THEN ${resetAt} 
            ELSE ${rateLimitBuckets.expiresAt} 
          END`,
        },
      })
      .returning({
        count: rateLimitBuckets.count,
        expiresAt: rateLimitBuckets.expiresAt,
      });

    const currentCount = result[0]?.count ?? 1;
    const bucketExpiry = result[0]?.expiresAt ?? resetAt;
    const remaining = Math.max(0, maxRequests - currentCount);

    return {
      success: currentCount <= maxRequests,
      remaining,
      resetAt: bucketExpiry,
    };
  } catch (err) {
    console.error('Rate limiter database fallback:', err);
    // Graceful open policy if database is transiently unreachable to avoid blocking valid traffic
    return {
      success: true,
      remaining: maxRequests,
      resetAt,
    };
  }
}
