'use client';

import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import { useParams } from 'next/navigation';
import {
  ArrowLeft,
  Calendar,
  Share2,
  Bookmark,
  CheckCircle,
  Tag,
  ShieldAlert,
} from 'lucide-react';
import { Locale } from '@/lib/i18n';
import AdSenseBanner from '@/components/AdSenseBanner';

interface ArticleDetail {
  id: string;
  slug: string;
  title: string;
  summary: string;
  content: string;
  category: string;
  featuredImageUrl: string | null;
  createdAt: string;
  translations: {
    locale: string;
    title: string;
    summary: string;
    content: string;
  }[];
}

function ArticleDetailContent() {
  const params = useParams();
  const slug = params.slug as string;

  const [locale, setLocale] = useState<Locale>('en');
  const [article, setArticle] = useState<ArticleDetail | null>(null);
  const [loading, setLoading] = useState(true);
  const [copied, setCopied] = useState(false);

  useEffect(() => {
    const savedLocale = (localStorage.getItem('gr_locale') as Locale) || 'en';
    setLocale(savedLocale);
    fetchArticle(savedLocale);
  }, [slug]);

  const fetchArticle = async (loc: Locale) => {
    try {
      setLoading(true);
      const res = await fetch(`/api/v1/articles/${slug}?locale=${loc}`).then((r) => r.json());
      if (res.success) {
        setArticle(res.data);
      }
    } catch (err) {
      console.error('Failed to load article:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleLanguageSwitch = (newLocale: Locale) => {
    setLocale(newLocale);
    fetchArticle(newLocale);
  };

  const handleShare = () => {
    if (typeof window !== 'undefined') {
      navigator.clipboard.writeText(window.location.href);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    }
  };

  if (loading) {
    return (
      <div className="max-w-4xl mx-auto px-4 py-20 animate-pulse space-y-6">
        <div className="h-6 w-32 bg-slate-200 dark:bg-slate-800 rounded-lg" />
        <div className="h-12 w-3/4 bg-slate-200 dark:bg-slate-800 rounded-xl" />
        <div className="h-80 bg-slate-200 dark:bg-slate-800 rounded-3xl" />
      </div>
    );
  }

  if (!article) {
    return (
      <div className="max-w-xl mx-auto px-4 py-24 text-center">
        <ShieldAlert size={48} className="mx-auto text-amber-500 mb-4" />
        <h1 className="text-2xl font-black text-slate-900 dark:text-white">Article Not Found</h1>
        <p className="text-xs text-slate-500 mt-2">
          The requested veterinary guide does not exist or may have been unpublished.
        </p>
        <Link
          href="/articles"
          className="mt-6 inline-flex items-center gap-2 px-6 py-3 rounded-xl gold-gradient text-slate-950 font-bold text-xs"
        >
          <ArrowLeft size={14} />
          <span>Back to Articles</span>
        </Link>
      </div>
    );
  }

  return (
    <article className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12 space-y-8">
      {/* Back button & Language Switcher */}
      <div className="flex flex-wrap items-center justify-between gap-4">
        <Link
          href="/articles"
          className="inline-flex items-center gap-1.5 text-xs font-bold text-slate-600 dark:text-slate-400 hover:text-amber-500 transition-colors"
        >
          <ArrowLeft size={14} />
          <span>All Veterinary Guides</span>
        </Link>

        {/* Trilingual Switcher */}
        <div className="flex items-center gap-1 p-1 rounded-xl bg-slate-100 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-xs font-bold">
          <span className="text-[10px] text-slate-400 px-2 uppercase">Language:</span>
          {(['en', 'fr', 'ar'] as Locale[]).map((l) => (
            <button
              key={l}
              onClick={() => handleLanguageSwitch(l)}
              className={`px-2.5 py-1 rounded-lg uppercase transition-all ${
                locale === l
                  ? 'bg-white dark:bg-slate-700 text-amber-600 dark:text-amber-400 shadow-sm'
                  : 'text-slate-600 dark:text-slate-400 hover:text-slate-900'
              }`}
            >
              {l === 'ar' ? 'العربية' : l}
            </button>
          ))}
        </div>
      </div>

      {/* Header Info */}
      <header className="space-y-4">
        <div className="flex items-center gap-3">
          <span className="px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wider bg-amber-100 dark:bg-amber-950/60 text-amber-800 dark:text-amber-400">
            {article.category.replace('_', ' ')}
          </span>
          <span className="flex items-center gap-1 text-xs text-slate-400">
            <Calendar size={13} />
            <span>{new Date(article.createdAt).toLocaleDateString()}</span>
          </span>
        </div>

        <h1 className="text-3xl sm:text-5xl font-black tracking-tight text-slate-900 dark:text-white leading-[1.2]">
          {article.title}
        </h1>

        <p className="text-base sm:text-lg text-slate-600 dark:text-slate-300 leading-relaxed font-medium bg-slate-50 dark:bg-slate-900/60 p-4 rounded-2xl border-l-4 border-amber-500">
          {article.summary}
        </p>
      </header>

      {/* Featured Image */}
      {article.featuredImageUrl && (
        <div className="rounded-3xl overflow-hidden shadow-md max-h-[440px] w-full bg-slate-100 dark:bg-slate-800">
          <img
            src={article.featuredImageUrl}
            alt={article.title}
            className="w-full h-full object-cover"
          />
        </div>
      )}

      {/* Main Content Body */}
      <div className="prose dark:prose-invert max-w-none text-slate-800 dark:text-slate-200 leading-relaxed text-sm sm:text-base space-y-4 whitespace-pre-line">
        {article.content}
      </div>

      {/* AdSense Placement */}
      <AdSenseBanner slot="article-mid-banner" />

      {/* Footer Actions & Share */}
      <div className="pt-8 border-t border-slate-200 dark:border-slate-800 flex flex-wrap items-center justify-between gap-4">
        <button
          onClick={handleShare}
          className="inline-flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-bold border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-900 text-slate-700 dark:text-slate-300 hover:border-amber-500 transition-colors"
        >
          {copied ? (
            <>
              <CheckCircle size={14} className="text-emerald-500" />
              <span>Link Copied!</span>
            </>
          ) : (
            <>
              <Share2 size={14} />
              <span>Share Guide</span>
            </>
          )}
        </button>

        <Link
          href="https://play.google.com/store/apps/details?id=com.goldenroost.app"
          target="_blank"
          rel="noopener noreferrer"
          className="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl gold-gradient text-slate-950 font-black text-xs shadow-md hover:scale-105 transition-transform"
        >
          <span>Track this in Golden Roost App</span>
        </Link>
      </div>
    </article>
  );
}

export default function ArticleDetailPage() {
  return (
    <React.Suspense
      fallback={
        <div className="max-w-4xl mx-auto px-4 py-20 text-center text-xs text-slate-500">
          Loading article...
        </div>
      }
    >
      <ArticleDetailContent />
    </React.Suspense>
  );
}
