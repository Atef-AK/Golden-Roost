'use client';

import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import { BookOpen, Search, ArrowRight, Filter } from 'lucide-react';
import { Locale, translations } from '@/lib/i18n';
import AdSenseBanner from '@/components/AdSenseBanner';

interface ArticleItem {
  id: string;
  slug: string;
  title: string;
  summary: string;
  category: string;
  featuredImageUrl: string | null;
  createdAt: string;
}

const CATEGORIES = [
  { id: 'all', label: 'All Guides' },
  { id: 'disease_guide', label: 'Disease & Biosecurity' },
  { id: 'housing', label: 'Housing & Ventilation' },
  { id: 'incubation', label: 'Incubation & Candling' },
  { id: 'nutrition', label: 'Nutrition & Feed' },
  { id: 'general', label: 'General Management' },
];

export default function ArticlesPage() {
  const [locale, setLocale] = useState<Locale>('en');
  const [articles, setArticles] = useState<ArticleItem[]>([]);
  const [filteredArticles, setFilteredArticles] = useState<ArticleItem[]>([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('all');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const updateLocale = () => {
      const savedLocale = (localStorage.getItem('gr_locale') as Locale) || 'en';
      setLocale(savedLocale);
      loadArticles(savedLocale);
    };
    updateLocale();
    window.addEventListener('gr-locale-change', updateLocale);
    return () => window.removeEventListener('gr-locale-change', updateLocale);
  }, []);

  const loadArticles = async (loc: Locale) => {
    try {
      setLoading(true);
      const res = await fetch(`/api/v1/articles?locale=${loc}`).then((r) => r.json());
      if (res.success) {
        setArticles(res.data);
        setFilteredArticles(res.data);
      }
    } catch (err) {
      console.error('Failed to load articles:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    let result = articles;
    if (selectedCategory !== 'all') {
      result = result.filter((a) => a.category === selectedCategory);
    }
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase();
      result = result.filter(
        (a) => a.title.toLowerCase().includes(q) || a.summary.toLowerCase().includes(q)
      );
    }
    setFilteredArticles(result);
  }, [searchQuery, selectedCategory, articles]);

  const t = translations[locale];

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12 space-y-10">
      {/* Page Header */}
      <div className="text-center max-w-3xl mx-auto">
        <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-amber-500/10 text-amber-600 dark:text-amber-400 text-xs font-bold uppercase mb-4">
          <BookOpen size={14} />
          <span>Poultry Knowledge Base</span>
        </div>
        <h1 className="text-3xl sm:text-5xl font-black text-slate-900 dark:text-white">
          Veterinary Guides & Flock Protocols
        </h1>
        <p className="mt-3 text-sm sm:text-base text-slate-600 dark:text-slate-400">
          Peer-reviewed medical guides, incubation schedules, biosecurity protocols, and feed
          formulation strategies for commercial producers and smallholders.
        </p>
      </div>

      {/* Filter and Search Bar */}
      <div className="flex flex-col md:flex-row items-center justify-between gap-4 p-4 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 shadow-sm">
        {/* Category Pills */}
        <div className="flex items-center gap-1.5 overflow-x-auto w-full md:w-auto pb-2 md:pb-0">
          {CATEGORIES.map((cat) => (
            <button
              key={cat.id}
              onClick={() => setSelectedCategory(cat.id)}
              className={`px-3 py-1.5 rounded-xl text-xs font-bold whitespace-nowrap transition-all ${
                selectedCategory === cat.id
                  ? 'bg-amber-500 text-slate-950 shadow-sm'
                  : 'text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800'
              }`}
            >
              {cat.label}
            </button>
          ))}
        </div>

        {/* Search Input */}
        <div className="relative w-full md:w-72">
          <Search size={16} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" />
          <input
            type="text"
            placeholder="Search articles..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-10 pr-4 py-2 rounded-xl text-xs bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white focus:outline-none focus:border-amber-500"
          />
        </div>
      </div>

      {/* Articles Grid */}
      {loading ? (
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 animate-pulse">
          {[1, 2, 3, 4, 5, 6].map((i) => (
            <div key={i} className="h-72 rounded-3xl bg-slate-200 dark:bg-slate-800" />
          ))}
        </div>
      ) : filteredArticles.length > 0 ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredArticles.map((art) => (
            <article
              key={art.id}
              className="group flex flex-col rounded-3xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 overflow-hidden shadow-sm hover:shadow-lg transition-all"
            >
              {art.featuredImageUrl && (
                <div className="h-48 w-full overflow-hidden bg-slate-100 dark:bg-slate-800">
                  <img
                    src={art.featuredImageUrl}
                    alt={art.title}
                    className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                  />
                </div>
              )}
              <div className="p-6 flex-1 flex flex-col">
                <span className="inline-block px-2.5 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wider bg-amber-100 dark:bg-amber-950/60 text-amber-800 dark:text-amber-400 mb-3 w-fit">
                  {art.category.replace('_', ' ')}
                </span>
                <h2 className="text-lg font-bold text-slate-900 dark:text-white mb-2 line-clamp-2 group-hover:text-amber-500 transition-colors">
                  <Link href={`/articles/${art.slug}`}>{art.title}</Link>
                </h2>
                <p className="text-xs text-slate-600 dark:text-slate-400 line-clamp-3 mb-6 flex-1 leading-relaxed">
                  {art.summary}
                </p>
                <div className="pt-4 border-t border-slate-100 dark:border-slate-800 flex items-center justify-between">
                  <span className="text-[11px] text-slate-400">
                    {new Date(art.createdAt).toLocaleDateString()}
                  </span>
                  <Link
                    href={`/articles/${art.slug}`}
                    className="inline-flex items-center gap-1 text-xs font-bold text-amber-600 dark:text-amber-400 hover:text-amber-500"
                  >
                    <span>Read Article</span>
                    <ArrowRight size={13} />
                  </Link>
                </div>
              </div>
            </article>
          ))}
        </div>
      ) : (
        <div className="text-center py-16 bg-white dark:bg-slate-900 rounded-3xl border border-slate-200 dark:border-slate-800">
          <BookOpen size={36} className="mx-auto text-slate-400 mb-3" />
          <h3 className="text-base font-bold text-slate-800 dark:text-slate-200">
            No matching articles found
          </h3>
          <p className="text-xs text-slate-500 mt-1">
            Try adjusting your search query or selected category.
          </p>
        </div>
      )}

      {/* AdSense Placement */}
      <AdSenseBanner slot="articles-footer-banner" />
    </div>
  );
}
