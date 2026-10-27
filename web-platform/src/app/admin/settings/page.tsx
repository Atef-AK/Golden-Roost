'use client';

import React, { useState, useEffect } from 'react';
import { Sliders, Save, CheckCircle2, AlertCircle, ShieldAlert, DollarSign } from 'lucide-react';

export default function AdminSettingsPage() {
  const [adsenseEnabled, setAdsenseEnabled] = useState(false);
  const [adsensePublisherId, setAdsensePublisherId] = useState('');
  const [admobEnabled, setAdmobEnabled] = useState(true);
  const [admobBannerId, setAdmobBannerId] = useState('');
  const [admobInterstitialId, setAdmobInterstitialId] = useState('');

  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [feedback, setFeedback] = useState<{ type: 'success' | 'error'; text: string } | null>(
    null
  );

  useEffect(() => {
    fetch('/api/v1/settings/monetization')
      .then((r) => r.json())
      .then((data) => {
        if (data.data) {
          const s = data.data;
          setAdsenseEnabled(!!s.adsenseEnabled);
          setAdsensePublisherId(s.adsensePublisherId || '');
          setAdmobEnabled(s.admobEnabled !== undefined ? !!s.admobEnabled : true);
          setAdmobBannerId(s.admobBannerId || '');
          setAdmobInterstitialId(s.admobInterstitialId || '');
        }
      })
      .catch((e) => {
        console.error('Failed to load settings:', e);
      })
      .finally(() => {
        setLoading(false);
      });
  }, []);

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    setFeedback(null);

    try {
      const res = await fetch('/api/v1/settings/monetization', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          adsenseEnabled,
          adsensePublisherId: adsensePublisherId.trim() || null,
          admobEnabled,
          admobBannerId: admobBannerId.trim() || null,
          admobInterstitialId: admobInterstitialId.trim() || null,
        }),
      });

      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.error || 'Failed to update monetization settings.');
      }

      setFeedback({ type: 'success', text: 'Monetization settings updated successfully.' });
    } catch (err: unknown) {
      setFeedback({
        type: 'error',
        text: err instanceof Error ? err.message : 'Update failed.',
      });
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="py-20 text-center text-slate-500 text-xs">
        Loading platform monetization configuration...
      </div>
    );
  }

  return (
    <div className="max-w-3xl space-y-8">
      <div>
        <h1 className="text-2xl font-black text-white">Monetization & Ad Networks</h1>
        <p className="text-xs text-slate-400 mt-1">
          Control ad network integration across web articles and native Android Flutter client.
        </p>
      </div>

      {feedback && (
        <div
          className={`p-4 rounded-2xl text-xs flex items-center gap-2 ${
            feedback.type === 'success'
              ? 'bg-emerald-950/60 border border-emerald-800 text-emerald-300'
              : 'bg-red-950/60 border border-red-800 text-red-300'
          }`}
        >
          {feedback.type === 'success' ? (
            <CheckCircle2 size={16} className="shrink-0 text-emerald-400" />
          ) : (
            <AlertCircle size={16} className="shrink-0 text-red-400" />
          )}
          <span>{feedback.text}</span>
        </div>
      )}

      <form onSubmit={handleSave} className="space-y-6">
        {/* Google AdSense (Web) */}
        <div className="p-6 rounded-3xl bg-slate-900 border border-slate-800 space-y-4 shadow-sm">
          <div className="flex items-center justify-between pb-3 border-b border-slate-800">
            <div>
              <h2 className="text-sm font-bold text-white flex items-center gap-2">
                <DollarSign size={16} className="text-amber-500" />
                <span>Google AdSense (Web Platform)</span>
              </h2>
              <p className="text-[11px] text-slate-400 mt-0.5">
                Displays responsive banner ads across public website articles and product catalogues.
              </p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                checked={adsenseEnabled}
                onChange={(e) => setAdsenseEnabled(e.target.checked)}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-slate-800 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-slate-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-amber-500" />
            </label>
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-300 mb-1">
              AdSense Publisher ID
            </label>
            <input
              type="text"
              placeholder="ca-pub-0000000000000000"
              value={adsensePublisherId}
              onChange={(e) => setAdsensePublisherId(e.target.value)}
              className="w-full px-3 py-2 rounded-xl text-xs font-mono bg-slate-800 border border-slate-700 text-white focus:outline-none focus:border-amber-500"
            />
          </div>
        </div>

        {/* Google AdMob (Android Mobile App) */}
        <div className="p-6 rounded-3xl bg-slate-900 border border-slate-800 space-y-4 shadow-sm">
          <div className="flex items-center justify-between pb-3 border-b border-slate-800">
            <div>
              <h2 className="text-sm font-bold text-white flex items-center gap-2">
                <DollarSign size={16} className="text-emerald-500" />
                <span>Google AdMob (Mobile Android App)</span>
              </h2>
              <p className="text-[11px] text-slate-400 mt-0.5">
                Serves banners and interstitials inside the Golden Roost Flutter mobile client.
              </p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                checked={admobEnabled}
                onChange={(e) => setAdmobEnabled(e.target.checked)}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-slate-800 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-slate-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-emerald-500" />
            </label>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold text-slate-300 mb-1">
                AdMob Banner Unit ID
              </label>
              <input
                type="text"
                placeholder="ca-app-pub-3940256099942544/6300978111"
                value={admobBannerId}
                onChange={(e) => setAdmobBannerId(e.target.value)}
                className="w-full px-3 py-2 rounded-xl text-xs font-mono bg-slate-800 border border-slate-700 text-white focus:outline-none focus:border-emerald-500"
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-300 mb-1">
                AdMob Interstitial Unit ID
              </label>
              <input
                type="text"
                placeholder="ca-app-pub-3940256099942544/1033173712"
                value={admobInterstitialId}
                onChange={(e) => setAdmobInterstitialId(e.target.value)}
                className="w-full px-3 py-2 rounded-xl text-xs font-mono bg-slate-800 border border-slate-700 text-white focus:outline-none focus:border-emerald-500"
              />
            </div>
          </div>
        </div>

        <button
          type="submit"
          disabled={saving}
          className="flex items-center justify-center gap-2 px-6 py-3 rounded-xl gold-gradient text-slate-950 font-bold text-xs shadow-md hover:scale-[1.01] active:scale-[0.99] transition-all disabled:opacity-50"
        >
          <Save size={15} />
          <span>{saving ? 'Updating Settings...' : 'Save Monetization Settings'}</span>
        </button>
      </form>
    </div>
  );
}
