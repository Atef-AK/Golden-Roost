'use client';

import React from 'react';
import Link from 'next/link';
import { ShieldCheck, Heart, Award, Cpu, Users, ArrowRight } from 'lucide-react';

export default function AboutPage() {
  return (
    <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-16 space-y-16">
      {/* Header */}
      <div className="text-center max-w-3xl mx-auto space-y-4">
        <span className="px-3 py-1 rounded-full bg-amber-500/10 text-amber-600 dark:text-amber-400 text-xs font-bold uppercase tracking-wider">
          Our Mission
        </span>
        <h1 className="text-4xl sm:text-5xl font-black text-slate-900 dark:text-white">
          Revolutionizing Poultry Farming Through Practical Technology
        </h1>
        <p className="text-base sm:text-lg text-slate-600 dark:text-slate-400 leading-relaxed">
          Golden Roost was founded on a simple principle: Agricultural technology must work in the
          real world—where mobile connectivity is spotty, dust is plentiful, and timing is
          everything.
        </p>
      </div>

      {/* Story & Philosophy */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
        <div className="p-8 rounded-3xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 shadow-sm space-y-3">
          <div className="w-12 h-12 rounded-2xl bg-amber-500/10 text-amber-500 flex items-center justify-center font-bold">
            <Cpu size={24} />
          </div>
          <h2 className="text-lg font-bold text-slate-900 dark:text-white">Offline-First Engine</h2>
          <p className="text-xs sm:text-sm text-slate-600 dark:text-slate-400 leading-relaxed">
            Your poultry coops and brooding pens should not be held hostage by cell reception. Every
            single feature in Golden Roost functions without internet, synchronizing seamlessly
            whenever connection is restored.
          </p>
        </div>

        <div className="p-8 rounded-3xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 shadow-sm space-y-3">
          <div className="w-12 h-12 rounded-2xl bg-emerald-500/10 text-emerald-500 flex items-center justify-center font-bold">
            <ShieldCheck size={24} />
          </div>
          <h2 className="text-lg font-bold text-slate-900 dark:text-white">Veterinary Rigor</h2>
          <p className="text-xs sm:text-sm text-slate-600 dark:text-slate-400 leading-relaxed">
            Our educational articles and clinical protocols are formulated according to international
            veterinary standards for Newcastle, Gumboro (IBD), and infectious bronchitis biosecurity.
          </p>
        </div>

        <div className="p-8 rounded-3xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 shadow-sm space-y-3">
          <div className="w-12 h-12 rounded-2xl bg-amber-500/10 text-amber-500 flex items-center justify-center font-bold">
            <Award size={24} />
          </div>
          <h2 className="text-lg font-bold text-slate-900 dark:text-white">Producer Profitability</h2>
          <p className="text-xs sm:text-sm text-slate-600 dark:text-slate-400 leading-relaxed">
            By eliminating feed waste through predictive depletion algorithms and minimizing chick
            mortality during incubation, we help farmers achieve industry-leading margins.
          </p>
        </div>
      </div>

      {/* Call to Action */}
      <div className="rounded-3xl bg-slate-900 p-8 sm:p-12 text-center text-white space-y-4">
        <h2 className="text-2xl sm:text-3xl font-black">Ready to modernize your flock management?</h2>
        <p className="text-xs sm:text-sm text-slate-400 max-w-xl mx-auto">
          Download Golden Roost for Android today or explore our comprehensive guides to take your
          farm to peak performance.
        </p>
        <div className="pt-2 flex flex-wrap justify-center gap-4">
          <a
            href="https://play.google.com/store/apps/details?id=com.goldenroost.app"
            target="_blank"
            rel="noopener noreferrer"
            className="px-6 py-3 rounded-xl gold-gradient text-slate-950 font-bold text-xs"
          >
            Download Android App
          </a>
          <Link
            href="/articles"
            className="px-6 py-3 rounded-xl border border-slate-700 font-bold text-xs hover:bg-slate-800"
          >
            Explore Guides
          </Link>
        </div>
      </div>
    </div>
  );
}
