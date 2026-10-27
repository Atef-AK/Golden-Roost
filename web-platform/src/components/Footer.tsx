'use client';

import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { Locale, translations } from '@/lib/i18n';
import { ShieldCheck, Mail, Heart } from 'lucide-react';

export default function Footer() {
  const pathname = usePathname();
  const [locale, setLocale] = useState<Locale>('en');

  useEffect(() => {
    const updateLocale = () => {
      const savedLocale = (localStorage.getItem('gr_locale') as Locale) || 'en';
      setLocale(savedLocale);
    };
    updateLocale();
    window.addEventListener('gr-locale-change', updateLocale);
    return () => window.removeEventListener('gr-locale-change', updateLocale);
  }, []);

  if (pathname.startsWith('/admin')) {
    return null;
  }

  const t = translations[locale];

  return (
    <footer className="bg-slate-900 text-slate-300 border-t border-slate-800 transition-colors">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-14">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-10">
          {/* Brand Info */}
          <div className="md:col-span-1 space-y-4">
            <Link href="/" className="flex items-center gap-2.5">
              <div className="w-9 h-9 rounded-xl gold-gradient flex items-center justify-center font-bold text-slate-950">
                🐓
              </div>
              <span className="text-xl font-black text-white">
                Golden <span className="text-amber-400">Roost</span>
              </span>
            </Link>
            <p className="text-xs text-slate-400 leading-relaxed">
              {t.brandTagline}
            </p>
            <div className="pt-2 text-xs text-slate-500">
              Package ID: <code className="text-amber-400/80">com.goldenroost.app</code>
            </div>
          </div>

          {/* Quick Navigation */}
          <div>
            <h3 className="text-sm font-bold text-white tracking-wider uppercase mb-4">
              Platform
            </h3>
            <ul className="space-y-2.5 text-xs font-medium">
              <li>
                <Link href="/" className="hover:text-amber-400 transition-colors">
                  {t.navHome}
                </Link>
              </li>
              <li>
                <Link href="/articles" className="hover:text-amber-400 transition-colors">
                  {t.navArticles}
                </Link>
              </li>
              <li>
                <Link href="/products" className="hover:text-amber-400 transition-colors">
                  {t.navProducts}
                </Link>
              </li>
              <li>
                <Link href="/about" className="hover:text-amber-400 transition-colors">
                  {t.navAbout}
                </Link>
              </li>
              <li>
                <Link href="/contact" className="hover:text-amber-400 transition-colors">
                  {t.navContact}
                </Link>
              </li>
            </ul>
          </div>

          {/* Compliance & Legal */}
          <div>
            <h3 className="text-sm font-bold text-white tracking-wider uppercase mb-4 flex items-center gap-2">
              <ShieldCheck size={16} className="text-emerald-400" />
              <span>Legal & Privacy</span>
            </h3>
            <ul className="space-y-2.5 text-xs font-medium">
              <li>
                <Link href="/privacy" className="hover:text-amber-400 transition-colors">
                  {t.privacyPolicy}
                </Link>
              </li>
              <li>
                <Link
                  href="/delete-account"
                  className="hover:text-red-400 text-slate-400 transition-colors flex items-center gap-1.5"
                >
                  <span className="w-1.5 h-1.5 rounded-full bg-red-500"></span>
                  <span>{t.deleteAccount}</span>
                </Link>
              </li>
              <li>
                <Link href="/admin/login" className="hover:text-amber-400 transition-colors">
                  {t.navAdmin}
                </Link>
              </li>
            </ul>
          </div>

          {/* Direct Support */}
          <div>
            <h3 className="text-sm font-bold text-white tracking-wider uppercase mb-4">
              Support
            </h3>
            <p className="text-xs text-slate-400 mb-3">
              Need assistance with our mobile application or farm data management?
            </p>
            <a
              href="mailto:support@goldenroost.com"
              className="inline-flex items-center gap-2 text-xs font-semibold text-amber-400 hover:text-amber-300 transition-colors"
            >
              <Mail size={14} />
              <span>support@goldenroost.com</span>
            </a>
          </div>
        </div>

        {/* Commercial & Affiliate Disclosure */}
        <div className="mt-12 pt-6 border-t border-slate-800 text-xs text-slate-500 leading-relaxed">
          <p>{t.affiliateNotice}</p>
        </div>

        {/* Copyright */}
        <div className="mt-6 flex flex-col sm:flex-row justify-between items-center text-xs text-slate-500 gap-2">
          <p>
            © 2026 Golden Roost. {t.footerRights}
          </p>
          <p className="flex items-center gap-1">
            Built with modern precision for poultry farmers worldwide.
          </p>
        </div>
      </div>
    </footer>
  );
}
