'use client';

import React, { useState, useRef } from 'react';
import {
  Bold,
  Italic,
  Heading2,
  Heading3,
  List,
  ListOrdered,
  Quote,
  Code,
  Link as LinkIcon,
  Image as ImageIcon,
  Table as TableIcon,
  Upload,
  Check,
  X,
} from 'lucide-react';

interface RichContentToolbarProps {
  textareaRef: React.RefObject<HTMLTextAreaElement | null>;
  value: string;
  onChange: (newValue: string) => void;
  accent?: 'amber' | 'emerald';
}

export default function RichContentToolbar({
  textareaRef,
  value,
  onChange,
  accent = 'amber',
}: RichContentToolbarProps) {
  const [isImageModalOpen, setIsImageModalOpen] = useState(false);
  const [imageMode, setImageMode] = useState<'upload' | 'url'>('upload');
  const [imageUrlInput, setImageUrlInput] = useState('');
  const [imageAltInput, setImageAltInput] = useState('');
  const [uploadedDataUrl, setUploadedDataUrl] = useState<string | null>(null);
  const [isCompressing, setIsCompressing] = useState(false);
  const fileInputRef = useRef<HTMLInputElement | null>(null);

  const isAmber = accent === 'amber';
  const activeBtnBg = isAmber
    ? 'hover:bg-amber-500/20 hover:text-amber-400 text-slate-300'
    : 'hover:bg-emerald-500/20 hover:text-emerald-400 text-slate-300';

  const insertText = (before: string, after: string = '', defaultText: string = '') => {
    const textarea = textareaRef.current;
    if (!textarea) {
      onChange(value + before + defaultText + after);
      return;
    }

    const start = textarea.selectionStart;
    const end = textarea.selectionEnd;
    const selected = value.substring(start, end) || defaultText;
    const replacement = before + selected + after;

    const newValue = value.substring(0, start) + replacement + value.substring(end);
    onChange(newValue);

    setTimeout(() => {
      textarea.focus();
      textarea.setSelectionRange(start + before.length, start + before.length + selected.length);
    }, 10);
  };

  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setIsCompressing(true);
    const reader = new FileReader();
    reader.onload = (readerEvent) => {
      const img = new Image();
      img.onload = () => {
        // Compress and scale to max 1200px width with high quality
        const canvas = document.createElement('canvas');
        let width = img.width;
        let height = img.height;
        const maxDimension = 1200;

        if (width > maxDimension || height > maxDimension) {
          if (width > height) {
            height = Math.round((height * maxDimension) / width);
            width = maxDimension;
          } else {
            width = Math.round((width * maxDimension) / height);
            height = maxDimension;
          }
        }

        canvas.width = width;
        canvas.height = height;
        const ctx = canvas.getContext('2d');
        if (ctx) {
          ctx.drawImage(img, 0, 0, width, height);
          const compressed = canvas.toDataURL('image/webp', 0.82);
          setUploadedDataUrl(compressed);
        } else {
          setUploadedDataUrl(readerEvent.target?.result as string);
        }
        setIsCompressing(false);
      };
      img.src = readerEvent.target?.result as string;
    };
    reader.readAsDataURL(file);
  };

  const handleConfirmImageInsert = () => {
    const finalUrl = imageMode === 'upload' ? uploadedDataUrl : imageUrlInput.trim();
    if (!finalUrl) return;

    const alt = imageAltInput.trim() || 'Visual Illustration';
    insertText(`\n\n![${alt}](${finalUrl})\n\n`, '', '');

    // Reset modal
    setIsImageModalOpen(false);
    setImageUrlInput('');
    setImageAltInput('');
    setUploadedDataUrl(null);
  };

  return (
    <div className="relative">
      {/* Toolbar Bar */}
      <div className="flex flex-wrap items-center gap-1 p-1.5 rounded-t-xl bg-slate-800/90 border border-b-0 border-slate-700 text-xs">
        {/* Bold */}
        <button
          type="button"
          onClick={() => insertText('**', '**', 'bold text')}
          className={`p-1.5 rounded-lg transition-colors ${activeBtnBg}`}
          title="Bold (Ctrl+B)"
        >
          <Bold size={14} />
        </button>

        {/* Italic */}
        <button
          type="button"
          onClick={() => insertText('*', '*', 'italic text')}
          className={`p-1.5 rounded-lg transition-colors ${activeBtnBg}`}
          title="Italic (Ctrl+I)"
        >
          <Italic size={14} />
        </button>

        <span className="w-px h-4 bg-slate-700 mx-0.5" />

        {/* Heading 2 */}
        <button
          type="button"
          onClick={() => insertText('\n## ', '\n', 'Section Heading')}
          className={`p-1.5 rounded-lg transition-colors ${activeBtnBg}`}
          title="Heading 2"
        >
          <Heading2 size={14} />
        </button>

        {/* Heading 3 */}
        <button
          type="button"
          onClick={() => insertText('\n### ', '\n', 'Subsection Title')}
          className={`p-1.5 rounded-lg transition-colors ${activeBtnBg}`}
          title="Heading 3"
        >
          <Heading3 size={14} />
        </button>

        <span className="w-px h-4 bg-slate-700 mx-0.5" />

        {/* Bullet List */}
        <button
          type="button"
          onClick={() => insertText('\n- ', '\n', 'List item')}
          className={`p-1.5 rounded-lg transition-colors ${activeBtnBg}`}
          title="Bullet List"
        >
          <List size={14} />
        </button>

        {/* Numbered List */}
        <button
          type="button"
          onClick={() => insertText('\n1. ', '\n', 'Step instruction')}
          className={`p-1.5 rounded-lg transition-colors ${activeBtnBg}`}
          title="Numbered List"
        >
          <ListOrdered size={14} />
        </button>

        {/* Quote */}
        <button
          type="button"
          onClick={() => insertText('\n> ', '\n', 'Clinical observation or quote')}
          className={`p-1.5 rounded-lg transition-colors ${activeBtnBg}`}
          title="Blockquote"
        >
          <Quote size={14} />
        </button>

        <span className="w-px h-4 bg-slate-700 mx-0.5" />

        {/* Code */}
        <button
          type="button"
          onClick={() => insertText('`', '`', 'code')}
          className={`p-1.5 rounded-lg transition-colors ${activeBtnBg}`}
          title="Inline Code"
        >
          <Code size={14} />
        </button>

        {/* Table */}
        <button
          type="button"
          onClick={() =>
            insertText(
              '\n\n| Parameter | Recommended Standard | Range |\n|---|---|---|\n| Temperature | 37.5°C | 37.2°C – 37.8°C |\n| Humidity | 55% | 50% – 60% |\n\n'
            )
          }
          className={`p-1.5 rounded-lg transition-colors ${activeBtnBg}`}
          title="Insert Table"
        >
          <TableIcon size={14} />
        </button>

        {/* Link */}
        <button
          type="button"
          onClick={() => insertText('[', '](https://example.com)', 'Link description')}
          className={`p-1.5 rounded-lg transition-colors ${activeBtnBg}`}
          title="Insert Link"
        >
          <LinkIcon size={14} />
        </button>

        {/* Add Image Button */}
        <button
          type="button"
          onClick={() => setIsImageModalOpen(true)}
          className={`flex items-center gap-1 px-2.5 py-1 rounded-lg font-bold transition-all ${
            isAmber
              ? 'bg-amber-500/20 text-amber-400 hover:bg-amber-500 hover:text-slate-950'
              : 'bg-emerald-500/20 text-emerald-400 hover:bg-emerald-500 hover:text-white'
          }`}
          title="Insert Image (Upload or URL)"
        >
          <ImageIcon size={14} />
          <span>Add Image</span>
        </button>
      </div>

      {/* Image Insertion Modal */}
      {isImageModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 backdrop-blur-sm animate-in fade-in duration-200">
          <div className="w-full max-w-md rounded-2xl bg-slate-900 border border-slate-800 p-6 shadow-2xl space-y-4">
            <div className="flex items-center justify-between">
              <h3 className="text-base font-bold text-white flex items-center gap-2">
                <ImageIcon size={18} className={isAmber ? 'text-amber-400' : 'text-emerald-400'} />
                <span>Insert Image into Content</span>
              </h3>
              <button
                type="button"
                onClick={() => setIsImageModalOpen(false)}
                className="p-1 rounded-lg text-slate-400 hover:text-white hover:bg-slate-800"
              >
                <X size={16} />
              </button>
            </div>

            {/* Mode Selector */}
            <div className="flex items-center gap-1 p-1 bg-slate-800 rounded-xl">
              <button
                type="button"
                onClick={() => setImageMode('upload')}
                className={`flex-1 py-1.5 text-xs font-bold rounded-lg transition-all ${
                  imageMode === 'upload'
                    ? isAmber
                      ? 'bg-amber-500 text-slate-950'
                      : 'bg-emerald-600 text-white'
                    : 'text-slate-400 hover:text-white'
                }`}
              >
                Upload File
              </button>
              <button
                type="button"
                onClick={() => setImageMode('url')}
                className={`flex-1 py-1.5 text-xs font-bold rounded-lg transition-all ${
                  imageMode === 'url'
                    ? isAmber
                      ? 'bg-amber-500 text-slate-950'
                      : 'bg-emerald-600 text-white'
                    : 'text-slate-400 hover:text-white'
                }`}
              >
                Image URL
              </button>
            </div>

            {/* Alt Caption */}
            <div>
              <label className="block text-xs font-semibold text-slate-300 mb-1">
                Image Caption / Description
              </label>
              <input
                type="text"
                placeholder="e.g. Broiler temperature candling chart"
                value={imageAltInput}
                onChange={(e) => setImageAltInput(e.target.value)}
                className="w-full px-3 py-2 rounded-xl text-xs bg-slate-800 border border-slate-700 text-white focus:outline-none focus:border-amber-500"
              />
            </div>

            {/* Mode 1: Upload */}
            {imageMode === 'upload' ? (
              <div className="space-y-3">
                <input
                  type="file"
                  ref={fileInputRef}
                  accept="image/*"
                  onChange={handleFileUpload}
                  className="hidden"
                />

                <div
                  onClick={() => fileInputRef.current?.click()}
                  className="cursor-pointer border-2 border-dashed border-slate-700 hover:border-amber-500 p-6 rounded-2xl flex flex-col items-center justify-center text-center transition-colors bg-slate-800/40"
                >
                  <Upload size={24} className="text-slate-400 mb-2" />
                  <span className="text-xs font-bold text-slate-200">
                    {isCompressing
                      ? 'Compressing image...'
                      : uploadedDataUrl
                      ? 'Click to choose a different photo'
                      : 'Choose photo from device'}
                  </span>
                  <span className="text-[11px] text-slate-500 mt-1">
                    PNG, JPG, WEBP — automatically optimized
                  </span>
                </div>

                {/* Preview */}
                {uploadedDataUrl && (
                  <div className="rounded-xl overflow-hidden border border-slate-700 max-h-48 bg-slate-950">
                    <img
                      src={uploadedDataUrl}
                      alt="Preview"
                      className="w-full h-44 object-contain"
                    />
                  </div>
                )}
              </div>
            ) : (
              /* Mode 2: URL */
              <div className="space-y-3">
                <div>
                  <label className="block text-xs font-semibold text-slate-300 mb-1">
                    Direct Image URL
                  </label>
                  <input
                    type="url"
                    placeholder="https://images.unsplash.com/photo-..."
                    value={imageUrlInput}
                    onChange={(e) => setImageUrlInput(e.target.value)}
                    className="w-full px-3 py-2 rounded-xl text-xs bg-slate-800 border border-slate-700 text-white focus:outline-none focus:border-amber-500 font-mono"
                  />
                </div>

                {imageUrlInput.trim() && (
                  <div className="rounded-xl overflow-hidden border border-slate-700 max-h-48 bg-slate-950">
                    <img
                      src={imageUrlInput}
                      alt="Preview"
                      onError={(e) => {
                        (e.target as HTMLElement).style.display = 'none';
                      }}
                      className="w-full h-44 object-contain"
                    />
                  </div>
                )}
              </div>
            )}

            {/* Actions */}
            <div className="flex items-center justify-end gap-3 pt-3 border-t border-slate-800">
              <button
                type="button"
                onClick={() => setIsImageModalOpen(false)}
                className="px-4 py-2 rounded-xl text-xs font-bold text-slate-400 hover:text-white"
              >
                Cancel
              </button>
              <button
                type="button"
                disabled={
                  (imageMode === 'upload' && !uploadedDataUrl) ||
                  (imageMode === 'url' && !imageUrlInput.trim()) ||
                  isCompressing
                }
                onClick={handleConfirmImageInsert}
                className={`flex items-center gap-1.5 px-5 py-2.5 rounded-xl font-bold text-xs shadow-md disabled:opacity-50 transition-all ${
                  isAmber
                    ? 'gold-gradient text-slate-950'
                    : 'bg-emerald-600 text-white hover:bg-emerald-500'
                }`}
              >
                <Check size={14} />
                <span>Insert Image</span>
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
