import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/db';
import { adminAuditLogs, adminUsers } from '@/db/schema';
import { desc, eq } from 'drizzle-orm';
import { verifyAdminSession, AuthError } from '@/lib/auth';

export async function GET(request: NextRequest) {
  try {
    await verifyAdminSession(request, ['superadmin']);

    const logs = await db
      .select({
        id: adminAuditLogs.id,
        action: adminAuditLogs.action,
        entityType: adminAuditLogs.entityType,
        entityId: adminAuditLogs.entityId,
        metadata: adminAuditLogs.metadata,
        ipAddress: adminAuditLogs.ipAddress,
        createdAt: adminAuditLogs.createdAt,
        adminEmail: adminUsers.email,
        adminName: adminUsers.displayName,
      })
      .from(adminAuditLogs)
      .leftJoin(adminUsers, eq(adminAuditLogs.adminUserId, adminUsers.id))
      .orderBy(desc(adminAuditLogs.createdAt))
      .limit(100);

    return NextResponse.json({ success: true, count: logs.length, data: logs });
  } catch (err: unknown) {
    if (err instanceof AuthError) {
      return NextResponse.json({ error: err.message }, { status: err.statusCode });
    }
    return NextResponse.json({ error: 'Failed to fetch audit logs' }, { status: 500 });
  }
}
