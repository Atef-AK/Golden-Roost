'use client';

import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import { ShoppingBag, Star, ArrowRight, ShieldCheck, ExternalLink } from 'lucide-react';
import { Locale, translations } from '@/lib/i18n';
import AdSenseBanner from '@/components/AdSenseBanner';

interface ProductItem {
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
}

const CATEGORIES = [
  { id: 'all', label: 'All Equipment' },
  { id: 'incubation', label: 'Incubators & Candlers' },
  { id: 'equipment', label: 'Drinkers & Brooders' },
  { id: 'medication', label: 'Vitamins & Hygiene' },
  { id: 'feed', label: 'Feeds & Supplements' },
];

export default function ProductsPage() {
  const [locale, setLocale] = useState<Locale>('en');
  const [products, setProducts] = useState<ProductItem[]>([]);
  const [filteredProducts, setFilteredProducts] = useState<ProductItem[]>([]);
  const [selectedCategory, setSelectedCategory] = useState('all');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const updateLocale = () => {
      const savedLocale = (localStorage.getItem('gr_locale') as Locale) || 'en';
      setLocale(savedLocale);
      loadProducts(savedLocale);
    };
    updateLocale();
    window.addEventListener('gr-locale-change', updateLocale);
    return () => window.removeEventListener('gr-locale-change', updateLocale);
  }, []);

  const loadProducts = async (loc: Locale) => {
    try {
      setLoading(true);
      const res = await fetch(`/api/v1/products?locale=${loc}`).then((r) => r.json());
      if (res.success) {
        setProducts(res.data);
        setFilteredProducts(res.data);
      }
    } catch (err) {
      console.error('Failed to load products:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (selectedCategory === 'all') {
      setFilteredProducts(products);
    } else {
      setFilteredProducts(products.filter((p) => p.category === selectedCategory));
    }
  }, [selectedCategory, products]);

  const t = translations[locale];

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12 space-y-10">
      {/* Page Header */}
      <div className="text-center max-w-3xl mx-auto">
        <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 text-xs font-bold uppercase mb-4">
          <ShoppingBag size={14} />
          <span>Farm Equipment & Supplies</span>
        </div>
        <h1 className="text-3xl sm:text-5xl font-black text-slate-900 dark:text-white">
          Certified Poultry Farm Equipment
        </h1>
        <p className="mt-3 text-sm sm:text-base text-slate-600 dark:text-slate-400">
          Curated brooding heaters, automatic drinkers, egg candlers, and digital incubators tested
          for maximum farm durability and chick survival.
        </p>

        {/* Affiliate Disclosure Notice */}
        <div className="mt-6 p-3 rounded-2xl bg-amber-50 dark:bg-amber-950/20 border border-amber-200 dark:border-amber-900/40 text-xs text-amber-800 dark:text-amber-300 leading-relaxed max-w-2xl mx-auto text-start sm:text-center">
          <p>
            <strong>Commercial Disclosure:</strong> Golden Roost earns affiliate commissions from
            qualifying purchases through external retailer links. This supports our free farm
            management tools at no extra cost to you.
          </p>
        </div>
      </div>

      {/* Category Pills */}
      <div className="flex items-center justify-center gap-2 overflow-x-auto pb-2">
        {CATEGORIES.map((cat) => (
          <button
            key={cat.id}
            onClick={() => setSelectedCategory(cat.id)}
            className={`px-4 py-2 rounded-xl text-xs font-bold whitespace-nowrap transition-all ${
              selectedCategory === cat.id
                ? 'bg-emerald-600 text-white shadow-sm'
                : 'bg-white dark:bg-slate-900 text-slate-600 dark:text-slate-400 border border-slate-200 dark:border-slate-800 hover:border-emerald-500'
            }`}
          >
            {cat.label}
          </button>
        ))}
      </div>

      {/* Products Grid */}
      {loading ? (
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 animate-pulse">
          {[1, 2, 3, 4, 5, 6].map((i) => (
            <div key={i} className="h-80 rounded-3xl bg-slate-200 dark:bg-slate-800" />
          ))}
        </div>
      ) : filteredProducts.length > 0 ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredProducts.map((prod) => (
            <div
              key={prod.id}
              className="group flex flex-col rounded-3xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 overflow-hidden shadow-sm hover:shadow-lg transition-all"
            >
              {prod.imageUrl && (
                <div className="h-52 w-full overflow-hidden bg-slate-100 dark:bg-slate-800">
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

                <h2 className="text-base font-bold text-slate-900 dark:text-white mb-2 line-clamp-2 group-hover:text-emerald-500 transition-colors">
                  <Link href={`/products/${prod.slug}`}>{prod.name}</Link>
                </h2>

                <p className="text-xs text-slate-600 dark:text-slate-400 line-clamp-3 mb-6 flex-1 leading-relaxed">
                  {prod.description}
                </p>

                <div className="pt-4 border-t border-slate-100 dark:border-slate-800 flex items-center justify-between">
                  <div>
                    <span className="text-xs text-slate-400 block">Retail Price</span>
                    <span className="text-lg font-black text-slate-900 dark:text-white">
                      {prod.priceDisplay || 'Check Store'}
                    </span>
                  </div>

                  <a
                    href={prod.affiliateUrl}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="inline-flex items-center gap-1.5 px-4 py-2.5 rounded-xl text-xs font-bold bg-emerald-600 text-white hover:bg-emerald-500 transition-all shadow-sm"
                  >
                    <span>Check Retailer</span>
                    <ExternalLink size={13} />
                  </a>
                </div>
              </div>
            </div>
          ))}
        </div>
      ) : (
        <div className="text-center py-16 bg-white dark:bg-slate-900 rounded-3xl border border-slate-200 dark:border-slate-800">
          <ShoppingBag size={36} className="mx-auto text-slate-400 mb-3" />
          <h3 className="text-base font-bold text-slate-800 dark:text-slate-200">
            No products found in this category
          </h3>
        </div>
      )}

      {/* AdSense Placement */}
      <AdSenseBanner slot="products-footer-banner" />
    </div>
  );
}
