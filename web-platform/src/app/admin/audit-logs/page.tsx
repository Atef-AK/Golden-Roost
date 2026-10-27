'use client';

import React, { useState, useEffect } from 'react';
import { ShieldAlert, RefreshCw, Clock, Terminal } from 'lucide-react';

interface AuditLogItem {
  id: string;
  action: string;
  entityType: string;
  entityId: string | null;
  metadata: Record<string, unknown> | null;
  ipAddress: string | null;
  createdAt: string;
  adminEmail: string | null;
  adminName: string | null;
}

export default function AdminAuditLogsPage() {
  const [logs, setLogs] = useState<AuditLogItem[]>([]);
  const [loading, setLoading] = useState(true);

  const loadLogs = async () => {
    try {
      setLoading(true);
      const res = await fetch('/api/v1/admin/audit-logs').then((r) => r.json());
      if (res.success) {
        setLogs(res.data || []);
      }
    } catch (e) {
      console.error('Failed to load audit logs:', e);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadLogs();
  }, []);

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-black text-white">Administrative Audit Trail</h1>
          <p className="text-xs text-slate-400 mt-1">
            Tamper-evident logs of administrative actions, authentication attempts, and CMS updates.
          </p>
        </div>
        <button
          onClick={loadLogs}
          className="p-2 rounded-xl bg-slate-900 border border-slate-800 text-slate-400 hover:text-white"
        >
          <RefreshCw size={15} />
        </button>
      </div>

      <div className="rounded-3xl bg-slate-900 border border-slate-800 overflow-hidden shadow-sm">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-slate-800/60 text-slate-400 uppercase tracking-wider text-[10px] font-bold border-b border-slate-800">
              <tr>
                <th className="px-6 py-3.5">Timestamp</th>
                <th className="px-6 py-3.5">Admin User</th>
                <th className="px-6 py-3.5">Action</th>
                <th className="px-6 py-3.5">Entity</th>
                <th className="px-6 py-3.5">IP Address</th>
                <th className="px-6 py-3.5 text-right">Metadata</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800 text-slate-300">
              {loading ? (
                <tr>
                  <td colSpan={6} className="px-6 py-8 text-center text-slate-500">
                    Loading audit trail...
                  </td>
                </tr>
              ) : logs.length > 0 ? (
                logs.map((log) => (
                  <tr key={log.id} className="hover:bg-slate-800/30 transition-colors">
                    <td className="px-6 py-4 text-slate-400 text-[11px] whitespace-nowrap">
                      {new Date(log.createdAt).toLocaleString()}
                    </td>
                    <td className="px-6 py-4">
                      <span className="font-bold text-white block">
                        {log.adminName || log.adminEmail || 'System'}
                      </span>
                      {log.adminEmail && (
                        <span className="text-[10px] text-slate-500 block">{log.adminEmail}</span>
                      )}
                    </td>
                    <td className="px-6 py-4">
                      <span className="px-2 py-0.5 rounded-md text-[10px] font-mono font-bold bg-amber-500/10 text-amber-400">
                        {log.action}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-slate-300">
                      <span className="capitalize">{log.entityType}</span>
                      {log.entityId && (
                        <span className="text-[10px] text-slate-500 block font-mono">
                          {log.entityId.substring(0, 8)}...
                        </span>
                      )}
                    </td>
                    <td className="px-6 py-4 text-slate-400 font-mono text-[11px]">
                      {log.ipAddress || 'unknown'}
                    </td>
                    <td className="px-6 py-4 text-right">
                      {log.metadata ? (
                        <pre className="text-[10px] text-slate-400 font-mono inline-block max-w-[200px] truncate">
                          {JSON.stringify(log.metadata)}
                        </pre>
                      ) : (
                        <span className="text-slate-600">—</span>
                      )}
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan={6} className="px-6 py-8 text-center text-slate-500">
                    No audit records recorded yet.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
