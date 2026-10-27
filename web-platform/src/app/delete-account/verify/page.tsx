'use client';

import React, { useState, useEffect, Suspense } from 'react';
import Link from 'next/link';
import { useSearchParams } from 'next/navigation';
import { CheckCircle2, AlertTriangle, ArrowRight, Home } from 'lucide-react';

function DeletionVerifier() {
  const searchParams = useSearchParams();
  const token = searchParams.get('token');

  const [loading, setLoading] = useState(true);
  const [success, setSuccess] = useState(false);
  const [message, setMessage] = useState('');

  useEffect(() => {
    if (!token) {
      setLoading(false);
      setMessage('No verification token provided in the URL.');
      return;
    }

    fetch('/api/v1/account-deletion/verify', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ token }),
    })
      .then((res) => res.json())
      .then((data) => {
        if (data.success) {
          setSuccess(true);
          setMessage(data.message);
        } else {
          setSuccess(false);
          setMessage(data.error || 'Verification failed.');
        }
      })
      .catch(() => {
        setSuccess(false);
        setMessage('Network error while verifying deletion request.');
      })
      .finally(() => {
        setLoading(false);
      });
  }, [token]);

  if (loading) {
    return (
      <div className="py-20 text-center animate-pulse space-y-4">
        <div className="w-12 h-12 rounded-full bg-slate-200 dark:bg-slate-800 mx-auto" />
        <p className="text-xs text-slate-500">Verifying deletion token and purging records...</p>
      </div>
    );
  }

  return (
    <div className="p-8 rounded-3xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 shadow-sm text-center space-y-5">
      {success ? (
        <>
          <CheckCircle2 size={54} className="mx-auto text-emerald-500" />
          <h1 className="text-2xl font-black text-slate-900 dark:text-white">
            Data Deletion Confirmed
          </h1>
          <p className="text-xs sm:text-sm text-slate-600 dark:text-slate-400 max-w-md mx-auto leading-relaxed">
            {message}
          </p>
          <div className="pt-4">
            <Link
              href="/"
              className="inline-flex items-center gap-2 px-6 py-3 rounded-xl gold-gradient text-slate-950 font-bold text-xs"
            >
              <Home size={14} />
              <span>Return to Golden Roost</span>
            </Link>
          </div>
        </>
      ) : (
        <>
          <AlertTriangle size={54} className="mx-auto text-red-500" />
          <h1 className="text-2xl font-black text-slate-900 dark:text-white">
            Verification Unsuccessful
          </h1>
          <p className="text-xs sm:text-sm text-slate-600 dark:text-slate-400 max-w-md mx-auto leading-relaxed">
            {message}
          </p>
          <div className="pt-4">
            <Link
              href="/delete-account"
              className="inline-flex items-center gap-2 px-6 py-3 rounded-xl bg-slate-900 text-white font-bold text-xs hover:bg-slate-800"
            >
              <span>Submit New Request</span>
            </Link>
          </div>
        </>
      )}
    </div>
  );
}

export default function VerifyDeletionPage() {
  return (
    <div className="max-w-xl mx-auto px-4 py-20">
      <Suspense fallback={<div className="text-center py-20 text-xs text-slate-500">Loading...</div>}>
        <DeletionVerifier />
      </Suspense>
    </div>
  );
}
