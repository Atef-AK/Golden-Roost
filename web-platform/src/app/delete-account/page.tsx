'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import { Trash2, AlertTriangle, CheckCircle2, ShieldCheck, Mail, ArrowRight } from 'lucide-react';

export default function DeleteAccountPage() {
  const [email, setEmail] = useState('');
  const [reason, setReason] = useState('');
  const [loading, setLoading] = useState(false);
  const [statusMessage, setStatusMessage] = useState<string | null>(null);
  const [debugUrl, setDebugUrl] = useState<string | null>(null);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setStatusMessage(null);
    setErrorMessage(null);
    setDebugUrl(null);

    try {
      const res = await fetch('/api/v1/account-deletion/request', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, reason }),
      });

      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.error || 'Failed to submit deletion request.');
      }

      setStatusMessage(data.message);
      if (data.debugVerificationUrl) {
        setDebugUrl(data.debugVerificationUrl);
      }
    } catch (err: unknown) {
      setErrorMessage(err instanceof Error ? err.message : 'An error occurred.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-16 space-y-10">
      {/* Header */}
      <div className="text-center max-w-xl mx-auto space-y-3">
        <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-red-500/10 text-red-600 dark:text-red-400 text-xs font-bold uppercase tracking-wider">
          <Trash2 size={14} />
          <span>Google Play Compliance</span>
        </div>
        <h1 className="text-3xl sm:text-4xl font-black text-slate-900 dark:text-white">
          Delete Golden Roost Account & Data
        </h1>
        <p className="text-xs sm:text-sm text-slate-600 dark:text-slate-400 leading-relaxed">
          In accordance with Google Play Developer Policies, you may request the total deletion of
          your account and associated server data at any time.
        </p>
      </div>

      {/* Scope Explanation Card */}
      <div className="p-6 rounded-3xl bg-amber-50 dark:bg-amber-950/20 border border-amber-200 dark:border-amber-900/40 text-xs text-amber-900 dark:text-amber-200 space-y-3">
        <div className="flex items-center gap-2 font-bold text-sm text-amber-800 dark:text-amber-400">
          <AlertTriangle size={18} />
          <span>What data will be permanently purged?</span>
        </div>
        <ul className="list-disc pl-5 space-y-1.5 leading-relaxed">
          <li>
            <strong>Firebase & Admin Identifiers:</strong> Your authentication credentials, email, and
            administrative privileges.
          </li>
          <li>
            <strong>Push Notification Records:</strong> Your Firebase Cloud Messaging (FCM) device
            registration tokens and topic subscriptions.
          </li>
          <li>
            <strong>Cloud Sync Data:</strong> Any backed-up farm batches or records stored on our
            servers.
          </li>
        </ul>
        <p className="pt-2 text-[11px] text-amber-800/80 dark:text-amber-300/80">
          <strong>Note on Local Farm Data:</strong> Because Golden Roost uses an offline-first SQLite
          database on your Android device, local coop records remain safely on your phone until you
          clear app storage or uninstall the app from Android Settings.
        </p>
      </div>

      {/* Deletion Form */}
      <div className="p-8 rounded-3xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 shadow-sm">
        {statusMessage ? (
          <div className="text-center py-8 space-y-4">
            <CheckCircle2 size={50} className="mx-auto text-emerald-500" />
            <h2 className="text-xl font-bold text-slate-900 dark:text-white">
              Verification Link Sent
            </h2>
            <p className="text-xs sm:text-sm text-slate-600 dark:text-slate-400 max-w-md mx-auto leading-relaxed">
              {statusMessage}
            </p>
            {debugUrl && (
              <div className="p-4 rounded-xl bg-slate-100 dark:bg-slate-800 border border-slate-300 dark:border-slate-700 text-xs text-start space-y-2">
                <span className="font-bold text-slate-800 dark:text-slate-200 block">
                  Dev Test Link (Direct Verification):
                </span>
                <Link
                  href={debugUrl}
                  className="text-amber-600 dark:text-amber-400 underline break-all font-mono"
                >
                  {debugUrl}
                </Link>
              </div>
            )}
          </div>
        ) : (
          <form onSubmit={handleSubmit} className="space-y-5">
            {errorMessage && (
              <div className="p-4 rounded-xl bg-red-50 dark:bg-red-950/40 text-red-600 dark:text-red-300 text-xs font-medium border border-red-200 dark:border-red-900">
                {errorMessage}
              </div>
            )}

            <div>
              <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
                Account Email Address *
              </label>
              <input
                type="email"
                required
                placeholder="farmer@example.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full px-4 py-3 rounded-xl text-xs bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white focus:outline-none focus:border-red-500"
              />
              <span className="text-[11px] text-slate-400 mt-1 block">
                Enter the email address registered with Golden Roost or associated with your FCM
                device.
              </span>
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
                Reason for Leaving (Optional)
              </label>
              <textarea
                rows={3}
                placeholder="Let us know how we can improve our poultry management tools..."
                value={reason}
                onChange={(e) => setReason(e.target.value)}
                className="w-full px-4 py-3 rounded-xl text-xs bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white focus:outline-none focus:border-red-500"
              />
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full flex items-center justify-center gap-2 py-3.5 rounded-xl bg-red-600 text-white font-bold text-xs hover:bg-red-700 transition-all shadow-md disabled:opacity-50"
            >
              {loading ? (
                <span>Generating Verification Link...</span>
              ) : (
                <>
                  <Trash2 size={15} />
                  <span>Request Account & Data Deletion</span>
                </>
              )}
            </button>
          </form>
        )}
      </div>
    </div>
  );
}
