'use client';

import React, { useState, useEffect } from 'react';
import {
  FileText,
  Plus,
  Edit2,
  Trash2,
  Eye,
  CheckCircle2,
  XCircle,
  X,
  Globe,
  Save,
  Search,
} from 'lucide-react';
import { Locale } from '@/lib/i18n';

interface ArticleItem {
  id: string;
  slug: string;
  title: string;
  summary: string;
  content: string;
  category: string;
  featuredImageUrl: string | null;
  isPublished: boolean;
  createdAt: string;
  translations: {
    locale: string;
    title: string;
    summary: string;
    content: string;
  }[];
}

export default function AdminArticlesPage() {
  const [articles, setArticles] = useState<ArticleItem[]>([]);
  const [filteredArticles, setFilteredArticles] = useState<ArticleItem[]>([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [loading, setLoading] = useState(true);

  // Modal State
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingArticle, setEditingArticle] = useState<ArticleItem | null>(null);
  const [activeTab, setActiveTab] = useState<Locale>('en');
  const [saving, setSaving] = useState(false);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  // Form Fields
  const [slug, setSlug] = useState('');
  const [category, setCategory] = useState('disease_guide');
  const [featuredImageUrl, setFeaturedImageUrl] = useState('');
  const [isPublished, setIsPublished] = useState(true);

  // Translations Form State
  const [translationsData, setTranslationsData] = useState({
    en: { title: '', summary: '', content: '' },
    fr: { title: '', summary: '', content: '' },
    ar: { title: '', summary: '', content: '' },
  });

  const loadArticles = async () => {
    try {
      setLoading(true);
      const res = await fetch('/api/v1/articles?include_drafts=true').then((r) => r.json());
      if (res.success) {
        setArticles(res.data);
        setFilteredArticles(res.data);
      }
    } catch (e) {
      console.error('Failed to load articles:', e);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadArticles();
  }, []);

  useEffect(() => {
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase();
      setFilteredArticles(
        articles.filter(
          (a) => a.title.toLowerCase().includes(q) || a.slug.toLowerCase().includes(q)
        )
      );
    } else {
      setFilteredArticles(articles);
    }
  }, [searchQuery, articles]);

  const handleOpenCreateModal = () => {
    setEditingArticle(null);
    setSlug('');
    setCategory('disease_guide');
    setFeaturedImageUrl('');
    setIsPublished(true);
    setTranslationsData({
      en: { title: '', summary: '', content: '' },
      fr: { title: '', summary: '', content: '' },
      ar: { title: '', summary: '', content: '' },
    });
    setActiveTab('en');
    setErrorMsg(null);
    setIsModalOpen(true);
  };

  const handleOpenEditModal = async (art: ArticleItem) => {
    try {
      const res = await fetch(`/api/v1/articles/${art.slug}?locale=en`).then((r) => r.json());
      if (res.success) {
        const full = res.data;
        setEditingArticle(full);
        setSlug(full.slug);
        setCategory(full.category);
        setFeaturedImageUrl(full.featuredImageUrl || '');
        setIsPublished(full.isPublished);

        const newTrans = {
          en: { title: '', summary: '', content: '' },
          fr: { title: '', summary: '', content: '' },
          ar: { title: '', summary: '', content: '' },
        };

        full.translations?.forEach(
          (t: { locale: string; title: string; summary: string; content: string }) => {
            if (t.locale === 'en' || t.locale === 'fr' || t.locale === 'ar') {
              newTrans[t.locale as Locale] = {
                title: t.title || '',
                summary: t.summary || '',
                content: t.content || '',
              };
            }
          }
        );

        setTranslationsData(newTrans);
        setActiveTab('en');
        setErrorMsg(null);
        setIsModalOpen(true);
      }
    } catch (e) {
      console.error('Failed to fetch article for edit:', e);
    }
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    setErrorMsg(null);

    const payload = {
      slug: slug.trim().toLowerCase(),
      category,
      featuredImageUrl: featuredImageUrl.trim() || null,
      isPublished,
      translations: [
        { locale: 'en', ...translationsData.en },
        { locale: 'fr', ...translationsData.fr },
        { locale: 'ar', ...translationsData.ar },
      ].filter((t) => t.title.trim().length > 0),
    };

    try {
      let res;
      if (editingArticle) {
        res = await fetch(`/api/v1/articles/${editingArticle.slug}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload),
        });
      } else {
        res = await fetch('/api/v1/articles', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload),
        });
      }

      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.error || 'Failed to save article.');
      }

      setIsModalOpen(false);
      loadArticles();
    } catch (err: unknown) {
      setErrorMsg(err instanceof Error ? err.message : 'Failed to save.');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (artSlug: string) => {
    if (!confirm(`Are you sure you want to permanently delete article "${artSlug}"?`)) {
      return;
    }

    try {
      const res = await fetch(`/api/v1/articles/${artSlug}`, {
        method: 'DELETE',
      });
      if (res.ok) {
        loadArticles();
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
          <h1 className="text-2xl font-black text-white">Articles & Veterinary CMS</h1>
          <p className="text-xs text-slate-400 mt-1">
            Author and publish peer-reviewed poultry disease protocols and guides.
          </p>
        </div>

        <button
          onClick={handleOpenCreateModal}
          className="flex items-center gap-2 px-4 py-2.5 rounded-xl gold-gradient text-slate-950 font-bold text-xs shadow-md hover:scale-105 transition-all"
        >
          <Plus size={15} />
          <span>New Article</span>
        </button>
      </div>

      {/* Search Bar */}
      <div className="relative max-w-md">
        <Search size={15} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-500" />
        <input
          type="text"
          placeholder="Search by title or slug..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="w-full pl-10 pr-4 py-2 rounded-xl text-xs bg-slate-900 border border-slate-800 text-white focus:outline-none focus:border-amber-500"
        />
      </div>

      {/* Articles Table */}
      <div className="rounded-3xl bg-slate-900 border border-slate-800 overflow-hidden shadow-sm">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-slate-800/60 text-slate-400 uppercase tracking-wider text-[10px] font-bold border-b border-slate-800">
              <tr>
                <th className="px-6 py-3.5">Title & Slug</th>
                <th className="px-6 py-3.5">Category</th>
                <th className="px-6 py-3.5">Status</th>
                <th className="px-6 py-3.5">Created</th>
                <th className="px-6 py-3.5 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800 text-slate-300">
              {loading ? (
                <tr>
                  <td colSpan={5} className="px-6 py-8 text-center text-slate-500">
                    Loading articles...
                  </td>
                </tr>
              ) : filteredArticles.length > 0 ? (
                filteredArticles.map((art) => (
                  <tr key={art.id} className="hover:bg-slate-800/30 transition-colors">
                    <td className="px-6 py-4">
                      <span className="font-bold text-white block text-sm">{art.title}</span>
                      <span className="text-[11px] text-slate-500 font-mono">/{art.slug}</span>
                    </td>
                    <td className="px-6 py-4">
                      <span className="px-2.5 py-1 rounded-full text-[10px] font-bold uppercase bg-amber-500/10 text-amber-400">
                        {art.category.replace('_', ' ')}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      {art.isPublished ? (
                        <span className="inline-flex items-center gap-1 text-[11px] font-bold text-emerald-400">
                          <CheckCircle2 size={13} />
                          <span>Published</span>
                        </span>
                      ) : (
                        <span className="inline-flex items-center gap-1 text-[11px] font-bold text-slate-500">
                          <XCircle size={13} />
                          <span>Draft</span>
                        </span>
                      )}
                    </td>
                    <td className="px-6 py-4 text-slate-400 text-[11px]">
                      {new Date(art.createdAt).toLocaleDateString()}
                    </td>
                    <td className="px-6 py-4 text-right space-x-2">
                      <button
                        onClick={() => handleOpenEditModal(art)}
                        className="p-1.5 rounded-lg bg-slate-800 text-slate-300 hover:text-amber-400 hover:bg-slate-700 transition-colors"
                        title="Edit Article"
                      >
                        <Edit2 size={14} />
                      </button>
                      <button
                        onClick={() => handleDelete(art.slug)}
                        className="p-1.5 rounded-lg bg-slate-800 text-slate-300 hover:text-red-400 hover:bg-slate-700 transition-colors"
                        title="Delete Article"
                      >
                        <Trash2 size={14} />
                      </button>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan={5} className="px-6 py-8 text-center text-slate-500">
                    No articles found.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Trilingual Article Editor Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 bg-black/75 flex items-center justify-center p-4 overflow-y-auto">
          <div className="w-full max-w-3xl rounded-3xl bg-slate-900 border border-slate-800 p-6 sm:p-8 space-y-6 my-8 max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between pb-4 border-b border-slate-800">
              <h2 className="text-lg font-black text-white">
                {editingArticle ? `Edit Article: ${editingArticle.slug}` : 'Create New Article'}
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

            <form onSubmit={handleSave} className="space-y-6">
              {/* Core Metadata */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-bold text-slate-300 mb-1">
                    URL Slug (e.g. newcastle-disease-guide) *
                  </label>
                  <input
                    type="text"
                    required
                    disabled={!!editingArticle}
                    value={slug}
                    onChange={(e) => setSlug(e.target.value)}
                    className="w-full px-3 py-2 rounded-xl text-xs bg-slate-800 border border-slate-700 text-white focus:outline-none focus:border-amber-500 disabled:opacity-60"
                  />
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-300 mb-1">Category *</label>
                  <select
                    value={category}
                    onChange={(e) => setCategory(e.target.value)}
                    className="w-full px-3 py-2 rounded-xl text-xs bg-slate-800 border border-slate-700 text-white focus:outline-none focus:border-amber-500"
                  >
                    <option value="disease_guide">Disease & Biosecurity</option>
                    <option value="housing">Housing & Ventilation</option>
                    <option value="incubation">Incubation & Candling</option>
                    <option value="nutrition">Nutrition & Feed</option>
                    <option value="general">General Management</option>
                  </select>
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 items-center">
                <div className="sm:col-span-2">
                  <label className="block text-xs font-bold text-slate-300 mb-1">
                    Featured Image URL (Optional)
                  </label>
                  <input
                    type="url"
                    value={featuredImageUrl}
                    onChange={(e) => setFeaturedImageUrl(e.target.value)}
                    placeholder="https://images.unsplash.com/..."
                    className="w-full px-3 py-2 rounded-xl text-xs bg-slate-800 border border-slate-700 text-white focus:outline-none focus:border-amber-500"
                  />
                </div>

                <div className="pt-5">
                  <label className="flex items-center gap-2 cursor-pointer text-xs font-bold text-slate-300">
                    <input
                      type="checkbox"
                      checked={isPublished}
                      onChange={(e) => setIsPublished(e.target.checked)}
                      className="w-4 h-4 rounded text-amber-500 bg-slate-800 border-slate-700"
                    />
                    <span>Publish Immediately</span>
                  </label>
                </div>
              </div>

              {/* Trilingual Content Editor Tabs */}
              <div className="space-y-4 pt-2 border-t border-slate-800">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-bold text-amber-400 uppercase tracking-wider flex items-center gap-1.5">
                    <Globe size={14} />
                    <span>Multilingual Translations</span>
                  </span>

                  {/* Language Tab Buttons */}
                  <div className="flex items-center gap-1 p-1 bg-slate-800 rounded-xl">
                    {(['en', 'fr', 'ar'] as Locale[]).map((tab) => (
                      <button
                        key={tab}
                        type="button"
                        onClick={() => setActiveTab(tab)}
                        className={`px-3 py-1 rounded-lg text-xs font-bold uppercase transition-all ${
                          activeTab === tab
                            ? 'bg-amber-500 text-slate-950 shadow-sm'
                            : 'text-slate-400 hover:text-white'
                        }`}
                      >
                        {tab === 'ar' ? 'العربية' : tab}
                      </button>
                    ))}
                  </div>
                </div>

                {/* Active Tab Form Fields */}
                <div
                  className="space-y-4 p-4 rounded-2xl bg-slate-850 border border-slate-800"
                  dir={activeTab === 'ar' ? 'rtl' : 'ltr'}
                >
                  <div>
                    <label className="block text-xs font-bold text-slate-300 mb-1">
                      Title ({activeTab.toUpperCase()}) *
                    </label>
                    <input
                      type="text"
                      required={activeTab === 'en'}
                      value={translationsData[activeTab].title}
                      onChange={(e) =>
                        setTranslationsData({
                          ...translationsData,
                          [activeTab]: {
                            ...translationsData[activeTab],
                            title: e.target.value,
                          },
                        })
                      }
                      className="w-full px-3 py-2 rounded-xl text-xs bg-slate-800 border border-slate-700 text-white focus:outline-none focus:border-amber-500"
                    />
                  </div>

                  <div>
                    <label className="block text-xs font-bold text-slate-300 mb-1">
                      Summary ({activeTab.toUpperCase()})
                    </label>
                    <textarea
                      rows={2}
                      value={translationsData[activeTab].summary}
                      onChange={(e) =>
                        setTranslationsData({
                          ...translationsData,
                          [activeTab]: {
                            ...translationsData[activeTab],
                            summary: e.target.value,
                          },
                        })
                      }
                      className="w-full px-3 py-2 rounded-xl text-xs bg-slate-800 border border-slate-700 text-white focus:outline-none focus:border-amber-500"
                    />
                  </div>

                  <div>
                    <label className="block text-xs font-bold text-slate-300 mb-1">
                      Full Article Body ({activeTab.toUpperCase()} Markdown)
                    </label>
                    <textarea
                      rows={8}
                      value={translationsData[activeTab].content}
                      onChange={(e) =>
                        setTranslationsData({
                          ...translationsData,
                          [activeTab]: {
                            ...translationsData[activeTab],
                            content: e.target.value,
                          },
                        })
                      }
                      placeholder="Use markdown headers (###), bullet points, and clinical notes..."
                      className="w-full px-3 py-2 rounded-xl text-xs font-mono bg-slate-800 border border-slate-700 text-white focus:outline-none focus:border-amber-500"
                    />
                  </div>
                </div>
              </div>

              {/* Form Action Buttons */}
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
                  className="flex items-center gap-1.5 px-6 py-2.5 rounded-xl gold-gradient text-slate-950 font-bold text-xs shadow-md disabled:opacity-50"
                >
                  <Save size={14} />
                  <span>{saving ? 'Saving...' : 'Save Article'}</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
