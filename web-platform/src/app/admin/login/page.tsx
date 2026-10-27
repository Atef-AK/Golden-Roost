'use client';

import React, { useState } from 'react';
import { useRouter } from 'next/navigation';
import { signInWithEmailAndPassword } from 'firebase/auth';
import { getClientAuth } from '@/lib/firebase-client';
import { Shield, Lock, Mail, ArrowRight, AlertCircle } from 'lucide-react';
import Link from 'next/link';

export default function AdminLoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setErrorMessage(null);

    try {
      const auth = getClientAuth();
      const userCredential = await signInWithEmailAndPassword(auth, email, password);
      const idToken = await userCredential.user.getIdToken();

      // Exchange ID token for an HTTP-only session cookie
      const sessionRes = await fetch('/api/v1/admin/auth/session', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ idToken }),
      });

      const sessionData = await sessionRes.json();

      if (!sessionRes.ok) {
        throw new Error(sessionData.error || 'Server session rejected.');
      }

      router.push('/admin');
    } catch (err: unknown) {
      console.error('Sign-in failed:', err);
      setErrorMessage(
        err instanceof Error ? err.message : 'Invalid administrator credentials.'
      );
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center p-4 bg-slate-950 text-slate-100 relative overflow-hidden">
      {/* Background glow */}
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[500px] h-[300px] bg-amber-500/10 blur-[120px] rounded-full pointer-events-none" />

      <div className="w-full max-w-md p-8 rounded-3xl bg-slate-900/90 border border-slate-800 shadow-2xl relative z-10 space-y-6">
        {/* Branding */}
        <div className="text-center space-y-2">
          <div className="w-14 h-14 rounded-2xl gold-gradient flex items-center justify-center mx-auto shadow-lg shadow-amber-500/20 text-3xl">
            🐓
          </div>
          <h1 className="text-2xl font-black text-white">Golden Roost</h1>
          <p className="text-xs text-slate-400 font-medium">Administration & CMS Console</p>
        </div>

        {errorMessage && (
          <div className="p-3 rounded-xl bg-red-950/60 border border-red-800 text-red-300 text-xs flex items-center gap-2">
            <AlertCircle size={15} className="shrink-0 text-red-400" />
            <span>{errorMessage}</span>
          </div>
        )}

        <form onSubmit={handleLogin} className="space-y-4">
          <div>
            <label className="block text-xs font-bold text-slate-300 mb-1.5">
              Admin Email Address
            </label>
            <div className="relative">
              <Mail size={16} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-500" />
              <input
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="admin@goldenroost.com"
                className="w-full pl-10 pr-4 py-2.5 rounded-xl text-xs bg-slate-800/80 border border-slate-700 text-white focus:outline-none focus:border-amber-500 transition-colors"
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-300 mb-1.5">
              Password
            </label>
            <div className="relative">
              <Lock size={16} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-500" />
              <input
                type="password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••••••"
                className="w-full pl-10 pr-4 py-2.5 rounded-xl text-xs bg-slate-800/80 border border-slate-700 text-white focus:outline-none focus:border-amber-500 transition-colors"
              />
            </div>
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full flex items-center justify-center gap-2 py-3 rounded-xl gold-gradient text-slate-950 font-bold text-xs shadow-lg hover:scale-[1.01] active:scale-[0.99] transition-all disabled:opacity-50"
          >
            {loading ? (
              <span>Authenticating Session...</span>
            ) : (
              <>
                <Shield size={14} />
                <span>Sign In to Admin Portal</span>
              </>
            )}
          </button>
        </form>

        <div className="pt-2 text-center text-[11px] text-slate-500">
          <Link href="/" className="hover:text-amber-400 transition-colors">
            ← Return to Public Website
          </Link>
        </div>
      </div>
    </div>
  );
}
