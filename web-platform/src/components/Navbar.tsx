'use client';

import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { Globe, Moon, Sun, Menu, X, Shield, BookOpen, ShoppingBag, Home, Phone, Info } from 'lucide-react';
import { Locale, translations } from '@/lib/i18n';

export default function Navbar() {
  const pathname = usePathname();
  const [locale, setLocale] = useState<Locale>('en');
  const [theme, setTheme] = useState<'light' | 'dark'>('light');
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  useEffect(() => {
    // Read persisted locale & theme from localStorage
    const savedLocale = (localStorage.getItem('gr_locale') as Locale) || 'en';
    const savedTheme = (localStorage.getItem('gr_theme') as 'light' | 'dark') || 'light';
    setLocale(savedLocale);
    setTheme(savedTheme);
    document.documentElement.setAttribute('data-theme', savedTheme);
    document.documentElement.setAttribute('dir', savedLocale === 'ar' ? 'rtl' : 'ltr');
    document.documentElement.setAttribute('lang', savedLocale);
  }, []);

  const handleLocaleChange = (newLocale: Locale) => {
    setLocale(newLocale);
    localStorage.setItem('gr_locale', newLocale);
    document.documentElement.setAttribute('dir', newLocale === 'ar' ? 'rtl' : 'ltr');
    document.documentElement.setAttribute('lang', newLocale);
    // Reload or dispatch event if needed
    window.dispatchEvent(new Event('gr-locale-change'));
  };

  const toggleTheme = () => {
    const nextTheme = theme === 'light' ? 'dark' : 'light';
    setTheme(nextTheme);
    localStorage.setItem('gr_theme', nextTheme);
    document.documentElement.setAttribute('data-theme', nextTheme);
  };

  const t = translations[locale];

  if (pathname.startsWith('/admin')) {
    return null;
  }

  return (
    <header className="sticky top-0 z-50 glass-nav transition-colors duration-200">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-20">
          {/* Logo & Branding */}
          <Link href="/" className="flex items-center gap-3 group">
            <div className="w-11 h-11 rounded-2xl gold-gradient flex items-center justify-center shadow-lg shadow-amber-500/20 group-hover:scale-105 transition-transform duration-200">
              <span className="text-2xl font-black text-slate-950">🐓</span>
            </div>
            <div>
              <span className="text-2xl font-black tracking-tight text-slate-900 dark:text-white flex items-center gap-1.5">
                Golden <span className="text-amber-500">Roost</span>
              </span>
              <p className="text-xs text-slate-500 dark:text-slate-400 font-medium hidden sm:block">
                Smart Poultry Farm Platform
              </p>
            </div>
          </Link>

          {/* Desktop Navigation Links */}
          <nav className="hidden md:flex items-center gap-8">
            <Link
              href="/"
              className={`text-sm font-semibold transition-colors ${
                pathname === '/'
                  ? 'text-amber-600 dark:text-amber-400'
                  : 'text-slate-700 dark:text-slate-200 hover:text-amber-500'
              }`}
            >
              {t.navHome}
            </Link>
            <Link
              href="/articles"
              className={`text-sm font-semibold transition-colors ${
                pathname.startsWith('/articles')
                  ? 'text-amber-600 dark:text-amber-400'
                  : 'text-slate-700 dark:text-slate-200 hover:text-amber-500'
              }`}
            >
              {t.navArticles}
            </Link>
            <Link
              href="/products"
              className={`text-sm font-semibold transition-colors ${
                pathname.startsWith('/products')
                  ? 'text-amber-600 dark:text-amber-400'
                  : 'text-slate-700 dark:text-slate-200 hover:text-amber-500'
              }`}
            >
              {t.navProducts}
            </Link>
            <Link
              href="/about"
              className={`text-sm font-semibold transition-colors ${
                pathname === '/about'
                  ? 'text-amber-600 dark:text-amber-400'
                  : 'text-slate-700 dark:text-slate-200 hover:text-amber-500'
              }`}
            >
              {t.navAbout}
            </Link>
            <Link
              href="/contact"
              className={`text-sm font-semibold transition-colors ${
                pathname === '/contact'
                  ? 'text-amber-600 dark:text-amber-400'
                  : 'text-slate-700 dark:text-slate-200 hover:text-amber-500'
              }`}
            >
              {t.navContact}
            </Link>
          </nav>

          {/* Controls: Language, Theme, Admin Portal */}
          <div className="hidden md:flex items-center gap-4">
            {/* Language Selector */}
            <div className="flex items-center bg-slate-100 dark:bg-slate-800 rounded-xl p-1 border border-slate-200 dark:border-slate-700 text-xs font-semibold">
              <button
                onClick={() => handleLocaleChange('en')}
                className={`px-2.5 py-1 rounded-lg transition-all ${
                  locale === 'en'
                    ? 'bg-white dark:bg-slate-700 text-amber-600 dark:text-amber-400 shadow-sm'
                    : 'text-slate-600 dark:text-slate-400 hover:text-slate-900'
                }`}
              >
                EN
              </button>
              <button
                onClick={() => handleLocaleChange('fr')}
                className={`px-2.5 py-1 rounded-lg transition-all ${
                  locale === 'fr'
                    ? 'bg-white dark:bg-slate-700 text-amber-600 dark:text-amber-400 shadow-sm'
                    : 'text-slate-600 dark:text-slate-400 hover:text-slate-900'
                }`}
              >
                FR
              </button>
              <button
                onClick={() => handleLocaleChange('ar')}
                className={`px-2.5 py-1 rounded-lg transition-all ${
                  locale === 'ar'
                    ? 'bg-white dark:bg-slate-700 text-amber-600 dark:text-amber-400 shadow-sm'
                    : 'text-slate-600 dark:text-slate-400 hover:text-slate-900'
                }`}
              >
                العربية
              </button>
            </div>

            {/* Dark / Light Toggle */}
            <button
              onClick={toggleTheme}
              aria-label="Toggle Theme"
              className="p-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-700 dark:text-slate-300 hover:border-amber-500 transition-colors"
            >
              {theme === 'light' ? <Moon size={18} /> : <Sun size={18} className="text-amber-400" />}
            </button>

            {/* Admin Portal Button */}
            <Link
              href="/admin/login"
              className="flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-bold bg-slate-900 dark:bg-slate-800 text-white hover:bg-amber-600 dark:hover:bg-amber-600 transition-colors shadow-sm"
            >
              <Shield size={14} className="text-amber-400" />
              <span>{t.navAdmin}</span>
            </Link>
          </div>

          {/* Mobile Menu Button */}
          <div className="md:hidden flex items-center gap-2">
            <button
              onClick={toggleTheme}
              aria-label="Toggle Theme"
              className="p-2 rounded-lg border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-700 dark:text-slate-300"
            >
              {theme === 'light' ? <Moon size={18} /> : <Sun size={18} className="text-amber-400" />}
            </button>
            <button
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="p-2 rounded-lg border border-slate-200 dark:border-slate-700 text-slate-700 dark:text-slate-300"
            >
              {mobileMenuOpen ? <X size={22} /> : <Menu size={22} />}
            </button>
          </div>
        </div>
      </div>

      {/* Mobile Drawer */}
      {mobileMenuOpen && (
        <div className="md:hidden border-t border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 px-4 pt-4 pb-6 space-y-4">
          <nav className="flex flex-col space-y-3">
            <Link
              href="/"
              onClick={() => setMobileMenuOpen(false)}
              className="flex items-center gap-3 p-2 rounded-lg font-medium text-slate-700 dark:text-slate-200 hover:bg-slate-50 dark:hover:bg-slate-800"
            >
              <Home size={18} />
              <span>{t.navHome}</span>
            </Link>
            <Link
              href="/articles"
              onClick={() => setMobileMenuOpen(false)}
              className="flex items-center gap-3 p-2 rounded-lg font-medium text-slate-700 dark:text-slate-200 hover:bg-slate-50 dark:hover:bg-slate-800"
            >
              <BookOpen size={18} />
              <span>{t.navArticles}</span>
            </Link>
            <Link
              href="/products"
              onClick={() => setMobileMenuOpen(false)}
              className="flex items-center gap-3 p-2 rounded-lg font-medium text-slate-700 dark:text-slate-200 hover:bg-slate-50 dark:hover:bg-slate-800"
            >
              <ShoppingBag size={18} />
              <span>{t.navProducts}</span>
            </Link>
            <Link
              href="/about"
              onClick={() => setMobileMenuOpen(false)}
              className="flex items-center gap-3 p-2 rounded-lg font-medium text-slate-700 dark:text-slate-200 hover:bg-slate-50 dark:hover:bg-slate-800"
            >
              <Info size={18} />
              <span>{t.navAbout}</span>
            </Link>
            <Link
              href="/contact"
              onClick={() => setMobileMenuOpen(false)}
              className="flex items-center gap-3 p-2 rounded-lg font-medium text-slate-700 dark:text-slate-200 hover:bg-slate-50 dark:hover:bg-slate-800"
            >
              <Phone size={18} />
              <span>{t.navContact}</span>
            </Link>
            <Link
              href="/admin/login"
              onClick={() => setMobileMenuOpen(false)}
              className="flex items-center gap-3 p-2 rounded-lg font-medium text-amber-600 dark:text-amber-400 hover:bg-amber-50 dark:hover:bg-amber-950/30"
            >
              <Shield size={18} />
              <span>{t.navAdmin}</span>
            </Link>
          </nav>

          {/* Mobile Language Selector */}
          <div className="flex items-center justify-around pt-3 border-t border-slate-100 dark:border-slate-800">
            <button
              onClick={() => handleLocaleChange('en')}
              className={`px-3 py-1.5 rounded-lg text-sm font-semibold ${
                locale === 'en'
                  ? 'bg-amber-500 text-white'
                  : 'text-slate-600 dark:text-slate-400'
              }`}
            >
              English
            </button>
            <button
              onClick={() => handleLocaleChange('fr')}
              className={`px-3 py-1.5 rounded-lg text-sm font-semibold ${
                locale === 'fr'
                  ? 'bg-amber-500 text-white'
                  : 'text-slate-600 dark:text-slate-400'
              }`}
            >
              Français
            </button>
            <button
              onClick={() => handleLocaleChange('ar')}
              className={`px-3 py-1.5 rounded-lg text-sm font-semibold ${
                locale === 'ar'
                  ? 'bg-amber-500 text-white'
                  : 'text-slate-600 dark:text-slate-400'
              }`}
            >
              العربية
            </button>
          </div>
        </div>
      )}
    </header>
  );
}
