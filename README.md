# Golden Roost — Poultry Farm Management Platform 🐔🥚🐣

**Golden Roost** (`com.goldenroost.app`) is an Android-first, production-grade, offline-first Flutter application designed for commercial poultry producers, hatcheries, and homesteaders. Built with Riverpod, SQLite (Schema v4), GoRouter, and a Firebase Cloud Bridge, it manages the complete end-to-end lifecycle of poultry operations: raising chickens, quails, ducks, and custom species, tracking egg collection and commercial sales, managing multi-stage incubator batches with hatch wizards, scheduling veterinary care and daily tasks with local notifications, providing peer-reviewed veterinary advisory articles, curated equipment recommendations, and tracking exact financial performance and electricity costs.

---

## 🌟 Key Capabilities & Modules

### 1. 📊 Real-Time Operations Dashboard
- **Top Metric Cards**: Live bird population, eggs collected today, feed stock with estimated depletion countdown, today's income/expenses, and current-month net operating result.
- **Urgent Action Center**: Active incubator batches countdown alerts, upcoming vaccinations, and overdue task warnings.
- **Interactive Timeline**: Real-time chronological audit trail of all farm operations.
- **Quick-Action Bottom Sheet**: 1-tap logging for daily feed, water inspections, egg collection, bird sales, mortalities, expenses, incubation events, and custom tasks.

### 2. 🐓 Flock & Bird Lifecycle Management
- **Multi-Species Support**: Built-in support for chickens (e.g. Lohmann Brown, Rhode Island Red), quails (e.g. Coturnix), ducks, turkeys, geese, and custom species.
- **Purpose Categorization**: Layers, Meat/Broilers, Breeders, or Dual-Purpose/Mixed.
- **Exact Population Accounting**: Tracks starting birds, purchases, hatches/intakes, natural mortalities, culls, and sales. Live count automatically recalculates from movement ledger without discrepancies.
- **Deterministic Sex Breakdown**: Base counts are anchored to immutable starting counts (`startMaleCount`, `startFemaleCount`) to eliminate drift over time.
- **Layer Eligibility Isolation**: Laying rate denominators strictly filter for mature layer females (≥ 18 weeks for chickens, ≥ 6 weeks for quails; excludes meat/broiler flocks).
- **Historical Back-Entry**: Back-date existing flocks to their true acquisition or hatch date.

### 3. 🥚 Egg Inventory & Reservation Engine
- **Daily Harvesting**: Separate logging for clean eggs, cracked, damaged, and rejects.
- **Inventory Reservation Math**: Available saleable eggs are computed as `Total Gathered - Incubation Eggs Set - Already Sold`.
- **Overselling Prevention**: Commercial sales forms validate available stock in real-time, preventing negative egg inventory.
- **Commercial Sales Ledger**: Track customer accounts, debt balances, and unit pricing per egg or dozen.

### 4. 🌽 Feed Silo & Idempotent Automation
- **Feed Formulations**: Starter, Grower, Layer, Breeder, Quail-specific, and custom feeds.
- **Pure Forecast vs. Physical Deduction**: Biological demand forecasting is a side-effect-free calculation that writes 0 rows to the database. Physical deduction is executed atomically and gated by `autoFeedDeduction` setting.
- **Burn-Rate Estimation**: Automatically projects remaining inventory days based on current flock size and species-calibrated daily nutrition curves.

### 5. 🐣 Incubator & Hatchery Management
- **Multi-Stage Batches**: Configurable incubation periods (21d chickens, 17d quails, 28d ducks).
- **Milestones & Diagnostics**: Tracks candling on Day 7/14, fertile eggs count, temperature (°C) & humidity (%) inspections, turning status, pipped eggs, and dead-in-shell losses.
- **Automated Ratios**: Fertility rate, hatch rate from set eggs, and hatch rate from fertile eggs.
- **1-Tap Chick Transfer Wizard**: Converts successfully hatched chicks directly into a new active flock with `isInternalTransfer: true`, preventing duplicate financial purchase expenses.

### 6. 📚 Veterinary Advisory & Equipment Catalogue (CMS)
- **Peer-Reviewed Veterinary Knowledge Base**: Offline-cached trilingual articles on biosecurity, disease prevention (Coccidiosis, Newcastle, Coryza), and brooding management with medical disclaimers and academic citations.
- **Curated Equipment Catalogue**: Incubators, automated waterers, and climate controllers with transparent affiliate disclosures.
- **Administration Dashboard (`/admin`)**: Protected in-app CMS to create, edit, and publish articles, products, and broadcast notification campaigns with security audit logging.

### 7. 💰 Financials, Electricity & Profitability
- **Transparent Calculations**: Net Operating Result = Recorded Operating Income - Recorded Operating Expenses.
- **Capital Investments vs. Operating Costs**: Separates fixed assets (incubators, cages, feeders) from recurring operational expenses (feed, vaccines, bedding, electricity).
- **Electricity Calculator**: Direct meter readings or wattage-hours formula (`Wattage × Daily Hours × Days ÷ 1000 × Tariff/kWh`) with customizable tariff rates.

### 8. 🌐 Offline-First Architecture & Cloud Sync Bridge
- **100% Usable Offline**: No internet connection required for any core farm operation.
- **Durable Sync Outbox**: Asynchronous queue with UUID idempotency keys and tombstones for conflict-free reconciliation with Firebase Firestore.
- **JSON Backup & Restore**: One-tap full database backup export and restore directly from device storage.

---

## 🎨 Design System & Localization

- **Color Palette**: Forest Green (`#1E4D2B`), Deep Hunter Green (`#12351E`), Warm Cream (`#FDFBF7`), Pale Sage (`#F4F7F4`), and Amber Gold (`#E08E0B`).
- **Typography**: Clean, readable sans-serif typography tailored for high legibility in farm/field environments.
- **Full Trilingual Localization**:
  - 🇬🇧 English (`en`)
  - 🇫🇷 Français (`fr`)
  - 🇹🇳/🇸🇦 العربية (`ar` with full native Right-To-Left directionality and Western Arabic numerals)
- **Monetization & Ads**:
  - Non-intrusive AdMob banner placement (restricted to discovery surfaces; never placed over operational forms).
  - Global user toggle to disable ads in Settings.

---

## 📖 Comprehensive Documentation Suite

For detailed architecture, configuration, and deployment guides, refer to the `docs/` directory:

| Document | Description |
| :--- | :--- |
| [**Architecture & Data Integrity**](docs/ARCHITECTURE.md) | Complete SQLite schema v4, atomic transactions, sex accounting, egg reservation math, and sync outbox specifications. |
| [**Firebase Setup Guide**](docs/FIREBASE_SETUP.md) | Firebase project creation, `com.goldenroost.app` registration, Firestore security rules, Cloud Functions, and admin bootstrap. |
| [**Admin Dashboard & CMS Manual**](docs/ADMIN_DASHBOARD.md) | CMS operations, veterinary article publishing, product catalogue management, broadcast campaigns, and audit trail. |
| [**Monetization & AdMob Guide**](docs/MONETIZATION_SETUP.md) | Non-intrusive AdMob banners, test IDs vs production IDs, consent handling (UMP), and affiliate disclosure compliance. |
| [**Privacy & Deletion Protocol**](docs/PRIVACY_AND_DELETION.md) | Data inventory, local vs cloud storage, in-app deletion request workflow, and Google Play external deletion URL guide. |
| [**Store Privacy Policy**](docs/PRIVACY_POLICY.md) | Full, store-ready Privacy Policy for Google Play Console submission. |
| [**Google Play Release Checklist**](docs/GOOGLE_PLAY_RELEASE_CHECKLIST.md) | Target SDK 36, keystore signing, release AAB build, trilingual store listing copy (EN, FR, AR), and Data Safety form answers. |
| [**Testing & Known Limitations**](docs/TESTING_AND_KNOWN_LIMITATIONS.md) | Automated test execution record (27/27 passing), static analysis, and manual owner deployment checklist. |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>=3.24.0` (Tested with Flutter 3.41 / Dart 3.11)
- Android SDK with API level 21+ (`minSdkVersion 21`, `targetSdkVersion 36`)
- Java 17 / OpenJDK 17

### Installation & Run

1. Clone or navigate to the repository:
   ```bash
   cd c:\DEV\Antigravity\Poultry
   ```

2. Fetch all dependencies:
   ```bash
   flutter pub get
   ```

3. Run automated tests:
   ```bash
   flutter test
   ```

4. Run static analysis:
   ```bash
   flutter analyze
   ```

5. Build Release Android App Bundle (.aab):
   ```bash
   flutter build appbundle --release
   ```

---

## 📱 Android Permissions & Security

The following permissions are configured in `android/app/src/main/AndroidManifest.xml`:
- `android.permission.INTERNET` & `android.permission.ACCESS_NETWORK_STATE`: For optional cloud synchronization and remote article updates.
- `android.permission.POST_NOTIFICATIONS`: Android 13+ runtime push notifications.
- `android.permission.SCHEDULE_EXACT_ALARM`: Accurate scheduling of feeding, candling, and vaccination reminders.
- `android.permission.RECEIVE_BOOT_COMPLETED`: Reschedule task reminders when device reboots.
- `android.permission.VIBRATE` & `android.permission.WAKE_LOCK`: Alerts during scheduled farm events.

---

## 🧪 Automated Testing Summary

Golden Roost includes 27 comprehensive automated tests verifying:
- Live bird counts after purchases, mortality, culling, and sales.
- Laying rates and egg usable percentage computations.
- Feed consumption conversions and stock depletion forecasting.
- Incubation fertility rates, hatch from set eggs, and hatch from fertile eggs.
- Chick cost allocation from egg costs and incubator electricity.
- Net operating results (Operating Income minus Operating Expenses).
- Electricity wattage-to-kWh cost models.
- Layer eligibility filtering (mature layers only).
- Egg reservation math preventing overselling.
- Internal chick transfer preventing duplicate financial expenses.
- Sync outbox queue serialization and tombstone tracking.
- Article trilingual presentation fallbacks and affiliate disclosure formatting.
- Responsive container layout and premium card styling.

---

## 📄 License & Attribution

Golden Roost is proprietary software developed by Atef AK. All rights reserved.
Repository: [https://github.com/Atef-AK/Golden-Roost](https://github.com/Atef-AK/Golden-Roost)
