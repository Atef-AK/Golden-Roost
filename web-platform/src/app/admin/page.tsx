'use client';

import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import {
  FileText,
  ShoppingBag,
  Bell,
  Smartphone,
  Plus,
  ArrowRight,
  TrendingUp,
  ShieldCheck,
  Activity,
} from 'lucide-react';

export default function AdminDashboardPage() {
  const [stats, setStats] = useState({
    articlesCount: 0,
    productsCount: 0,
    devicesCount: 0,
    campaignsCount: 0,
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    Promise.all([
      fetch('/api/v1/articles?include_drafts=true').then((r) => r.json()),
      fetch('/api/v1/products?include_unpublished=true').then((r) => r.json()),
      fetch('/api/v1/admin/notifications/campaigns').then((r) => r.json()),
    ])
      .then(([artRes, prodRes, notifRes]) => {
        setStats({
          articlesCount: artRes.count || 0,
          productsCount: prodRes.count || 0,
          devicesCount: notifRes.totalActiveDevices || 0,
          campaignsCount: notifRes.data?.length || 0,
        });
      })
      .catch((err) => {
        console.error('Failed to load admin stats:', err);
      })
      .finally(() => {
        setLoading(false);
      });
  }, []);

  return (
    <div className="space-y-8">
      {/* Top Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-2xl sm:text-3xl font-black text-white">Operations Dashboard</h1>
          <p className="text-xs text-slate-400 mt-1">
            Real-time status of CMS content, affiliate equipment, and mobile push subscriptions.
          </p>
        </div>

        <div className="flex items-center gap-3">
          <Link
            href="/admin/articles"
            className="flex items-center gap-1.5 px-4 py-2 rounded-xl text-xs font-bold gold-gradient text-slate-950 shadow-md hover:scale-105 transition-all"
          >
            <Plus size={14} />
            <span>New Article</span>
          </Link>
          <Link
            href="/admin/notifications"
            className="flex items-center gap-1.5 px-4 py-2 rounded-xl text-xs font-bold bg-amber-500/20 text-amber-400 border border-amber-500/30 hover:bg-amber-500/30 transition-all"
          >
            <Bell size={14} />
            <span>Send Push Alert</span>
          </Link>
        </div>
      </div>

      {/* KPI Stats Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        <div className="p-6 rounded-3xl bg-slate-900 border border-slate-800 space-y-2">
          <div className="flex items-center justify-between text-slate-400">
            <span className="text-xs font-bold uppercase tracking-wider">Veterinary Guides</span>
            <FileText size={18} className="text-amber-500" />
          </div>
          <span className="block text-3xl font-black text-white">
            {loading ? '...' : stats.articlesCount}
          </span>
          <span className="text-[11px] text-slate-500 block">Published and draft articles</span>
        </div>

        <div className="p-6 rounded-3xl bg-slate-900 border border-slate-800 space-y-2">
          <div className="flex items-center justify-between text-slate-400">
            <span className="text-xs font-bold uppercase tracking-wider">Catalogue Products</span>
            <ShoppingBag size={18} className="text-emerald-500" />
          </div>
          <span className="block text-3xl font-black text-white">
            {loading ? '...' : stats.productsCount}
          </span>
          <span className="text-[11px] text-slate-500 block">Affiliate equipment listings</span>
        </div>

        <div className="p-6 rounded-3xl bg-slate-900 border border-slate-800 space-y-2">
          <div className="flex items-center justify-between text-slate-400">
            <span className="text-xs font-bold uppercase tracking-wider">Push Devices</span>
            <Smartphone size={18} className="text-amber-400" />
          </div>
          <span className="block text-3xl font-black text-white">
            {loading ? '...' : stats.devicesCount}
          </span>
          <span className="text-[11px] text-slate-500 block">Active Android FCM tokens</span>
        </div>

        <div className="p-6 rounded-3xl bg-slate-900 border border-slate-800 space-y-2">
          <div className="flex items-center justify-between text-slate-400">
            <span className="text-xs font-bold uppercase tracking-wider">Push Campaigns</span>
            <Bell size={18} className="text-emerald-400" />
          </div>
          <span className="block text-3xl font-black text-white">
            {loading ? '...' : stats.campaignsCount}
          </span>
          <span className="text-[11px] text-slate-500 block">Total broadcasts dispatched</span>
        </div>
      </div>

      {/* Quick Access Tiles */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Link
          href="/admin/articles"
          className="p-6 rounded-3xl bg-slate-900/60 border border-slate-800 hover:border-amber-500/50 hover:bg-slate-900 transition-all group flex flex-col justify-between"
        >
          <div>
            <div className="w-10 h-10 rounded-xl bg-amber-500/10 text-amber-500 flex items-center justify-center mb-4">
              <FileText size={20} />
            </div>
            <h2 className="text-base font-bold text-white mb-1">Knowledge Base CMS</h2>
            <p className="text-xs text-slate-400 leading-relaxed">
              Create, edit, and translate disease guides, incubation schedules, and housing protocols
              in English, French, and Arabic.
            </p>
          </div>
          <span className="mt-4 inline-flex items-center gap-1 text-xs font-bold text-amber-400 group-hover:translate-x-1 transition-transform">
            <span>Manage Articles</span>
            <ArrowRight size={13} />
          </span>
        </Link>

        <Link
          href="/admin/products"
          className="p-6 rounded-3xl bg-slate-900/60 border border-slate-800 hover:border-emerald-500/50 hover:bg-slate-900 transition-all group flex flex-col justify-between"
        >
          <div>
            <div className="w-10 h-10 rounded-xl bg-emerald-500/10 text-emerald-500 flex items-center justify-center mb-4">
              <ShoppingBag size={20} />
            </div>
            <h2 className="text-base font-bold text-white mb-1">Affiliate Equipment</h2>
            <p className="text-xs text-slate-400 leading-relaxed">
              Manage affiliate retailer URLs for brooders, automated drinkers, egg candlers, and
              incubators.
            </p>
          </div>
          <span className="mt-4 inline-flex items-center gap-1 text-xs font-bold text-emerald-400 group-hover:translate-x-1 transition-transform">
            <span>Manage Products</span>
            <ArrowRight size={13} />
          </span>
        </Link>

        <Link
          href="/admin/notifications"
          className="p-6 rounded-3xl bg-slate-900/60 border border-slate-800 hover:border-amber-500/50 hover:bg-slate-900 transition-all group flex flex-col justify-between"
        >
          <div>
            <div className="w-10 h-10 rounded-xl bg-amber-500/10 text-amber-500 flex items-center justify-center mb-4">
              <Bell size={20} />
            </div>
            <h2 className="text-base font-bold text-white mb-1">FCM Broadcasts</h2>
            <p className="text-xs text-slate-400 leading-relaxed">
              Dispatch push notifications directly to installed Android farm devices with biosecurity
              alerts or app feature updates.
            </p>
          </div>
          <span className="mt-4 inline-flex items-center gap-1 text-xs font-bold text-amber-400 group-hover:translate-x-1 transition-transform">
            <span>Compose Broadcast</span>
            <ArrowRight size={13} />
          </span>
        </Link>
      </div>
    </div>
  );
}
