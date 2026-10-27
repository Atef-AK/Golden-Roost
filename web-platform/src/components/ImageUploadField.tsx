'use client';

import React, { useRef, useState } from 'react';
import { Upload, X, Image as ImageIcon, Check } from 'lucide-react';

interface ImageUploadFieldProps {
  label: string;
  value: string;
  onChange: (val: string) => void;
  placeholder?: string;
  accent?: 'amber' | 'emerald';
}

export default function ImageUploadField({
  label,
  value,
  onChange,
  placeholder = 'https://...',
  accent = 'amber',
}: ImageUploadFieldProps) {
  const fileInputRef = useRef<HTMLInputElement | null>(null);
  const [isCompressing, setIsCompressing] = useState(false);
  const isAmber = accent === 'amber';

  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setIsCompressing(true);
    const reader = new FileReader();
    reader.onload = (readerEvent) => {
      const img = new Image();
      img.onload = () => {
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
          onChange(compressed);
        } else {
          onChange(readerEvent.target?.result as string);
        }
        setIsCompressing(false);
      };
      img.src = readerEvent.target?.result as string;
    };
    reader.readAsDataURL(file);
  };

  return (
    <div className="space-y-2">
      <div className="flex items-center justify-between">
        <label className="block text-xs font-bold text-slate-300">{label}</label>
        <button
          type="button"
          onClick={() => fileInputRef.current?.click()}
          className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg text-[11px] font-bold transition-all ${
            isAmber
              ? 'bg-amber-500/15 text-amber-400 hover:bg-amber-500 hover:text-slate-950'
              : 'bg-emerald-500/15 text-emerald-400 hover:bg-emerald-500 hover:text-white'
          }`}
        >
          <Upload size={12} />
          <span>{isCompressing ? 'Compressing...' : 'Upload from Device'}</span>
        </button>
      </div>

      <input
        type="file"
        ref={fileInputRef}
        accept="image/*"
        onChange={handleFileUpload}
        className="hidden"
      />

      {/* URL Input */}
      <div className="relative">
        <input
          type="text"
          value={value}
          onChange={(e) => onChange(e.target.value)}
          placeholder={placeholder}
          className="w-full px-3 py-2 rounded-xl text-xs bg-slate-800 border border-slate-700 text-white focus:outline-none focus:border-amber-500 pr-8"
        />
        {value && (
          <button
            type="button"
            onClick={() => onChange('')}
            className="absolute right-2.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-white"
            title="Clear image"
          >
            <X size={14} />
          </button>
        )}
      </div>

      {/* Image Preview Thumbnail */}
      {value && (
        <div className="relative rounded-2xl overflow-hidden border border-slate-700 bg-slate-950 p-1 flex items-center justify-center max-h-40 group">
          <img
            src={value}
            alt="Thumbnail preview"
            onError={(e) => {
              (e.target as HTMLElement).style.display = 'none';
            }}
            className="max-h-36 object-contain rounded-xl"
          />
          <div className="absolute top-2 right-2 flex items-center gap-1 bg-black/60 backdrop-blur-md px-2 py-1 rounded-lg text-[10px] text-emerald-400 font-bold">
            <Check size={12} />
            <span>Image Active</span>
          </div>
        </div>
      )}
    </div>
  );
}
