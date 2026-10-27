import { db } from '../db';
import { adminAuditLogs } from '../db/schema';

export interface AuditLogParams {
  adminUserId?: string;
  action: string;
  entityType: string;
  entityId?: string;
  metadata?: Record<string, unknown>;
  ipAddress?: string;
}

export async function logAdminAction(params: AuditLogParams): Promise<void> {
  try {
    await db.insert(adminAuditLogs).values({
      adminUserId: params.adminUserId,
      action: params.action,
      entityType: params.entityType,
      entityId: params.entityId,
      metadata: params.metadata,
      ipAddress: params.ipAddress,
    });
  } catch (err) {
    console.error('Failed to write admin audit log:', err);
  }
}
