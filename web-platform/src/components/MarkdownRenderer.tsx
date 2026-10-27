'use client';

import React from 'react';

interface MarkdownRendererProps {
  content: string;
  className?: string;
}

export default function MarkdownRenderer({ content, className = '' }: MarkdownRendererProps) {
  if (!content || !content.trim()) {
    return <div className="text-slate-400 italic text-sm">No content provided.</div>;
  }

  // Parse lines into blocks
  const blocks: React.ReactNode[] = [];
  const lines = content.split('\n');
  let i = 0;

  const parseInline = (text: string): React.ReactNode => {
    // Process markdown links [text](url)
    const linkRegex = /\[([^\]]+)\]\(([^)]+)\)/g;
    // Process images ![alt](url)
    const imageRegex = /!\[([^\]]*)\]\(([^)]+)\)/g;
    // Process bold **text** or __text__
    const boldRegex = /\*\*([^*]+)\*\*/g;
    // Process italic *text* or _text_
    const italicRegex = /\*([^*]+)\*/g;
    // Process inline code `code`
    const codeRegex = /`([^`]+)`/g;

    // Check if the whole text is an image tag
    const imgMatch = text.match(/^!\[([^\]]*)\]\(([^)]+)\)$/);
    if (imgMatch) {
      const alt = imgMatch[1];
      const src = imgMatch[2];
      return (
        <figure className="my-6 rounded-2xl overflow-hidden border border-slate-200 dark:border-slate-800 shadow-md bg-slate-100 dark:bg-slate-900 group">
          <img
            src={src}
            alt={alt || 'Article visual'}
            className="w-full max-h-[460px] object-cover transition-transform duration-300 group-hover:scale-[1.01]"
            loading="lazy"
          />
          {alt && (
            <figcaption className="p-3 text-center text-xs text-slate-500 dark:text-slate-400 italic border-t border-slate-100 dark:border-slate-800/60 bg-white/50 dark:bg-slate-900/50">
              {alt}
            </figcaption>
          )}
        </figure>
      );
    }

    // Replace images inline if mixed
    const parts: (string | React.ReactNode)[] = [text];

    // Helper to replace pattern in parts
    const replacePattern = (
      regex: RegExp,
      renderFn: (match: RegExpExecArray, key: string) => React.ReactNode
    ) => {
      for (let pIdx = 0; pIdx < parts.length; pIdx++) {
        const part = parts[pIdx];
        if (typeof part !== 'string') continue;

        regex.lastIndex = 0;
        let match = regex.exec(part);
        if (!match) continue;

        const before = part.slice(0, match.index);
        const after = part.slice(match.index + match[0].length);
        const rendered = renderFn(match, `${pIdx}-${match.index}`);

        parts.splice(pIdx, 1, before, rendered, after);
        pIdx += 1; // skip past inserted item
      }
    };

    // Images
    replacePattern(imageRegex, (m, k) => (
      <figure
        key={`img-${k}`}
        className="my-4 rounded-2xl overflow-hidden border border-slate-200 dark:border-slate-800 shadow-sm bg-slate-100 dark:bg-slate-900"
      >
        <img src={m[2]} alt={m[1] || 'Embedded visual'} className="w-full max-h-[440px] object-cover" />
        {m[1] && (
          <figcaption className="p-2 text-center text-xs text-slate-500 dark:text-slate-400 italic">
            {m[1]}
          </figcaption>
        )}
      </figure>
    ));

    // Links
    replacePattern(linkRegex, (m, k) => (
      <a
        key={`link-${k}`}
        href={m[2]}
        target="_blank"
        rel="noopener noreferrer"
        className="text-amber-600 dark:text-amber-400 font-semibold underline underline-offset-2 hover:text-amber-500"
      >
        {m[1]}
      </a>
    ));

    // Bold
    replacePattern(boldRegex, (m, k) => (
      <strong key={`b-${k}`} className="font-bold text-slate-900 dark:text-white">
        {m[1]}
      </strong>
    ));

    // Italic
    replacePattern(italicRegex, (m, k) => (
      <em key={`i-${k}`} className="italic text-slate-800 dark:text-slate-200">
        {m[1]}
      </em>
    ));

    // Code
    replacePattern(codeRegex, (m, k) => (
      <code
        key={`c-${k}`}
        className="px-1.5 py-0.5 rounded bg-slate-200 dark:bg-slate-800 text-amber-600 dark:text-amber-400 font-mono text-xs"
      >
        {m[1]}
      </code>
    ));

    return parts;
  };

  while (i < lines.length) {
    const rawLine = lines[i];
    const trimmed = rawLine.trim();

    if (!trimmed) {
      i++;
      continue;
    }

    // Markdown Table
    if (trimmed.startsWith('|') && trimmed.endsWith('|')) {
      const tableLines: string[] = [];
      while (i < lines.length && lines[i].trim().startsWith('|') && lines[i].trim().endsWith('|')) {
        tableLines.push(lines[i].trim());
        i++;
      }

      if (tableLines.length >= 2) {
        const parseRow = (line: string) =>
          line
            .split('|')
            .slice(1, -1)
            .map((c) => c.trim());

        const headers = parseRow(tableLines[0]);
        const isDivider = (line: string) => /^\|[-:\s|]+\|$/.test(line);
        const dataRows = (isDivider(tableLines[1]) ? tableLines.slice(2) : tableLines.slice(1)).map(
          parseRow
        );

        blocks.push(
          <div
            key={`table-${i}`}
            className="my-6 overflow-x-auto rounded-2xl border border-slate-200 dark:border-slate-800 shadow-sm"
          >
            <table className="w-full text-left text-xs sm:text-sm">
              <thead className="bg-slate-100 dark:bg-slate-800/80 text-slate-700 dark:text-slate-200 uppercase tracking-wider text-[11px] font-bold border-b border-slate-200 dark:border-slate-800">
                <tr>
                  {headers.map((h, hIdx) => (
                    <th key={hIdx} className="px-4 py-3">
                      {h}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 dark:divide-slate-800 bg-white dark:bg-slate-900">
                {dataRows.map((row, rIdx) => (
                  <tr key={rIdx} className="hover:bg-slate-50 dark:hover:bg-slate-850/60 transition-colors">
                    {row.map((cell, cIdx) => (
                      <td key={cIdx} className="px-4 py-3 text-slate-700 dark:text-slate-300">
                        {parseInline(cell)}
                      </td>
                    ))}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        );
        continue;
      }
    }

    // Code Blocks (``` ... ```)
    if (trimmed.startsWith('```')) {
      const lang = trimmed.slice(3).trim();
      i++;
      const codeLines: string[] = [];
      while (i < lines.length && !lines[i].trim().startsWith('```')) {
        codeLines.push(lines[i]);
        i++;
      }
      if (i < lines.length && lines[i].trim().startsWith('```')) {
        i++;
      }

      blocks.push(
        <div
          key={`code-${i}`}
          className="my-5 rounded-2xl overflow-hidden border border-slate-200 dark:border-slate-800 bg-slate-900 text-slate-100"
        >
          {lang && (
            <div className="px-4 py-1.5 bg-slate-800/80 border-b border-slate-800 text-[10px] font-bold uppercase tracking-wider text-amber-400">
              {lang}
            </div>
          )}
          <pre className="p-4 overflow-x-auto text-xs sm:text-sm font-mono leading-relaxed">
            <code>{codeLines.join('\n')}</code>
          </pre>
        </div>
      );
      continue;
    }

    // Headings
    if (trimmed.startsWith('# ')) {
      blocks.push(
        <h1 key={`h1-${i}`} className="text-2xl sm:text-3xl font-black text-slate-900 dark:text-white mt-8 mb-4 tracking-tight leading-tight">
          {parseInline(trimmed.slice(2))}
        </h1>
      );
      i++;
      continue;
    }
    if (trimmed.startsWith('## ')) {
      blocks.push(
        <h2 key={`h2-${i}`} className="text-xl sm:text-2xl font-bold text-slate-900 dark:text-white mt-7 mb-3 pb-2 border-b border-slate-200 dark:border-slate-800 tracking-tight">
          {parseInline(trimmed.slice(3))}
        </h2>
      );
      i++;
      continue;
    }
    if (trimmed.startsWith('### ')) {
      blocks.push(
        <h3 key={`h3-${i}`} className="text-lg sm:text-xl font-bold text-amber-600 dark:text-amber-400 mt-5 mb-2">
          {parseInline(trimmed.slice(4))}
        </h3>
      );
      i++;
      continue;
    }
    if (trimmed.startsWith('#### ')) {
      blocks.push(
        <h4 key={`h4-${i}`} className="text-base font-bold text-slate-800 dark:text-slate-200 mt-4 mb-1">
          {parseInline(trimmed.slice(5))}
        </h4>
      );
      i++;
      continue;
    }

    // Horizontal Rule
    if (trimmed === '---' || trimmed === '***' || trimmed === '___') {
      blocks.push(
        <hr key={`hr-${i}`} className="my-8 border-slate-200 dark:border-slate-800" />
      );
      i++;
      continue;
    }

    // Blockquotes
    if (trimmed.startsWith('>')) {
      const quoteLines: string[] = [];
      while (i < lines.length && lines[i].trim().startsWith('>')) {
        quoteLines.push(lines[i].trim().replace(/^>\s*/, ''));
        i++;
      }
      blocks.push(
        <blockquote
          key={`quote-${i}`}
          className="my-5 p-4 rounded-2xl bg-amber-50 dark:bg-amber-950/20 border-l-4 border-amber-500 text-slate-800 dark:text-slate-200 text-sm sm:text-base italic leading-relaxed"
        >
          {parseInline(quoteLines.join(' '))}
        </blockquote>
      );
      continue;
    }

    // Bullet Lists (- or *)
    if (/^[-*]\s+/.test(trimmed)) {
      const listItems: string[] = [];
      while (i < lines.length && /^[-*]\s+/.test(lines[i].trim())) {
        listItems.push(lines[i].trim().replace(/^[-*]\s+/, ''));
        i++;
      }
      blocks.push(
        <ul key={`ul-${i}`} className="my-4 space-y-2 list-none text-sm sm:text-base text-slate-700 dark:text-slate-300">
          {listItems.map((item, idx) => (
            <li key={idx} className="flex items-start gap-2.5">
              <span className="w-1.5 h-1.5 rounded-full bg-amber-500 mt-2 shrink-0" />
              <span>{parseInline(item)}</span>
            </li>
          ))}
        </ul>
      );
      continue;
    }

    // Numbered Lists (1. 2.)
    if (/^\d+\.\s+/.test(trimmed)) {
      const listItems: string[] = [];
      while (i < lines.length && /^\d+\.\s+/.test(lines[i].trim())) {
        listItems.push(lines[i].trim().replace(/^\d+\.\s+/, ''));
        i++;
      }
      blocks.push(
        <ol key={`ol-${i}`} className="my-4 space-y-2 list-decimal list-inside text-sm sm:text-base text-slate-700 dark:text-slate-300 font-medium">
          {listItems.map((item, idx) => (
            <li key={idx} className="leading-relaxed">
              <span className="text-slate-700 dark:text-slate-300 font-normal">{parseInline(item)}</span>
            </li>
          ))}
        </ol>
      );
      continue;
    }

    // Standalone Image
    if (/^!\[([^\]]*)\]\(([^)]+)\)$/.test(trimmed)) {
      blocks.push(
        <div key={`img-block-${i}`}>
          {parseInline(trimmed)}
        </div>
      );
      i++;
      continue;
    }

    // Regular Paragraph
    blocks.push(
      <p key={`p-${i}`} className="my-3 text-sm sm:text-base text-slate-700 dark:text-slate-300 leading-relaxed font-normal">
        {parseInline(trimmed)}
      </p>
    );
    i++;
  }

  return <div className={`space-y-1 ${className}`}>{blocks}</div>;
}
