# Golden Roost — Web Platform, Admin CMS & Cloud Integration Guide

This document describes the architecture, database schema, administrative portal, and deployment steps for the **Golden Roost** web platform and Flutter mobile integration.

---

## 1. Architecture Overview

```
                                +-----------------------------+
                                |    Firebase Authentication  |
                                |  (Email/Password Admin Auth)|
                                +--------------+--------------+
                                               | ID Token
                                               v
+--------------------------+    HTTPS     +----+------------------------+    PostgreSQL   +-------------------------+
|   Flutter Mobile App     | <----------> |     Next.js 16 Web Platform  | <-------------> |     Neon.tech Database   |
| (com.goldenroost.app)    |              |     (Hosted on Vercel)      |   (Serverless)  |   (Authoritative Rel.)  |
| 100% Offline SQLite Farm |              |  - Public Portal & SEO      |                 | - admin_users (RBAC)    |
| Native AdMob SDK         |              |  - Protected Admin CMS      |                 | - articles & products   |
| Pull-to-Refresh Sync     |              |  - FCM Notification Engine  |                 | - push_devices (FCM)    |
| FCM Push Subscriptions   |              |  - Google Play Deletion API |                 | - audit logs & scheduler|
+--------------------------+              +-----------------------------+                 +-------------------------+
```

---

## 2. Directory Structure

```
├── lib/                             # Flutter Mobile Application (com.goldenroost.app)
│   ├── core/                        # DatabaseHelper (SQLite), AdService (AdMob), SyncService
│   ├── models/                      # Flock, Feed, IncubationBatch, Article, FinanceRecord
│   ├── providers/                   # Riverpod state notifiers (offline-first + remote sync)
│   └── views/                       # Modern responsive UI screens with Arabic RTL support
└── web-platform/                    # Next.js 16.4.3 Web Platform & Admin CMS
    ├── drizzle/                     # Authoritative PostgreSQL SQL migrations
    │   └── 0000_narrow_scarlet_witch.sql
    ├── scripts/
    │   ├── bootstrap-admin.ts       # Superadmin account provisioning script
    │   └── seed.ts                  # Curated articles, products, and monetization seeder
    ├── src/
    │   ├── app/                     # Next.js App Router pages and API routes
    │   │   ├── (public pages)       # /, /articles, /products, /about, /contact, /privacy
    │   │   ├── delete-account/      # Verified account deletion portal (Google Play compliance)
    │   │   ├── admin/               # Protected administration console (/admin/*)
    │   │   └── api/                 # Secure REST & Cron endpoints (/api/v1/*, /api/cron/*)
    │   ├── db/                      # Neon serverless client & Drizzle ORM schema
    │   ├── lib/                     # Auth verifier, rate limiter, audit logger, Firebase SDKs
    │   └── components/              # Responsive Navbar, Footer, AdSenseBanner
    ├── drizzle.config.ts            # Drizzle kit configuration
    ├── vercel.json                  # Vercel Cron configuration for push campaigns
    └── .env.example                 # Production environment variable reference
```

---

## 3. Security Model

1. **Zero Hardcoded PINs or Secrets**: All legacy mobile PIN backdoors have been completely removed. Privileged actions require authenticated administrative sessions.
2. **Server-Side HTTP-Only Cookies**: Admin login exchanges Firebase ID tokens for 5-day secure `HttpOnly` session cookies (`gr_admin_session`) with `SameSite=Lax`.
3. **Authoritative Neon Live RBAC**: On every single administrative request, the server executes a live check against `admin_users` in Neon PostgreSQL:
   - Validates `is_active = true` (instant deactivation).
   - Dynamically reads the current role (`superadmin`, `editor`, `viewer`).
4. **Serverless Rate Limiting**: All sensitive endpoints (`/api/v1/admin/auth/session`, `/api/v1/account-deletion/*`, `/api/v1/mobile/devices/register`) use atomic PostgreSQL rate-limit counters (`rate_limit_buckets`) to prevent brute force without relying on in-memory state.
5. **CSRF Validation**: Mutation endpoints validate request `Origin` and `Referer` headers against the hosting domain.

---

## 4. Neon PostgreSQL Setup & Migrations

### 4.1. Apply Schema Migrations
In the Neon Console (or via CLI), set your connection string in `web-platform/.env.local`:
```bash
DATABASE_URL="postgresql://user:password@ep-sample-pooler.region.neon.tech/neondb?sslmode=require"
```
Execute Drizzle migrations:
```bash
cd web-platform
npx drizzle-kit migrate
```
Or execute the SQL migration file directly in the Neon SQL Editor:
`web-platform/drizzle/0000_narrow_scarlet_witch.sql`

### 4.2. Seed Default Knowledge & Products
Populate trilingual veterinary guides (Newcastle, Ventilation, Incubation) and certified equipment:
```bash
npx tsx scripts/seed.ts
```

### 4.3. Bootstrap Superadmin Account
Provision your administrative email:
```bash
npx tsx scripts/bootstrap-admin.ts admin@goldenroost.com
```

---

## 5. Vercel Deployment Instructions

1. Push code to your GitHub repository: `https://github.com/Atef-AK/Golden-Roost.git`.
2. In the [Vercel Dashboard](https://vercel.com):
   - **Import Repository**: `Golden-Roost`
   - **Root Directory**: `web-platform`
   - **Framework Preset**: `Next.js`
   - **Node.js Version**: `22.x`
3. Configure **Environment Variables** in Vercel Project Settings:
   - `DATABASE_URL`: Your pooled Neon connection string.
   - `FIREBASE_ADMIN_PROJECT_ID`: Firebase project ID (`golden-roost-app`).
   - `FIREBASE_ADMIN_CLIENT_EMAIL`: Service account email.
   - `FIREBASE_ADMIN_PRIVATE_KEY`: Private key string (including newlines).
   - `NEXT_PUBLIC_FIREBASE_API_KEY`: Firebase web API key.
   - `NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN`: `golden-roost-app.firebaseapp.com`.
   - `NEXT_PUBLIC_FIREBASE_PROJECT_ID`: `golden-roost-app`.
   - `CRON_SECRET`: Random 32+ character token protecting `/api/cron/*`.
4. Deploy! Vercel will build the Next.js 16 application and configure the cron schedule from `vercel.json`.

---

## 6. Google Play Store Dual-Channel Account Deletion Compliance

Google Play requires applications with accounts or persistent device tokens to provide a publicly accessible web deletion portal:
- **Public URL**: `https://goldenroost.com/delete-account`
- **Verification Workflow**:
  1. User submits their email on `/delete-account`.
  2. Server generates a cryptographically secure 24-hour token in `account_deletion_requests`.
  3. User clicks verification link sent to their email (or direct verification in test environments).
  4. Server purges associated push notification tokens, cloud sync records, and administrative memberships.
  5. User is shown a verified confirmation screen.
