'use client';

import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import {
  LayoutDashboard,
  FileText,
  ShoppingBag,
  Bell,
  Sliders,
  ShieldAlert,
  LogOut,
  User,
  ExternalLink,
  Menu,
  X,
} from 'lucide-react';
import { getClientAuth } from '@/lib/firebase-client';
import { signOut } from 'firebase/auth';

interface AdminProfile {
  id: string;
  email: string;
  role: 'superadmin' | 'editor' | 'viewer';
  displayName: string | null;
}

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const [admin, setAdmin] = useState<AdminProfile | null>(null);
  const [loading, setLoading] = useState(true);
  const [sidebarOpen, setSidebarOpen] = useState(false);

  // If on /admin/login, bypass the authenticated layout wrapper
  const isLoginPage = pathname === '/admin/login';

  useEffect(() => {
    if (isLoginPage) {
      setLoading(false);
      return;
    }

    fetch('/api/v1/admin/auth/me')
      .then((res) => {
        if (!res.ok) throw new Error('Unauthenticated');
        return res.json();
      })
      .then((data) => {
        if (data.user) {
          setAdmin(data.user);
        } else {
          router.push('/admin/login');
        }
      })
      .catch(() => {
        router.push('/admin/login');
      })
      .finally(() => {
        setLoading(false);
      });
  }, [pathname, isLoginPage, router]);

  const handleSignOut = async () => {
    try {
      await fetch('/api/v1/admin/auth/session', { method: 'DELETE' });
      const auth = getClientAuth();
      await signOut(auth);
    } catch (e) {
      console.warn('Sign-out error:', e);
    } finally {
      router.push('/admin/login');
    }
  };

  if (isLoginPage) {
    return <>{children}</>;
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-slate-950 flex items-center justify-center text-slate-400 text-xs font-semibold">
        Verifying administrator authorization...
      </div>
    );
  }

  const navItems = [
    { href: '/admin', label: 'Overview', icon: LayoutDashboard },
    { href: '/admin/articles', label: 'Articles CMS', icon: FileText },
    { href: '/admin/products', label: 'Products CMS', icon: ShoppingBag },
    { href: '/admin/notifications', label: 'Push Notifications', icon: Bell },
    { href: '/admin/settings', label: 'Monetization Settings', icon: Sliders },
    { href: '/admin/audit-logs', label: 'Audit Logs', icon: ShieldAlert },
  ];

  return (
    <div className="min-h-screen bg-slate-950 text-slate-100 flex flex-col md:flex-row">
      {/* Mobile Header */}
      <div className="md:hidden flex items-center justify-between p-4 bg-slate-900 border-b border-slate-800">
        <Link href="/admin" className="flex items-center gap-2">
          <span className="text-xl">🐓</span>
          <span className="font-black text-sm">Golden Roost Admin</span>
        </Link>
        <button
          onClick={() => setSidebarOpen(!sidebarOpen)}
          className="p-2 rounded-lg bg-slate-800 text-slate-300"
        >
          {sidebarOpen ? <X size={20} /> : <Menu size={20} />}
        </button>
      </div>

      {/* Sidebar */}
      <aside
        className={`fixed md:static inset-y-0 left-0 z-50 w-64 bg-slate-900 border-r border-slate-800 flex flex-col justify-between p-4 transition-transform duration-200 ${
          sidebarOpen ? 'translate-x-0' : '-translate-x-full md:translate-x-0'
        }`}
      >
        <div className="space-y-6">
          {/* Logo */}
          <div className="flex items-center justify-between">
            <Link href="/admin" className="flex items-center gap-2.5">
              <div className="w-10 h-10 rounded-xl gold-gradient flex items-center justify-center text-xl font-bold text-slate-950 shadow-md shadow-amber-500/20">
                🐓
              </div>
              <div>
                <span className="font-black text-sm text-white block">Golden Roost</span>
                <span className="text-[10px] text-amber-400 font-bold uppercase tracking-wider block">
                  Admin Console
                </span>
              </div>
            </Link>
            <button
              onClick={() => setSidebarOpen(false)}
              className="md:hidden text-slate-400 hover:text-white"
            >
              <X size={18} />
            </button>
          </div>

          {/* Current Admin Identity */}
          {admin && (
            <div className="p-3 rounded-2xl bg-slate-800/60 border border-slate-800 space-y-1">
              <div className="flex items-center justify-between">
                <span className="text-xs font-bold text-white truncate max-w-[130px]">
                  {admin.displayName || admin.email.split('@')[0]}
                </span>
                <span
                  className={`px-2 py-0.5 rounded-full text-[9px] font-black uppercase tracking-wider ${
                    admin.role === 'superadmin'
                      ? 'bg-amber-500 text-slate-950'
                      : admin.role === 'editor'
                      ? 'bg-emerald-500 text-slate-950'
                      : 'bg-slate-700 text-slate-300'
                  }`}
                >
                  {admin.role}
                </span>
              </div>
              <p className="text-[10px] text-slate-400 truncate">{admin.email}</p>
            </div>
          )}

          {/* Navigation Links */}
          <nav className="space-y-1">
            {navItems.map((item) => {
              const Icon = item.icon;
              const isActive =
                item.href === '/admin'
                  ? pathname === '/admin'
                  : pathname.startsWith(item.href);

              return (
                <Link
                  key={item.href}
                  href={item.href}
                  onClick={() => setSidebarOpen(false)}
                  className={`flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-semibold transition-colors ${
                    isActive
                      ? 'bg-amber-500 text-slate-950 font-bold shadow-md shadow-amber-500/20'
                      : 'text-slate-400 hover:text-white hover:bg-slate-800/60'
                  }`}
                >
                  <Icon size={16} />
                  <span>{item.label}</span>
                </Link>
              );
            })}
          </nav>
        </div>

        {/* Bottom Actions */}
        <div className="pt-4 border-t border-slate-800 space-y-2">
          <Link
            href="/"
            target="_blank"
            className="flex items-center justify-between px-3 py-2 rounded-xl text-xs text-slate-400 hover:text-amber-400 hover:bg-slate-800/40 transition-colors"
          >
            <span>View Public Website</span>
            <ExternalLink size={13} />
          </Link>
          <button
            onClick={handleSignOut}
            className="w-full flex items-center gap-2 px-3 py-2 rounded-xl text-xs font-semibold text-red-400 hover:text-red-300 hover:bg-red-950/30 transition-colors"
          >
            <LogOut size={15} />
            <span>Sign Out</span>
          </button>
        </div>
      </aside>

      {/* Main Admin Content Canvas */}
      <main className="flex-1 p-6 md:p-10 max-w-7xl overflow-y-auto">{children}</main>
    </div>
  );
}
