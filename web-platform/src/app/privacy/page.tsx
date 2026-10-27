'use client';

import React from 'react';
import Link from 'next/link';
import { Shield, Lock, Trash2, Mail } from 'lucide-react';

export default function PrivacyPage() {
  return (
    <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-16 space-y-10">
      <div className="border-b border-slate-200 dark:border-slate-800 pb-6">
        <span className="text-xs font-bold text-amber-500 uppercase tracking-wider block mb-1">
          Google Play & Web Platform Compliance
        </span>
        <h1 className="text-3xl sm:text-4xl font-black text-slate-900 dark:text-white">
          Privacy Policy
        </h1>
        <p className="text-xs text-slate-400 mt-2">
          Effective Date: October 27, 2026 | Last Updated: October 27, 2026
        </p>
      </div>

      <div className="prose dark:prose-invert max-w-none text-xs sm:text-sm text-slate-700 dark:text-slate-300 leading-relaxed space-y-6">
        <section className="space-y-3">
          <h2 className="text-base sm:text-lg font-bold text-slate-900 dark:text-white">
            1. Introduction & Scope
          </h2>
          <p>
            Golden Roost (&quot;we&quot;, &quot;our&quot;, or &quot;us&quot;) provides the Golden Roost mobile application
            (Package ID: <code>com.goldenroost.app</code>) and the Golden Roost web platform
            (goldenroost.com). We are committed to protecting the privacy and operational data of
            poultry farmers, agricultural producers, and website visitors.
          </p>
        </section>

        <section className="space-y-3">
          <h2 className="text-base sm:text-lg font-bold text-slate-900 dark:text-white">
            2. Offline-First Farm Architecture & Local Storage
          </h2>
          <p>
            The primary farm operational data recorded within the Golden Roost mobile application—including
            flock counts, egg collection counts, feed purchase and consumption quantities, incubation
            cycles, bird mortality logs, and financial transactions—is stored locally on your device in an
            encrypted SQLite database.
          </p>
          <p>
            We do not transmit your farm business records to our servers unless you explicitly configure
            and initiate optional cloud backup synchronization. You retain 100% ownership of your farm
            data.
          </p>
        </section>

        <section className="space-y-3">
          <h2 className="text-base sm:text-lg font-bold text-slate-900 dark:text-white">
            3. Information We Collect
          </h2>
          <ul className="list-disc pl-5 space-y-2">
            <li>
              <strong>Push Notification Tokens:</strong> If you grant notification permissions, we collect
              a Firebase Cloud Messaging (FCM) registration token and preferred language/topics to send
              biosecurity alerts, disease warnings, and technical updates.
            </li>
            <li>
              <strong>Account Authentication Data:</strong> If you sign in to administrative services, we
              process your email address and Firebase User ID via Firebase Authentication.
            </li>
            <li>
              <strong>Affiliate Link Usage:</strong> When you click on retailer links in our product
              catalogue, external merchants (such as Amazon) may place cookies on your browser according
              to their own privacy policies.
            </li>
            <li>
              <strong>Advertising:</strong> Our mobile application may display Google AdMob banners, and
              our web platform may display Google AdSense ads. Google may use non-sensitive device
              identifiers to serve personalized or non-personalized advertisements.
            </li>
          </ul>
        </section>

        <section className="space-y-3">
          <h2 className="text-base sm:text-lg font-bold text-slate-900 dark:text-white">
            4. User Rights & Account Deletion Policy
          </h2>
          <p>
            In accordance with Google Play Developer Policies and global privacy regulations (including
            GDPR and CCPA), you have the right to request the total and permanent deletion of your account
            and all associated data.
          </p>
          <p>
            You can initiate data deletion directly inside the mobile app or via our dedicated web deletion
            portal at:{' '}
            <Link
              href="/delete-account"
              className="text-amber-600 dark:text-amber-400 font-bold hover:underline"
            >
              https://goldenroost.com/delete-account
            </Link>
          </p>
        </section>

        <section className="space-y-3">
          <h2 className="text-base sm:text-lg font-bold text-slate-900 dark:text-white">
            5. Security & Data Retention
          </h2>
          <p>
            All administrative communications between your browser, mobile app, and our serverless
            backend use Transport Layer Security (TLS 1.3). Database access is restricted to verified
            server sessions with role-based access control.
          </p>
        </section>

        <section className="space-y-3">
          <h2 className="text-base sm:text-lg font-bold text-slate-900 dark:text-white">
            6. Contact Our Data Protection Team
          </h2>
          <p>
            If you have questions, privacy inquiries, or wish to exercise your data rights, contact us at:
          </p>
          <p className="font-bold text-amber-600 dark:text-amber-400">
            Email: privacy@goldenroost.com
          </p>
        </section>
      </div>
    </div>
  );
}
