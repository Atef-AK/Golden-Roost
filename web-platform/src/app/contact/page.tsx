'use client';

import React, { useState } from 'react';
import { Mail, MessageSquare, Phone, Send, CheckCircle2 } from 'lucide-react';

export default function ContactPage() {
  const [submitted, setSubmitted] = useState(false);
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    subject: '',
    message: '',
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitted(true);
  };

  return (
    <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-16 space-y-12">
      <div className="text-center max-w-2xl mx-auto space-y-3">
        <span className="px-3 py-1 rounded-full bg-amber-500/10 text-amber-600 dark:text-amber-400 text-xs font-bold uppercase tracking-wider">
          Get in Touch
        </span>
        <h1 className="text-3xl sm:text-4xl font-black text-slate-900 dark:text-white">
          Contact Golden Roost Support
        </h1>
        <p className="text-xs sm:text-sm text-slate-600 dark:text-slate-400">
          Have questions about the app, partnership inquiries, or farm technical consulting? We are
          here to assist.
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
        {/* Support Channels */}
        <div className="space-y-4">
          <div className="p-6 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 shadow-sm space-y-2">
            <Mail className="text-amber-500" size={20} />
            <h3 className="text-sm font-bold text-slate-900 dark:text-white">Email Support</h3>
            <p className="text-xs text-slate-500">For general inquiries and bug reports:</p>
            <a
              href="mailto:support@goldenroost.com"
              className="text-xs font-bold text-amber-600 dark:text-amber-400 block hover:underline"
            >
              support@goldenroost.com
            </a>
          </div>

          <div className="p-6 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 shadow-sm space-y-2">
            <MessageSquare className="text-emerald-500" size={20} />
            <h3 className="text-sm font-bold text-slate-900 dark:text-white">Partnerships</h3>
            <p className="text-xs text-slate-500">For retail and affiliate collaborations:</p>
            <a
              href="mailto:partners@goldenroost.com"
              className="text-xs font-bold text-emerald-600 dark:text-emerald-400 block hover:underline"
            >
              partners@goldenroost.com
            </a>
          </div>
        </div>

        {/* Contact Form */}
        <div className="md:col-span-2 p-8 rounded-3xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 shadow-sm">
          {submitted ? (
            <div className="text-center py-12 space-y-3">
              <CheckCircle2 size={48} className="mx-auto text-emerald-500" />
              <h2 className="text-xl font-bold text-slate-900 dark:text-white">Message Received</h2>
              <p className="text-xs text-slate-500 max-w-md mx-auto">
                Thank you for contacting Golden Roost. Our team will review your inquiry and respond
                within 1–2 business days.
              </p>
              <button
                onClick={() => setSubmitted(false)}
                className="mt-4 px-6 py-2.5 rounded-xl text-xs font-bold gold-gradient text-slate-950"
              >
                Send Another Message
              </button>
            </div>
          ) : (
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1">
                    Your Name
                  </label>
                  <input
                    type="text"
                    required
                    value={formData.name}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    className="w-full px-3 py-2 rounded-xl text-xs bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white focus:outline-none focus:border-amber-500"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1">
                    Email Address
                  </label>
                  <input
                    type="email"
                    required
                    value={formData.email}
                    onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                    className="w-full px-3 py-2 rounded-xl text-xs bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white focus:outline-none focus:border-amber-500"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1">
                  Subject
                </label>
                <input
                  type="text"
                  required
                  value={formData.subject}
                  onChange={(e) => setFormData({ ...formData, subject: e.target.value })}
                  className="w-full px-3 py-2 rounded-xl text-xs bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white focus:outline-none focus:border-amber-500"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1">
                  Message
                </label>
                <textarea
                  required
                  rows={5}
                  value={formData.message}
                  onChange={(e) => setFormData({ ...formData, message: e.target.value })}
                  className="w-full px-3 py-2 rounded-xl text-xs bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white focus:outline-none focus:border-amber-500"
                />
              </div>

              <button
                type="submit"
                className="w-full flex items-center justify-center gap-2 py-3 rounded-xl gold-gradient text-slate-950 font-bold text-xs shadow-md hover:scale-[1.01] active:scale-[0.99] transition-all"
              >
                <Send size={14} />
                <span>Submit Inquiry</span>
              </button>
            </form>
          )}
        </div>
      </div>
    </div>
  );
}
