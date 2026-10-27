'use client';

import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import {
  Download,
  BookOpen,
  ShoppingBag,
  CheckCircle2,
  TrendingUp,
  Cpu,
  Layers,
  Sparkles,
  ArrowRight,
  ShieldAlert,
  Flame,
  Star,
} from 'lucide-react';
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

interface ProductItem {
  id: string;
  slug: string;
  name: string;
  description: string;
  category: string;
  priceDisplay: string | null;
  imageUrl: string | null;
  affiliatePlatform: string;
  affiliateUrl: string;
  rating: string | null;
}

export default function HomePage() {
  const [locale, setLocale] = useState<Locale>('en');
  const [articles, setArticles] = useState<ArticleItem[]>([]);
  const [products, setProducts] = useState<ProductItem[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const updateLocale = () => {
      const savedLocale = (localStorage.getItem('gr_locale') as Locale) || 'en';
      setLocale(savedLocale);
      fetchContent(savedLocale);
    };
    updateLocale();
    window.addEventListener('gr-locale-change', updateLocale);
    return () => window.removeEventListener('gr-locale-change', updateLocale);
  }, []);

  const fetchContent = async (loc: Locale) => {
    try {
      setLoading(true);
      const [artRes, prodRes] = await Promise.all([
        fetch(`/api/v1/articles?locale=${loc}`).then((r) => r.json()),
        fetch(`/api/v1/products?locale=${loc}`).then((r) => r.json()),
      ]);

      if (artRes.success) {
        setArticles(artRes.data.slice(0, 3));
      }
      if (prodRes.success) {
        setProducts(prodRes.data.slice(0, 3));
      }
    } catch (e) {
      console.error('Failed to fetch home page content:', e);
    } finally {
      setLoading(false);
    }
  };

  const t = translations[locale];

  return (
    <div className="space-y-20 pb-20">
      {/* Hero Section */}
      <section className="relative overflow-hidden pt-12 pb-20 lg:pt-20 lg:pb-28">
        {/* Ambient Gradient Glows */}
        <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[350px] bg-amber-400/15 dark:bg-amber-500/10 blur-[130px] rounded-full pointer-events-none" />
        <div className="absolute top-1/3 right-10 w-[400px] h-[300px] bg-emerald-500/10 blur-[120px] rounded-full pointer-events-none" />

        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10 text-center">
          {/* Badge */}
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-amber-500/30 bg-amber-500/10 dark:bg-amber-400/10 text-amber-700 dark:text-amber-400 text-xs font-bold tracking-wide uppercase mb-8 shadow-sm">
            <Sparkles size={14} className="text-amber-500" />
            <span>{t.heroBadge}</span>
          </div>

          {/* Main Headline */}
          <h1 className="text-4xl sm:text-6xl lg:text-7xl font-black tracking-tight text-slate-900 dark:text-white max-w-4xl mx-auto leading-[1.1]">
            Empowering Poultry Farmers with{' '}
            <span className="gold-text-gradient">Precision & Intelligence</span>
          </h1>

          {/* Subtitle */}
          <p className="mt-6 text-lg sm:text-xl text-slate-600 dark:text-slate-300 max-w-3xl mx-auto leading-relaxed">
            {t.heroSubtitle}
          </p>

          {/* CTA Action Buttons */}
          <div className="mt-10 flex flex-wrap justify-center items-center gap-4">
            <a
              href="https://play.google.com/store/apps/details?id=com.goldenroost.app"
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center gap-2.5 px-8 py-4 rounded-2xl gold-gradient text-slate-950 font-black text-sm shadow-xl shadow-amber-500/25 hover:scale-105 active:scale-95 transition-all duration-200"
            >
              <Download size={18} />
              <span>{t.downloadApp}</span>
            </a>
            <Link
              href="/articles"
              className="flex items-center gap-2 px-6 py-4 rounded-2xl border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-900 font-bold text-sm text-slate-800 dark:text-slate-100 hover:border-amber-500 hover:bg-slate-50 dark:hover:bg-slate-800 shadow-sm transition-all"
            >
              <BookOpen size={18} className="text-amber-500" />
              <span>{t.exploreKnowledge}</span>
            </Link>
            <Link
              href="/products"
              className="flex items-center gap-2 px-6 py-4 rounded-2xl border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-900 font-bold text-sm text-slate-800 dark:text-slate-100 hover:border-emerald-500 hover:bg-slate-50 dark:hover:bg-slate-800 shadow-sm transition-all"
            >
              <ShoppingBag size={18} className="text-emerald-500" />
              <span>{t.exploreProducts}</span>
            </Link>
          </div>

          {/* Key Metric Highlights */}
          <div className="mt-16 grid grid-cols-2 md:grid-cols-4 gap-4 max-w-4xl mx-auto">
            <div className="p-4 rounded-2xl border border-slate-200 dark:border-slate-800 bg-white/70 dark:bg-slate-900/70 backdrop-blur-sm">
              <span className="block text-2xl sm:text-3xl font-black text-amber-500">100%</span>
              <span className="text-xs text-slate-500 font-medium">Offline Operations</span>
            </div>
            <div className="p-4 rounded-2xl border border-slate-200 dark:border-slate-800 bg-white/70 dark:bg-slate-900/70 backdrop-blur-sm">
              <span className="block text-2xl sm:text-3xl font-black text-emerald-500">0 Data Loss</span>
              <span className="text-xs text-slate-500 font-medium">Guaranteed Outbox</span>
            </div>
            <div className="p-4 rounded-2xl border border-slate-200 dark:border-slate-800 bg-white/70 dark:bg-slate-900/70 backdrop-blur-sm">
              <span className="block text-2xl sm:text-3xl font-black text-amber-500">3 Languages</span>
              <span className="text-xs text-slate-500 font-medium">EN • FR • العربية</span>
            </div>
            <div className="p-4 rounded-2xl border border-slate-200 dark:border-slate-800 bg-white/70 dark:bg-slate-900/70 backdrop-blur-sm">
              <span className="block text-2xl sm:text-3xl font-black text-emerald-500">21-Day</span>
              <span className="text-xs text-slate-500 font-medium">Incubation Logic</span>
            </div>
          </div>
        </div>
      </section>

      {/* Feature Pillars Section */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center max-w-3xl mx-auto mb-14">
          <h2 className="text-3xl sm:text-4xl font-black text-slate-900 dark:text-white">
            {t.featuresTitle}
          </h2>
          <p className="mt-3 text-sm sm:text-base text-slate-600 dark:text-slate-400">
            {t.featuresSubtitle}
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {/* Card 1 */}
          <div className="p-6 rounded-3xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 shadow-sm hover:border-amber-500/50 hover:shadow-md transition-all group">
            <div className="w-12 h-12 rounded-2xl bg-amber-500/10 text-amber-500 flex items-center justify-center mb-5 group-hover:scale-110 transition-transform">
              <Cpu size={24} />
            </div>
            <h3 className="text-base font-bold text-slate-900 dark:text-white mb-2">
              {t.feature1Title}
            </h3>
            <p className="text-xs sm:text-sm text-slate-600 dark:text-slate-400 leading-relaxed">
              {t.feature1Desc}
            </p>
          </div>

          {/* Card 2 */}
          <div className="p-6 rounded-3xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 shadow-sm hover:border-emerald-500/50 hover:shadow-md transition-all group">
            <div className="w-12 h-12 rounded-2xl bg-emerald-500/10 text-emerald-500 flex items-center justify-center mb-5 group-hover:scale-110 transition-transform">
              <TrendingUp size={24} />
            </div>
            <h3 className="text-base font-bold text-slate-900 dark:text-white mb-2">
              {t.feature2Title}
            </h3>
            <p className="text-xs sm:text-sm text-slate-600 dark:text-slate-400 leading-relaxed">
              {t.feature2Desc}
            </p>
          </div>

          {/* Card 3 */}
          <div className="p-6 rounded-3xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 shadow-sm hover:border-amber-500/50 hover:shadow-md transition-all group">
            <div className="w-12 h-12 rounded-2xl bg-amber-500/10 text-amber-500 flex items-center justify-center mb-5 group-hover:scale-110 transition-transform">
              <Layers size={24} />
            </div>
            <h3 className="text-base font-bold text-slate-900 dark:text-white mb-2">
              {t.feature3Title}
            </h3>
            <p className="text-xs sm:text-sm text-slate-600 dark:text-slate-400 leading-relaxed">
              {t.feature3Desc}
            </p>
          </div>

          {/* Card 4 */}
          <div className="p-6 rounded-3xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 shadow-sm hover:border-emerald-500/50 hover:shadow-md transition-all group">
            <div className="w-12 h-12 rounded-2xl bg-emerald-500/10 text-emerald-500 flex items-center justify-center mb-5 group-hover:scale-110 transition-transform">
              <ShieldAlert size={24} />
            </div>
            <h3 className="text-base font-bold text-slate-900 dark:text-white mb-2">
              {t.feature4Title}
            </h3>
            <p className="text-xs sm:text-sm text-slate-600 dark:text-slate-400 leading-relaxed">
              {t.feature4Desc}
            </p>
          </div>
        </div>
      </section>

      {/* AdSense Placement */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <AdSenseBanner slot="home-mid-banner" />
      </div>

      {/* Latest Articles Preview */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex flex-col sm:flex-row justify-between items-start sm:items-end gap-4 mb-10">
          <div>
            <h2 className="text-2xl sm:text-3xl font-black text-slate-900 dark:text-white">
              {t.latestArticlesTitle}
            </h2>
            <p className="text-xs sm:text-sm text-slate-500 mt-1">
              Validated protocols written for smallholders and commercial poultry producers.
            </p>
          </div>
          <Link
            href="/articles"
            className="inline-flex items-center gap-1.5 text-xs font-bold text-amber-600 dark:text-amber-400 hover:text-amber-500 transition-colors"
          >
            <span>{t.viewAllArticles}</span>
            <ArrowRight size={14} />
          </Link>
        </div>

        {loading ? (
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 animate-pulse">
            {[1, 2, 3].map((i) => (
              <div key={i} className="h-64 rounded-3xl bg-slate-200 dark:bg-slate-800" />
            ))}
          </div>
        ) : articles.length > 0 ? (
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {articles.map((art) => (
              <article
                key={art.id}
                className="group flex flex-col rounded-3xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 overflow-hidden shadow-sm hover:shadow-lg transition-all"
              >
                {art.featuredImageUrl && (
                  <div className="h-44 w-full overflow-hidden bg-slate-100 dark:bg-slate-800">
                    <img
                      src={art.featuredImageUrl}
                      alt={art.title}
                      className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                    />
                  </div>
                )}
                <div className="p-6 flex-1 flex flex-col">
                  <div className="flex items-center gap-2 mb-3">
                    <span className="px-2.5 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wider bg-amber-100 dark:bg-amber-950/60 text-amber-800 dark:text-amber-400">
                      {art.category.replace('_', ' ')}
                    </span>
                  </div>
                  <h3 className="text-base font-bold text-slate-900 dark:text-white mb-2 line-clamp-2 group-hover:text-amber-500 transition-colors">
                    <Link href={`/articles/${art.slug}`}>{art.title}</Link>
                  </h3>
                  <p className="text-xs text-slate-600 dark:text-slate-400 line-clamp-3 mb-4 flex-1">
                    {art.summary}
                  </p>
                  <Link
                    href={`/articles/${art.slug}`}
                    className="inline-flex items-center gap-1 text-xs font-bold text-amber-600 dark:text-amber-400 hover:text-amber-500"
                  >
                    <span>{t.readMore}</span>
                    <ArrowRight size={12} />
                  </Link>
                </div>
              </article>
            ))}
          </div>
        ) : (
          <p className="text-sm text-slate-500">No articles published yet.</p>
        )}
      </section>

      {/* Recommended Products & Equipment */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex flex-col sm:flex-row justify-between items-start sm:items-end gap-4 mb-10">
          <div>
            <h2 className="text-2xl sm:text-3xl font-black text-slate-900 dark:text-white">
              {t.featuredProductsTitle}
            </h2>
            <p className="text-xs sm:text-sm text-slate-500 mt-1">
              Field-tested brooders, drinkers, candlers, and digital incubators.
            </p>
          </div>
          <Link
            href="/products"
            className="inline-flex items-center gap-1.5 text-xs font-bold text-emerald-600 dark:text-emerald-400 hover:text-emerald-500 transition-colors"
          >
            <span>{t.viewAllProducts}</span>
            <ArrowRight size={14} />
          </Link>
        </div>

        {loading ? (
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 animate-pulse">
            {[1, 2, 3].map((i) => (
              <div key={i} className="h-64 rounded-3xl bg-slate-200 dark:bg-slate-800" />
            ))}
          </div>
        ) : products.length > 0 ? (
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {products.map((prod) => (
              <div
                key={prod.id}
                className="group flex flex-col rounded-3xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 overflow-hidden shadow-sm hover:shadow-lg transition-all"
              >
                {prod.imageUrl && (
                  <div className="h-44 w-full overflow-hidden bg-slate-100 dark:bg-slate-800">
                    <img
                      src={prod.imageUrl}
                      alt={prod.name}
                      className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                    />
                  </div>
                )}
                <div className="p-6 flex-1 flex flex-col">
                  <div className="flex items-center justify-between mb-3">
                    <span className="px-2.5 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wider bg-emerald-100 dark:bg-emerald-950/60 text-emerald-800 dark:text-emerald-400">
                      {prod.category}
                    </span>
                    {prod.rating && (
                      <div className="flex items-center gap-1 text-xs font-bold text-amber-500">
                        <Star size={13} fill="currentColor" />
                        <span>{prod.rating}</span>
                      </div>
                    )}
                  </div>
                  <h3 className="text-base font-bold text-slate-900 dark:text-white mb-2 line-clamp-2 group-hover:text-emerald-500 transition-colors">
                    <Link href={`/products/${prod.slug}`}>{prod.name}</Link>
                  </h3>
                  <p className="text-xs text-slate-600 dark:text-slate-400 line-clamp-3 mb-4 flex-1">
                    {prod.description}
                  </p>
                  <div className="flex items-center justify-between pt-3 border-t border-slate-100 dark:border-slate-800">
                    <span className="text-base font-black text-slate-900 dark:text-white">
                      {prod.priceDisplay || 'Check Store'}
                    </span>
                    <a
                      href={prod.affiliateUrl}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="inline-flex items-center gap-1 px-4 py-2 rounded-xl text-xs font-bold bg-emerald-600 text-white hover:bg-emerald-500 transition-colors"
                    >
                      <span>{t.viewProduct}</span>
                      <ArrowRight size={12} />
                    </a>
                  </div>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <p className="text-sm text-slate-500">No products catalogued yet.</p>
        )}
      </section>

      {/* Android App Release Banner */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="rounded-3xl gold-gradient p-8 sm:p-12 text-slate-950 flex flex-col md:flex-row items-center justify-between gap-8 shadow-2xl shadow-amber-500/20">
          <div className="max-w-xl space-y-3">
            <span className="px-3 py-1 rounded-full bg-slate-950/15 text-slate-950 text-xs font-black uppercase tracking-wider">
              Google Play Official Release
            </span>
            <h2 className="text-3xl sm:text-4xl font-black tracking-tight">
              Get the Golden Roost Farm App Today
            </h2>
            <p className="text-sm sm:text-base font-medium opacity-90 leading-relaxed">
              Record egg production, live bird mortalities, batch incubation candling, and feed usage
              directly inside the farm coop with zero internet required.
            </p>
          </div>
          <div className="flex flex-col sm:flex-row items-center gap-4">
            <a
              href="https://play.google.com/store/apps/details?id=com.goldenroost.app"
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center gap-2.5 px-8 py-4 rounded-2xl bg-slate-950 text-white font-black text-sm shadow-xl hover:bg-slate-900 transition-all"
            >
              <Download size={18} className="text-amber-400" />
              <span>Download on Google Play</span>
            </a>
          </div>
        </div>
      </section>
    </div>
  );
}
