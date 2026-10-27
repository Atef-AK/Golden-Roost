'use client';

import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import { useParams } from 'next/navigation';
import { ArrowLeft, Star, ExternalLink, ShieldCheck, AlertCircle } from 'lucide-react';
import { Locale } from '@/lib/i18n';
import AdSenseBanner from '@/components/AdSenseBanner';

interface ProductDetail {
  id: string;
  slug: string;
  name: string;
  description: string;
  category: string;
  affiliatePlatform: string;
  affiliateUrl: string;
  priceDisplay: string | null;
  imageUrl: string | null;
  rating: string | null;
  translations: {
    locale: string;
    name: string;
    description: string;
  }[];
}

function ProductDetailContent() {
  const params = useParams();
  const slug = params.slug as string;

  const [locale, setLocale] = useState<Locale>('en');
  const [product, setProduct] = useState<ProductDetail | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const savedLocale = (localStorage.getItem('gr_locale') as Locale) || 'en';
    setLocale(savedLocale);
    fetchProduct(savedLocale);
  }, [slug]);

  const fetchProduct = async (loc: Locale) => {
    try {
      setLoading(true);
      const res = await fetch(`/api/v1/products/${slug}?locale=${loc}`).then((r) => r.json());
      if (res.success) {
        setProduct(res.data);
      }
    } catch (err) {
      console.error('Failed to load product:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleLanguageSwitch = (newLocale: Locale) => {
    setLocale(newLocale);
    fetchProduct(newLocale);
  };

  if (loading) {
    return (
      <div className="max-w-4xl mx-auto px-4 py-20 animate-pulse space-y-6">
        <div className="h-6 w-32 bg-slate-200 dark:bg-slate-800 rounded-lg" />
        <div className="h-64 bg-slate-200 dark:bg-slate-800 rounded-3xl" />
      </div>
    );
  }

  if (!product) {
    return (
      <div className="max-w-xl mx-auto px-4 py-24 text-center">
        <AlertCircle size={48} className="mx-auto text-amber-500 mb-4" />
        <h1 className="text-2xl font-black text-slate-900 dark:text-white">Product Not Found</h1>
        <p className="text-xs text-slate-500 mt-2">
          The requested product does not exist or may have been removed.
        </p>
        <Link
          href="/products"
          className="mt-6 inline-flex items-center gap-2 px-6 py-3 rounded-xl gold-gradient text-slate-950 font-bold text-xs"
        >
          <ArrowLeft size={14} />
          <span>Back to Equipment</span>
        </Link>
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12 space-y-8">
      {/* Navigation & Language */}
      <div className="flex flex-wrap items-center justify-between gap-4">
        <Link
          href="/products"
          className="inline-flex items-center gap-1.5 text-xs font-bold text-slate-600 dark:text-slate-400 hover:text-emerald-500 transition-colors"
        >
          <ArrowLeft size={14} />
          <span>All Equipment</span>
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
                  ? 'bg-white dark:bg-slate-700 text-emerald-600 dark:text-emerald-400 shadow-sm'
                  : 'text-slate-600 dark:text-slate-400 hover:text-slate-900'
              }`}
            >
              {l === 'ar' ? 'العربية' : l}
            </button>
          ))}
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-8 items-start">
        {/* Product Image */}
        <div className="rounded-3xl overflow-hidden bg-slate-100 dark:bg-slate-800 border border-slate-200 dark:border-slate-800 shadow-sm">
          {product.imageUrl ? (
            <img
              src={product.imageUrl}
              alt={product.name}
              className="w-full h-80 object-cover"
            />
          ) : (
            <div className="w-full h-80 flex items-center justify-center text-slate-400">
              No Image Available
            </div>
          )}
        </div>

        {/* Product Details */}
        <div className="space-y-6">
          <div>
            <div className="flex items-center justify-between gap-2 mb-2">
              <span className="px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wider bg-emerald-100 dark:bg-emerald-950/60 text-emerald-800 dark:text-emerald-400">
                {product.category}
              </span>
              {product.rating && (
                <div className="flex items-center gap-1 text-xs font-bold text-amber-500">
                  <Star size={14} fill="currentColor" />
                  <span>{product.rating} / 5.0</span>
                </div>
              )}
            </div>

            <h1 className="text-2xl sm:text-3xl font-black text-slate-900 dark:text-white leading-tight">
              {product.name}
            </h1>
          </div>

          <div className="p-4 rounded-2xl bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-800">
            <span className="text-xs text-slate-500 block">Retailer Price</span>
            <span className="text-3xl font-black text-slate-900 dark:text-white">
              {product.priceDisplay || 'Check Online Store'}
            </span>
            <span className="text-xs text-slate-400 block mt-1">
              Available via {product.affiliatePlatform.toUpperCase()}
            </span>
          </div>

          <p className="text-xs sm:text-sm text-slate-600 dark:text-slate-300 leading-relaxed">
            {product.description}
          </p>

          <a
            href={product.affiliateUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="w-full flex items-center justify-center gap-2 py-4 rounded-2xl bg-emerald-600 text-white font-bold text-sm hover:bg-emerald-500 shadow-lg shadow-emerald-600/25 transition-all"
          >
            <span>Buy on {product.affiliatePlatform.toUpperCase()}</span>
            <ExternalLink size={16} />
          </a>

          {/* Commercial Disclosure */}
          <div className="p-3 rounded-xl bg-slate-100 dark:bg-slate-900 text-[11px] text-slate-500 leading-relaxed border border-slate-200 dark:border-slate-800">
            <ShieldCheck size={14} className="inline mr-1 text-emerald-500" />
            <strong>Affiliate Note:</strong> Golden Roost receives an affiliate commission for
            purchases made through this link. This does not affect the price you pay.
          </div>
        </div>
      </div>

      {/* AdSense Placement */}
      <AdSenseBanner slot="product-detail-banner" />
    </div>
  );
}

export default function ProductDetailPage() {
  return (
    <React.Suspense
      fallback={
        <div className="max-w-4xl mx-auto px-4 py-20 text-center text-xs text-slate-500">
          Loading product...
        </div>
      }
    >
      <ProductDetailContent />
    </React.Suspense>
  );
}
