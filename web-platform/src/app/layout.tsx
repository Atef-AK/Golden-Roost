import type { Metadata } from 'next';
import { Geist, Geist_Mono } from 'next/font/google';
import './globals.css';
import Navbar from '@/components/Navbar';
import Footer from '@/components/Footer';

const geistSans = Geist({
  variable: '--font-geist-sans',
  subsets: ['latin'],
});

const geistMono = Geist_Mono({
  variable: '--font-geist-mono',
  subsets: ['latin'],
});

export const metadata: Metadata = {
  title: 'Golden Roost — Smart Poultry Farm Management & Knowledge Platform',
  description:
    'Production-grade poultry farm management platform. Track flocks, eggs, feed depletion, incubation schedules, and farm finances 100% offline, coupled with peer-reviewed veterinary guides and certified equipment.',
  keywords: [
    'poultry farm management',
    'egg production tracking',
    'broiler flock management',
    'poultry feed formulation',
    'chicken incubation schedule',
    'poultry disease guide',
    'Newcastle disease vaccination',
    'poultry farm software',
  ],
  authors: [{ name: 'Golden Roost Team' }],
  openGraph: {
    title: 'Golden Roost — Precision Poultry Farm Management',
    description:
      'Manage broiler and layer flocks, feed depletion, and incubation offline, while accessing expert veterinary advice.',
    url: 'https://goldenroost.com',
    siteName: 'Golden Roost',
    locale: 'en_US',
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Golden Roost — Precision Poultry Farm Management',
    description: 'Empowering poultry farmers with offline-first tracking and veterinary expertise.',
  },
  robots: {
    index: true,
    follow: true,
  },
};

import React, { Suspense } from 'react';

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className={`${geistSans.variable} ${geistMono.variable} h-full antialiased`}>
      <body className="min-h-full flex flex-col bg-slate-50 dark:bg-slate-950 text-slate-900 dark:text-slate-100 transition-colors">
        <Suspense fallback={<div className="h-20" />}>
          <Navbar />
        </Suspense>
        <main className="flex-1">{children}</main>
        <Suspense fallback={null}>
          <Footer />
        </Suspense>
      </body>
    </html>
  );
}
