'use client';

import React, { useState, useEffect } from 'react';
import { Bell, Send, Clock, CheckCircle2, AlertCircle, Smartphone, RefreshCw } from 'lucide-react';

interface CampaignItem {
  id: string;
  title: string;
  body: string;
  targetTopic: string | null;
  status: string;
  sentCount: number;
  failedCount: number;
  scheduledAt: string | null;
  createdAt: string;
}

export default function AdminNotificationsPage() {
  const [campaigns, setCampaigns] = useState<CampaignItem[]>([]);
  const [totalDevices, setTotalDevices] = useState(0);
  const [loading, setLoading] = useState(true);

  // Composer Form
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [targetTopic, setTargetTopic] = useState('general_announcements');
  const [sendImmediately, setSendImmediately] = useState(true);
  const [scheduledAt, setScheduledAt] = useState('');
  const [sending, setSending] = useState(false);
  const [feedback, setFeedback] = useState<{ type: 'success' | 'error'; text: string } | null>(
    null
  );

  const loadCampaigns = async () => {
    try {
      setLoading(true);
      const res = await fetch('/api/v1/admin/notifications/campaigns').then((r) => r.json());
      if (res.success) {
        setCampaigns(res.data || []);
        setTotalDevices(res.totalActiveDevices || 0);
      }
    } catch (e) {
      console.error('Failed to load campaigns:', e);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadCampaigns();
  }, []);

  const handleDispatch = async (e: React.FormEvent) => {
    e.preventDefault();
    setSending(true);
    setFeedback(null);

    const payload = {
      title: title.trim(),
      body: body.trim(),
      targetTopic: targetTopic === 'all_direct' ? null : targetTopic,
      sendImmediately,
      scheduledAt: !sendImmediately && scheduledAt ? new Date(scheduledAt).toISOString() : null,
    };

    try {
      const res = await fetch('/api/v1/admin/notifications/campaigns', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });

      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.error || 'Failed to dispatch notification.');
      }

      setFeedback({
        type: 'success',
        text: sendImmediately
          ? 'Notification broadcast triggered successfully!'
          : 'Notification scheduled successfully.',
      });

      setTitle('');
      setBody('');
      loadCampaigns();
    } catch (err: unknown) {
      setFeedback({
        type: 'error',
        text: err instanceof Error ? err.message : 'Dispatch failed.',
      });
    } finally {
      setSending(false);
    }
  };

  return (
    <div className="space-y-8">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-black text-white">Push Notification Center</h1>
        <p className="text-xs text-slate-400 mt-1">
          Broadcast veterinary disease alerts, weather advisories, and app updates to active Android
          devices.
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Broadcast Composer */}
        <div className="lg:col-span-1 p-6 rounded-3xl bg-slate-900 border border-slate-800 shadow-sm space-y-5">
          <div className="flex items-center justify-between pb-3 border-b border-slate-800">
            <h2 className="text-sm font-bold text-white flex items-center gap-2">
              <Bell size={16} className="text-amber-500" />
              <span>Compose Message</span>
            </h2>
            <div className="flex items-center gap-1.5 text-[11px] text-slate-400">
              <Smartphone size={13} className="text-emerald-400" />
              <span>{totalDevices} Active Devices</span>
            </div>
          </div>

          {feedback && (
            <div
              className={`p-3 rounded-xl text-xs flex items-center gap-2 ${
                feedback.type === 'success'
                  ? 'bg-emerald-950/60 border border-emerald-800 text-emerald-300'
                  : 'bg-red-950/60 border border-red-800 text-red-300'
              }`}
            >
              {feedback.type === 'success' ? (
                <CheckCircle2 size={15} className="shrink-0 text-emerald-400" />
              ) : (
                <AlertCircle size={15} className="shrink-0 text-red-400" />
              )}
              <span>{feedback.text}</span>
            </div>
          )}

          <form onSubmit={handleDispatch} className="space-y-4">
            <div>
              <label className="block text-xs font-bold text-slate-300 mb-1">
                Notification Title *
              </label>
              <input
                type="text"
                required
                placeholder="Biosecurity Alert: Newcastle Outbreak"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                className="w-full px-3 py-2 rounded-xl text-xs bg-slate-800 border border-slate-700 text-white focus:outline-none focus:border-amber-500"
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-300 mb-1">
                Message Body *
              </label>
              <textarea
                required
                rows={3}
                placeholder="Farmers in the region are advised to inspect footbaths and restrict coop visitors..."
                value={body}
                onChange={(e) => setBody(e.target.value)}
                className="w-full px-3 py-2 rounded-xl text-xs bg-slate-800 border border-slate-700 text-white focus:outline-none focus:border-amber-500"
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-300 mb-1">Target Audience</label>
              <select
                value={targetTopic}
                onChange={(e) => setTargetTopic(e.target.value)}
                className="w-full px-3 py-2 rounded-xl text-xs bg-slate-800 border border-slate-700 text-white focus:outline-none focus:border-amber-500"
              >
                <option value="general_announcements">All Users (general_announcements)</option>
                <option value="poultry_tips">Poultry Tips & Veterinary Protocols</option>
                <option value="disease_alerts">Urgent Disease Alerts Only</option>
                <option value="all_direct">Direct Token Multicast (500 device batch)</option>
              </select>
            </div>

            {/* Delivery Timing */}
            <div className="space-y-2 pt-2">
              <label className="block text-xs font-bold text-slate-300">Delivery Timing</label>
              <div className="flex items-center gap-4 text-xs text-slate-300">
                <label className="flex items-center gap-1.5 cursor-pointer">
                  <input
                    type="radio"
                    name="timing"
                    checked={sendImmediately}
                    onChange={() => setSendImmediately(true)}
                    className="text-amber-500"
                  />
                  <span>Send Immediately</span>
                </label>
                <label className="flex items-center gap-1.5 cursor-pointer">
                  <input
                    type="radio"
                    name="timing"
                    checked={!sendImmediately}
                    onChange={() => setSendImmediately(false)}
                    className="text-amber-500"
                  />
                  <span>Schedule</span>
                </label>
              </div>

              {!sendImmediately && (
                <input
                  type="datetime-local"
                  required={!sendImmediately}
                  value={scheduledAt}
                  onChange={(e) => setScheduledAt(e.target.value)}
                  className="w-full px-3 py-2 rounded-xl text-xs bg-slate-800 border border-slate-700 text-white focus:outline-none focus:border-amber-500 mt-2"
                />
              )}
            </div>

            <button
              type="submit"
              disabled={sending}
              className="w-full flex items-center justify-center gap-2 py-3 rounded-xl gold-gradient text-slate-950 font-bold text-xs shadow-md hover:scale-[1.01] active:scale-[0.99] transition-all disabled:opacity-50"
            >
              <Send size={14} />
              <span>{sending ? 'Dispatching...' : sendImmediately ? 'Send Broadcast Now' : 'Schedule Broadcast'}</span>
            </button>
          </form>
        </div>

        {/* Campaign History Table */}
        <div className="lg:col-span-2 space-y-4">
          <div className="flex items-center justify-between">
            <h2 className="text-sm font-bold text-white">Broadcast History & Deliveries</h2>
            <button
              onClick={loadCampaigns}
              className="p-1.5 rounded-lg bg-slate-900 border border-slate-800 text-slate-400 hover:text-white"
              title="Refresh"
            >
              <RefreshCw size={14} />
            </button>
          </div>

          <div className="rounded-3xl bg-slate-900 border border-slate-800 overflow-hidden shadow-sm">
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs">
                <thead className="bg-slate-800/60 text-slate-400 uppercase tracking-wider text-[10px] font-bold border-b border-slate-800">
                  <tr>
                    <th className="px-6 py-3.5">Title & Message</th>
                    <th className="px-6 py-3.5">Audience</th>
                    <th className="px-6 py-3.5">Status</th>
                    <th className="px-6 py-3.5">Delivered</th>
                    <th className="px-6 py-3.5 text-right">Date</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-800 text-slate-300">
                  {loading ? (
                    <tr>
                      <td colSpan={5} className="px-6 py-8 text-center text-slate-500">
                        Loading broadcast history...
                      </td>
                    </tr>
                  ) : campaigns.length > 0 ? (
                    campaigns.map((camp) => (
                      <tr key={camp.id} className="hover:bg-slate-800/30 transition-colors">
                        <td className="px-6 py-4 max-w-xs">
                          <span className="font-bold text-white block">{camp.title}</span>
                          <span className="text-[11px] text-slate-400 line-clamp-1">
                            {camp.body}
                          </span>
                        </td>
                        <td className="px-6 py-4 font-mono text-[11px] text-amber-400">
                          {camp.targetTopic || 'Direct Multicast'}
                        </td>
                        <td className="px-6 py-4">
                          <span
                            className={`px-2.5 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wider ${
                              camp.status === 'completed'
                                ? 'bg-emerald-500/10 text-emerald-400'
                                : camp.status === 'processing'
                                ? 'bg-amber-500/10 text-amber-400 animate-pulse'
                                : camp.status === 'scheduled'
                                ? 'bg-blue-500/10 text-blue-400'
                                : 'bg-slate-800 text-slate-400'
                            }`}
                          >
                            {camp.status}
                          </span>
                        </td>
                        <td className="px-6 py-4 text-xs font-semibold">
                          <span className="text-emerald-400">{camp.sentCount} sent</span>
                          {camp.failedCount > 0 && (
                            <span className="text-red-400 ml-1.5">({camp.failedCount} failed)</span>
                          )}
                        </td>
                        <td className="px-6 py-4 text-right text-slate-400 text-[11px]">
                          {new Date(camp.createdAt).toLocaleDateString()}
                        </td>
                      </tr>
                    ))
                  ) : (
                    <tr>
                      <td colSpan={5} className="px-6 py-8 text-center text-slate-500">
                        No notification broadcasts sent yet.
                      </td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
