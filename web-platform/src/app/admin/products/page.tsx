'use client';

import React, { useState, useEffect, useRef } from 'react';
import {
  ShoppingBag,
  Plus,
  Edit2,
  Trash2,
  ExternalLink,
  CheckCircle2,
  XCircle,
  X,
  Globe,
  Save,
  Search,
  Star,
  Eye,
} from 'lucide-react';
import { Locale } from '@/lib/i18n';
import RichContentToolbar from '@/components/RichContentToolbar';
import ImageUploadField from '@/components/ImageUploadField';
import MarkdownRenderer from '@/components/MarkdownRenderer';

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
  isPublished: boolean;
  createdAt: string;
  translations: {
    locale: string;
    name: string;
    description: string;
  }[];
}

export default function AdminProductsPage() {
  const [products, setProducts] = useState<ProductItem[]>([]);
  const [filteredProducts, setFilteredProducts] = useState<ProductItem[]>([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [loading, setLoading] = useState(true);

  // Modal State
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingProduct, setEditingProduct] = useState<ProductItem | null>(null);
  const [activeTab, setActiveTab] = useState<Locale>('en');
  const [saving, setSaving] = useState(false);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  // Form Fields
  const [slug, setSlug] = useState('');
  const [category, setCategory] = useState('equipment');
  const [affiliatePlatform, setAffiliatePlatform] = useState('amazon');
  const [affiliateUrl, setAffiliateUrl] = useState('');
  const [priceDisplay, setPriceDisplay] = useState('');
  const [imageUrl, setImageUrl] = useState('');
  const [rating, setRating] = useState('4.80');
  const [isPublished, setIsPublished] = useState(true);

  // Translations Form State
  const [translationsData, setTranslationsData] = useState({
    en: { name: '', description: '' },
    fr: { name: '', description: '' },
    ar: { name: '', description: '' },
  });

  const [contentViewMode, setContentViewMode] = useState<'write' | 'preview'>('write');
  const textareaRef = useRef<HTMLTextAreaElement | null>(null);

  const loadProducts = async () => {
    try {
      setLoading(true);
      const res = await fetch('/api/v1/products?include_unpublished=true').then((r) => r.json());
      if (res.success) {
        setProducts(res.data);
        setFilteredProducts(res.data);
      }
    } catch (e) {
      console.error('Failed to load products:', e);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadProducts();
  }, []);

  useEffect(() => {
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase();
      setFilteredProducts(
        products.filter(
          (p) => p.name.toLowerCase().includes(q) || p.slug.toLowerCase().includes(q)
        )
      );
    } else {
      setFilteredProducts(products);
    }
  }, [searchQuery, products]);

  const handleOpenCreateModal = () => {
    setEditingProduct(null);
    setSlug('');
    setCategory('equipment');
    setAffiliatePlatform('amazon');
    setAffiliateUrl('');
    setPriceDisplay('');
    setImageUrl('');
    setRating('4.80');
    setIsPublished(true);
    setTranslationsData({
      en: { name: '', description: '' },
      fr: { name: '', description: '' },
      ar: { name: '', description: '' },
    });
    setActiveTab('en');
    setContentViewMode('write');
    setErrorMsg(null);
    setIsModalOpen(true);
  };

  const handleOpenEditModal = async (prod: ProductItem) => {
    try {
      const res = await fetch(`/api/v1/products/${prod.slug}?locale=en`).then((r) => r.json());
      if (res.success) {
        const full = res.data;
        setEditingProduct(full);
        setSlug(full.slug);
        setCategory(full.category);
        setAffiliatePlatform(full.affiliatePlatform);
        setAffiliateUrl(full.affiliateUrl);
        setPriceDisplay(full.priceDisplay || '');
        setImageUrl(full.imageUrl || '');
        setRating(full.rating || '4.80');
        setIsPublished(full.isPublished);

        const newTrans = {
          en: { name: '', description: '' },
          fr: { name: '', description: '' },
          ar: { name: '', description: '' },
        };

        full.translations?.forEach(
          (t: { locale: string; name: string; description: string }) => {
            if (t.locale === 'en' || t.locale === 'fr' || t.locale === 'ar') {
              newTrans[t.locale as Locale] = {
                name: t.name || '',
                description: t.description || '',
              };
            }
          }
        );

        setTranslationsData(newTrans);
        setActiveTab('en');
        setContentViewMode('write');
        setErrorMsg(null);
        setIsModalOpen(true);
      }
    } catch (e) {
      console.error('Failed to load product for edit:', e);
    }
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    setErrorMsg(null);

    const payload = {
      slug: slug.trim().toLowerCase(),
      category,
      affiliatePlatform,
      affiliateUrl: affiliateUrl.trim(),
      priceDisplay: priceDisplay.trim() || null,
      imageUrl: imageUrl.trim() || null,
      rating,
      isPublished,
      translations: [
        { locale: 'en', ...translationsData.en },
        { locale: 'fr', ...translationsData.fr },
        { locale: 'ar', ...translationsData.ar },
      ].filter((t) => t.name.trim().length > 0),
    };

    try {
      let res;
      if (editingProduct) {
        res = await fetch(`/api/v1/products/${editingProduct.slug}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload),
        });
      } else {
        res = await fetch('/api/v1/products', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload),
        });
      }

      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.error || 'Failed to save product.');
      }

      setIsModalOpen(false);
      loadProducts();
    } catch (err: unknown) {
      setErrorMsg(err instanceof Error ? err.message : 'Failed to save product.');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (prodSlug: string) => {
    if (!confirm(`Are you sure you want to permanently delete product "${prodSlug}"?`)) {
      return;
    }

    try {
      const res = await fetch(`/api/v1/products/${prodSlug}`, {
        method: 'DELETE',
      });
      if (res.ok) {
        loadProducts();
      } else {
        const data = await res.json();
        alert(data.error || 'Failed to delete.');
      }
    } catch (e) {
      console.error('Delete error:', e);
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-2xl font-black text-white">Equipment & Affiliate Products</h1>
          <p className="text-xs text-slate-400 mt-1">
            Manage brooders, drinkers, egg incubators, and external retailer affiliate URLs.
          </p>
        </div>

        <button
          onClick={handleOpenCreateModal}
          className="flex items-center gap-2 px-4 py-2.5 rounded-xl bg-emerald-600 text-white font-bold text-xs shadow-md hover:bg-emerald-500 transition-all"
        >
          <Plus size={15} />
          <span>Add Product</span>
        </button>
      </div>

      {/* Search Bar */}
      <div className="relative max-w-md">
        <Search size={15} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-500" />
        <input
          type="text"
          placeholder="Search product name or slug..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="w-full pl-10 pr-4 py-2 rounded-xl text-xs bg-slate-900 border border-slate-800 text-white focus:outline-none focus:border-emerald-500"
        />
      </div>

      {/* Products Table */}
      <div className="rounded-3xl bg-slate-900 border border-slate-800 overflow-hidden shadow-sm">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-slate-800/60 text-slate-400 uppercase tracking-wider text-[10px] font-bold border-b border-slate-800">
              <tr>
                <th className="px-6 py-3.5">Product Name</th>
                <th className="px-6 py-3.5">Category</th>
                <th className="px-6 py-3.5">Platform</th>
                <th className="px-6 py-3.5">Price</th>
                <th className="px-6 py-3.5">Status</th>
                <th className="px-6 py-3.5 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800 text-slate-300">
              {loading ? (
                <tr>
                  <td colSpan={6} className="px-6 py-8 text-center text-slate-500">
                    Loading products...
                  </td>
                </tr>
              ) : filteredProducts.length > 0 ? (
                filteredProducts.map((prod) => (
                  <tr key={prod.id} className="hover:bg-slate-800/30 transition-colors">
                    <td className="px-6 py-4">
                      <span className="font-bold text-white block text-sm">{prod.name}</span>
                      <span className="text-[11px] text-slate-500 font-mono">/{prod.slug}</span>
                    </td>
                    <td className="px-6 py-4">
                      <span className="px-2.5 py-1 rounded-full text-[10px] font-bold uppercase bg-emerald-500/10 text-emerald-400">
                        {prod.category}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <a
                        href={prod.affiliateUrl}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="inline-flex items-center gap-1 font-mono text-[11px] text-amber-400 hover:underline"
                      >
                        <span>{prod.affiliatePlatform.toUpperCase()}</span>
                        <ExternalLink size={11} />
                      </a>
                    </td>
                    <td className="px-6 py-4 font-bold text-white">
                      {prod.priceDisplay || 'N/A'}
                    </td>
                    <td className="px-6 py-4">
                      {prod.isPublished ? (
                        <span className="inline-flex items-center gap-1 text-[11px] font-bold text-emerald-400">
                          <CheckCircle2 size={13} />
                          <span>Active</span>
                        </span>
                      ) : (
                        <span className="inline-flex items-center gap-1 text-[11px] font-bold text-slate-500">
                          <XCircle size={13} />
                          <span>Hidden</span>
                        </span>
                      )}
                    </td>
                    <td className="px-6 py-4 text-right space-x-2">
                      <button
                        onClick={() => handleOpenEditModal(prod)}
                        className="p-1.5 rounded-lg bg-slate-800 text-slate-300 hover:text-emerald-400 hover:bg-slate-700 transition-colors"
                        title="Edit Product"
                      >
                        <Edit2 size={14} />
                      </button>
                      <button
                        onClick={() => handleDelete(prod.slug)}
                        className="p-1.5 rounded-lg bg-slate-800 text-slate-300 hover:text-red-400 hover:bg-slate-700 transition-colors"
                        title="Delete Product"
                      >
                        <Trash2 size={14} />
                      </button>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan={6} className="px-6 py-8 text-center text-slate-500">
                    No products found.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Product Editor Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 bg-black/75 flex items-center justify-center p-4 overflow-y-auto">
          <div className="w-full max-w-2xl rounded-3xl bg-slate-900 border border-slate-800 p-6 sm:p-8 space-y-6 my-8 max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between pb-4 border-b border-slate-800">
              <h2 className="text-lg font-black text-white">
                {editingProduct ? `Edit Product: ${editingProduct.slug}` : 'Add New Equipment'}
              </h2>
              <button
                onClick={() => setIsModalOpen(false)}
                className="text-slate-400 hover:text-white"
              >
                <X size={20} />
              </button>
            </div>

            {errorMsg && (
              <div className="p-3 rounded-xl bg-red-950/60 border border-red-800 text-red-300 text-xs">
                {errorMsg}
              </div>
            )}

            <form onSubmit={handleSave} className="space-y-5">
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-bold text-slate-300 mb-1">
                    Slug (e.g. automatic-egg-candler) *
                  </label>
                  <input
                    type="text"
                    required
                    disabled={!!editingProduct}
                    value={slug}
                    onChange={(e) => setSlug(e.target.value)}
                    className="w-full px-3 py-2 rounded-xl text-xs bg-slate-800 border border-slate-700 text-white focus:outline-none focus:border-emerald-500 disabled:opacity-60"
                  />
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-300 mb-1">Category *</label>
                  <select
                    value={category}
                    onChange={(e) => setCategory(e.target.value)}
                    className="w-full px-3 py-2 rounded-xl text-xs bg-slate-800 border border-slate-700 text-white focus:outline-none focus:border-emerald-500"
                  >
                    <option value="equipment">Drinkers & Brooders</option>
                    <option value="incubation">Incubators & Candlers</option>
                    <option value="medication">Vitamins & Hygiene</option>
                    <option value="feed">Feeds & Supplements</option>
                  </select>
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <div>
                  <label className="block text-xs font-bold text-slate-300 mb-1">Platform *</label>
                  <select
                    value={affiliatePlatform}
                    onChange={(e) => setAffiliatePlatform(e.target.value)}
                    className="w-full px-3 py-2 rounded-xl text-xs bg-slate-800 border border-slate-700 text-white focus:outline-none focus:border-emerald-500"
                  >
                    <option value="amazon">Amazon</option>
                    <option value="jumia">Jumia</option>
                    <option value="direct">Direct Manufacturer</option>
                  </select>
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-300 mb-1">
                    Price Tag (e.g. $24.99)
                  </label>
                  <input
                    type="text"
                    value={priceDisplay}
                    onChange={(e) => setPriceDisplay(e.target.value)}
                    placeholder="$29.99"
                    className="w-full px-3 py-2 rounded-xl text-xs bg-slate-800 border border-slate-700 text-white focus:outline-none focus:border-emerald-500"
                  />
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-300 mb-1">Rating</label>
                  <input
                    type="text"
                    value={rating}
                    onChange={(e) => setRating(e.target.value)}
                    placeholder="4.85"
                    className="w-full px-3 py-2 rounded-xl text-xs bg-slate-800 border border-slate-700 text-white focus:outline-none focus:border-emerald-500"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-300 mb-1">
                  Affiliate Retailer URL *
                </label>
                <input
                  type="url"
                  required
                  value={affiliateUrl}
                  onChange={(e) => setAffiliateUrl(e.target.value)}
                  placeholder="https://amazon.com/dp/...?tag=..."
                  className="w-full px-3 py-2 rounded-xl text-xs bg-slate-800 border border-slate-700 text-white focus:outline-none focus:border-emerald-500 font-mono"
                />
              </div>

              <div>
                <ImageUploadField
                  label="Product Main Image"
                  value={imageUrl}
                  onChange={setImageUrl}
                  placeholder="https://images.unsplash.com/... or upload photo"
                  accent="emerald"
                />
              </div>

              {/* Trilingual Tabs */}
              <div className="space-y-4 pt-3 border-t border-slate-800">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-bold text-emerald-400 uppercase tracking-wider flex items-center gap-1.5">
                    <Globe size={14} />
                    <span>Product Translations</span>
                  </span>

                  <div className="flex items-center gap-1 p-1 bg-slate-800 rounded-xl">
                    {(['en', 'fr', 'ar'] as Locale[]).map((tab) => (
                      <button
                        key={tab}
                        type="button"
                        onClick={() => setActiveTab(tab)}
                        className={`px-3 py-1 rounded-lg text-xs font-bold uppercase transition-all ${
                          activeTab === tab
                            ? 'bg-emerald-600 text-white shadow-sm'
                            : 'text-slate-400 hover:text-white'
                        }`}
                      >
                        {tab === 'ar' ? 'العربية' : tab}
                      </button>
                    ))}
                  </div>
                </div>

                <div
                  className="space-y-4 p-4 rounded-2xl bg-slate-850 border border-slate-800"
                  dir={activeTab === 'ar' ? 'rtl' : 'ltr'}
                >
                  <div>
                    <label className="block text-xs font-bold text-slate-300 mb-1">
                      Product Name ({activeTab.toUpperCase()}) *
                    </label>
                    <input
                      type="text"
                      required={activeTab === 'en'}
                      value={translationsData[activeTab].name}
                      onChange={(e) =>
                        setTranslationsData({
                          ...translationsData,
                          [activeTab]: {
                            ...translationsData[activeTab],
                            name: e.target.value,
                          },
                        })
                      }
                      className="w-full px-3 py-2 rounded-xl text-xs bg-slate-800 border border-slate-700 text-white focus:outline-none focus:border-emerald-500"
                    />
                  </div>

                  {/* Rich Product Description & Specs */}
                  <div className="space-y-2">
                    <div className="flex items-center justify-between">
                      <label className="block text-xs font-bold text-slate-300">
                        Description & Specifications ({activeTab.toUpperCase()})
                      </label>
                      <div className="flex items-center gap-1 p-0.5 rounded-lg bg-slate-800 text-[11px] font-bold">
                        <button
                          type="button"
                          onClick={() => setContentViewMode('write')}
                          className={`flex items-center gap-1 px-2.5 py-1 rounded-md transition-all ${
                            contentViewMode === 'write'
                              ? 'bg-emerald-600 text-white shadow-sm'
                              : 'text-slate-400 hover:text-white'
                          }`}
                        >
                          <Edit2 size={12} />
                          <span>Write & Format</span>
                        </button>
                        <button
                          type="button"
                          onClick={() => setContentViewMode('preview')}
                          className={`flex items-center gap-1 px-2.5 py-1 rounded-md transition-all ${
                            contentViewMode === 'preview'
                              ? 'bg-emerald-600 text-white shadow-sm'
                              : 'text-slate-400 hover:text-white'
                          }`}
                        >
                          <Eye size={12} />
                          <span>Live Preview</span>
                        </button>
                      </div>
                    </div>

                    {contentViewMode === 'write' ? (
                      <div>
                        <RichContentToolbar
                          textareaRef={textareaRef}
                          value={translationsData[activeTab].description}
                          onChange={(val) =>
                            setTranslationsData({
                              ...translationsData,
                              [activeTab]: {
                                ...translationsData[activeTab],
                                description: val,
                              },
                            })
                          }
                          accent="emerald"
                        />
                        <textarea
                          ref={textareaRef}
                          rows={8}
                          value={translationsData[activeTab].description}
                          onChange={(e) =>
                            setTranslationsData({
                              ...translationsData,
                              [activeTab]: {
                                ...translationsData[activeTab],
                                description: e.target.value,
                              },
                            })
                          }
                          placeholder="Author product features, technical specifications table, usage guidelines, and embedded images..."
                          className="w-full px-3 py-2.5 rounded-b-xl text-xs font-mono bg-slate-800 border border-slate-700 text-white focus:outline-none focus:border-emerald-500 leading-relaxed"
                        />
                      </div>
                    ) : (
                      <div className="p-4 rounded-xl bg-slate-900 border border-slate-700 min-h-[180px] max-h-[320px] overflow-y-auto">
                        <MarkdownRenderer content={translationsData[activeTab].description} />
                      </div>
                    )}
                  </div>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="flex items-center justify-end gap-3 pt-4 border-t border-slate-800">
                <button
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="px-4 py-2 rounded-xl text-xs font-bold text-slate-400 hover:text-white"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={saving}
                  className="flex items-center gap-1.5 px-6 py-2.5 rounded-xl bg-emerald-600 text-white font-bold text-xs shadow-md disabled:opacity-50 hover:bg-emerald-500 transition-colors"
                >
                  <Save size={14} />
                  <span>{saving ? 'Saving...' : 'Save Product'}</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
