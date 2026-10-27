'use client';

import React, { useEffect, useState } from 'react';

export default function AdSenseBanner({ slot }: { slot?: string }) {
  const [adsenseEnabled, setAdsenseEnabled] = useState(false);
  const [publisherId, setPublisherId] = useState('');

  useEffect(() => {
    fetch('/api/v1/settings/monetization')
      .then((res) => res.json())
      .then((data) => {
        if (data.data?.adsenseEnabled && data.data?.adsensePublisherId) {
          setAdsenseEnabled(true);
          setPublisherId(data.data.adsensePublisherId);
        }
      })
      .catch(() => {
        // Fallback silently if offline or request fails
      });
  }, []);

  if (!adsenseEnabled || !publisherId) {
    return null;
  }

  return (
    <aside
      aria-label="Advertisement"
      className="my-8 p-4 rounded-2xl border border-dashed border-amber-300 dark:border-amber-900/50 bg-amber-50/50 dark:bg-amber-950/10 flex flex-col items-center justify-center min-h-[100px]"
    >
      <span className="text-[10px] tracking-widest text-slate-400 uppercase mb-2">
        Advertisement
      </span>
      {/* Ins tag rendered when Google AdSense script is active */}
      <ins
        className="adsbygoogle"
        style={{ display: 'block', width: '100%' }}
        data-ad-client={publisherId}
        data-ad-slot={slot || '1234567890'}
        data-ad-format="auto"
        data-full-width-responsive="true"
      />
    </aside>
  );
}
