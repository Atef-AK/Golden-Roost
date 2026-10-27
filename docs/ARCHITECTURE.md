# Golden Roost — System Architecture & Data Integrity Specification

**Version:** 2.0.0 (Production Release)  
**Package:** `com.goldenroost.app`  
**Framework:** Flutter 3.x / Dart 3.x  
**State Management:** Flutter Riverpod  
**Local Persistence:** SQLite (`sqflite`) — Schema Version 4  
**Cloud Synchronization:** Firebase Firestore / Cloud Functions (Bridge Pattern)

---

## 1. System Overview & Core Philosophy

**Golden Roost** is built upon an uncompromising **offline-first** architectural paradigm designed for harsh agricultural environments. Poultry farms frequently operate in rural zones with intermittent or non-existent cellular coverage. 

### Core Architectural Principles:
1. **100% Offline Usability:** Every critical farm workflow (daily feeding, egg collection, bird movement, incubator candling, financial logging, medication, and offline veterinary handbook access) functions entirely without internet access.
2. **Deterministic Ledger Accounting:** No double-counting, no silent record loss, and no phantom inventory. Every financial transaction, feed deduction, and chick movement is traceable through atomic transactions.
3. **Decoupled Forecasts from Consumption:** Forecasting biological feed demand based on flock age and species curves is a pure, side-effect-free calculation that never mutates physical inventory ledgers without explicit user authorization or automated configuration.
4. **Resilient Cloud Bridge:** Cloud synchronization is an optional, additive layer. When enabled, mutations are buffered in a local SQLite outbox with idempotency keys and tombstones, ensuring zero data loss during network dropouts or app restarts.

```
┌────────────────────────────────────────────────────────────────────────┐
│                        Golden Roost UI Layer                           │
│     (Responsive Views, RTL/LTR Support, Forms, Charts, Dialogs)        │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Watches & Notifies
┌───────────────────────────────────▼────────────────────────────────────┐
│                       Riverpod State Layer                             │
│   (FlockProvider, FeedProvider, FinanceProvider, ArticleProvider...)   │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Calls Services & Repositories
┌───────────────────────────────────▼────────────────────────────────────┐
│                    Domain & Business Logic Layer                       │
│    (FarmCalculations, FeedAutomationService, NotificationService)      │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Atomic Operations
┌───────────────────────────────────▼────────────────────────────────────┐
│                   DatabaseHelper (SQLite Engine v4)                    │
│   ┌────────────────────────┬───────────────────────────────────────┐   │
│   │   Farm Core Tables     │        Sync & Remote CMS Tables       │   │
│   │   - flocks             │        - sync_outbox                  │   │
│   │   - bird_movements     │        - sync_tombstones              │   │
│   │   - egg_records/sales  │        - articles                     │   │
│   │   - feed_items/txns    │        - poultry_products             │   │
│   │   - finances           │        - notification_campaigns       │   │
│   │   - incubation_batches │        - admin_audit_logs             │   │
│   └────────────────────────┴───────────────────────────────────────┘   │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Durable Outbox Queue
┌───────────────────────────────────▼────────────────────────────────────┐
│               SyncService & Cloud Bridge Adapter                       │
│     (Idempotency Keys, Tombstone Propagation, Conflict Handling)       │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ HTTPS / TLS (When Online)
┌───────────────────────────────────▼────────────────────────────────────┐
│                       Firebase Cloud Backend                           │
│          (Cloud Firestore, Firebase Auth, FCM Messaging)               │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Database Schema (SQLite Version 4)

The database schema is managed through `lib/core/database/database_helper.dart`. Incremental migrations ensure existing user data is seamlessly preserved when moving from earlier versions.

### 2.1 Complete Table Inventory

| Table Name | Primary Key | Description |
| :--- | :--- | :--- |
| `flocks` | `id` (TEXT) | Active and archived bird flocks with breed, age, purpose, start counts, and housing. |
| `bird_movements` | `id` (TEXT) | Immutable log of bird intakes, purchases, mortalities, culls, and sales per flock. |
| `egg_records` | `id` (TEXT) | Daily egg collection logs (good, cracked, damaged, rejected). |
| `egg_sales` | `id` (TEXT) | Commercial egg sales with customer, price, quantity, and payment status. |
| `feed_items` | `id` (TEXT) | Feed silo inventory items with batch code, current stock (kg), and unit cost. |
| `feed_transactions` | `id` (TEXT) | Atomic stock movements (purchases, daily flock feeding, manual adjustments). |
| `finances` | `id` (TEXT) | Operational expenses, capital equipment investments, and revenue transactions. |
| `incubation_batches` | `id` (TEXT) | Egg incubation runs with set dates, machine identifiers, unit costs, and transfer flags. |
| `incubation_readings` | `id` (TEXT) | Daily candling, temperature, humidity, and milestone observations. |
| `tasks` | `id` (TEXT) | Scheduled farm tasks, vaccination schedules, and reminders. |
| `electricity_meters` | `id` (TEXT) | Meter readings and wattage equipment consumption calculations. |
| `sync_outbox` | `id` (TEXT) | Local mutations awaiting upload to Firebase Firestore. |
| `sync_tombstones` | `id` (TEXT) | Deleted entity IDs with timestamps to propagate deletions to the cloud. |
| `articles` | `id` (TEXT) | Trilingual veterinary and management articles with offline caching. |
| `poultry_products` | `id` (TEXT) | Curated poultry equipment catalog with affiliate links and disclosures. |
| `notification_campaigns` | `id` (TEXT) | Broadcast announcements and push notification history. |
| `admin_audit_logs` | `id` (TEXT) | Local audit log tracking content and sync operations. |

### 2.2 Data Definition Details (Key Tables)

#### Core Flocks Table
```sql
CREATE TABLE flocks (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  species TEXT NOT NULL,
  breed TEXT,
  housing TEXT,
  purpose TEXT NOT NULL,
  currentCount INTEGER NOT NULL,
  startMaleCount INTEGER DEFAULT 0,
  startFemaleCount INTEGER DEFAULT 0,
  acquisitionDate TEXT NOT NULL,
  hatchDate TEXT,
  initialAgeWeeks INTEGER DEFAULT 0,
  targetLayingAgeWeeks INTEGER DEFAULT 18,
  notes TEXT,
  isActive INTEGER DEFAULT 1,
  colorHex TEXT,
  createdAt TEXT NOT NULL,
  updatedAt TEXT NOT NULL
);
```

#### Sync Outbox Table
```sql
CREATE TABLE sync_outbox (
  id TEXT PRIMARY KEY,
  entityType TEXT NOT NULL,
  entityId TEXT NOT NULL,
  action TEXT NOT NULL, -- 'create', 'update', 'delete'
  payload TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  attemptCount INTEGER DEFAULT 0,
  lastAttemptAt TEXT,
  status TEXT DEFAULT 'pending', -- 'pending', 'in_flight', 'failed'
  idempotencyKey TEXT UNIQUE NOT NULL
);
```

#### Articles Table
```sql
CREATE TABLE articles (
  id TEXT PRIMARY KEY,
  slug TEXT UNIQUE NOT NULL,
  titleEn TEXT NOT NULL,
  titleFr TEXT NOT NULL,
  titleAr TEXT NOT NULL,
  summaryEn TEXT NOT NULL,
  summaryFr TEXT NOT NULL,
  summaryAr TEXT NOT NULL,
  bodyEn TEXT NOT NULL,
  bodyFr TEXT NOT NULL,
  bodyAr TEXT NOT NULL,
  category TEXT NOT NULL,
  tags TEXT,
  authorName TEXT NOT NULL,
  veterinaryReviewer TEXT,
  imageUrl TEXT,
  readingTimeMinutes INTEGER DEFAULT 5,
  referencesList TEXT,
  medicalDisclaimer TEXT,
  isPublished INTEGER DEFAULT 1,
  publishedAt TEXT NOT NULL,
  updatedAt TEXT NOT NULL
);
```

---

## 3. Data Integrity & Business Logic Guarantees

### 3.1 Atomic Database Transactions
All multi-table operations are executed inside `db.transaction((txn) async { ... })` blocks. For instance, when recording a feed transaction:
1. The `feed_transactions` entry is written.
2. The corresponding `feed_items` stock level is updated in-place.
3. If the transaction was an automated daily feeding, an idempotency record is maintained.
If any step fails or is interrupted by an unexpected process exit, SQLite rolls back the entire transaction atomically, preventing orphaned records.

### 3.2 Deterministic Sex & Population Accounting
Flock sex counts are recalibrated deterministically to prevent drift over time:
- In `Flock`, immutable starting male and female counts (`startMaleCount`, `startFemaleCount`) are recorded at flock creation.
- Mortalities, culls, and sales track the specific sex (`male`, `female`, or `unknown`).
- When computing current active sex distribution, the calculation starts from the immutable base and reconciles all historical movements:
  $$\text{Current Females} = \text{startFemaleCount} - \sum \text{Female Mortalities/Culls/Sales}$$
  $$\text{Current Males} = \text{startMaleCount} - \sum \text{Male Mortalities/Culls/Sales}$$

### 3.3 Layer Eligibility & Egg Production Metrics
In `lib/models/flock.dart`, `eligibleLayingFemales` computes only birds capable of commercial egg production:
```dart
int get eligibleLayingFemales {
  if (purpose == FlockPurpose.meat) return 0;
  final ageInWks = ageInWeeks;
  final isQuail = species.toLowerCase().contains('quail') || species.toLowerCase().contains('caille');
  final matureAge = isQuail ? 6 : 18;
  if (ageInWks < matureAge) return 0;
  return femaleCount > 0 ? femaleCount : (currentCount * 0.95).round();
}
```
This strictly eliminates distorted laying percentages (e.g., broiler flocks or 4-week-old pullets showing up in laying denominator calculations).

### 3.4 Egg Reservation Math (Preventing Overselling)
Eggs harvested cannot be double-sold if they are already dedicated to incubator batches. `FarmCalculations.calculateAvailableSaleableEggs`:
$$\text{Available Saleable Eggs} = \text{Total Clean Eggs Collected} - \text{Eggs Set in Incubators} - \text{Eggs Already Sold}$$
In `lib/views/eggs/eggs_screen.dart`, sales dialog forms validate that the user cannot sell more eggs than the physical available saleable inventory.

### 3.5 Internal Hatchery Chick Transfers (No Double-Counting)
When an incubation batch hatches successfully:
1. `transferChicksToNewFlock` in `IncubationProvider` sets `isTransferred: true` and records `transferredFlockId`.
2. It calls `FlockProvider.addFlock` with `isInternalTransfer: true`.
3. When `isInternalTransfer == true`, `addFlock` skips recording an acquisition purchase expense in `finances`. The expenses were already accounted for in the incubation batch costs (original egg setting cost, incubator electricity, sanitation). This prevents artificial balance sheet inflation.

### 3.6 Pure Forecast vs Transactional Consumption
In `lib/core/services/feed_automation_service.dart`:
- `forecastDailyDemand` is a **pure function**: it reads active flock populations and species nutrition curves (e.g. 118 g/day for 20-week layer, 108 g/day for 3-week broiler) and returns the projected kilogram requirement. **It writes 0 rows to the database.**
- `recordActualFeedConsumption` is the **transactional mutator**: it writes `feed_transactions`, decrements `feed_items`, and logs financial expenses only when authorized.
- Automatic daily feed deduction is controlled by the user-facing setting `farm_settings.autoFeedDeduction` (default: `false`).

---

## 4. Offline-First Synchronization & Firebase Bridge

The synchronization subsystem in `lib/core/sync/sync_service.dart` implements an asynchronous, durable outbox pattern:

```
[Local User Action]
       │
       ▼
[SQLite Transaction] ──► Writes Entity (flock, egg, feed...)
       │
       └──► Writes `sync_outbox` row (Action, Payload, IdempotencyKey)
       
                                [When Connectivity Available]
                                             │
                                             ▼
                                  [SyncService.processOutbox]
                                             │
                                             ├──► Checks Network State
                                             ├──► Batches Outbox Rows
                                             ├──► HTTPS Post to Firestore
                                             └──► Deletes Outbox Row on 200 OK
```

### 4.1 Idempotency Keys
Every mutation generates a deterministic or UUID-based idempotency key:
$$\text{IdempotencyKey} = \text{entityType}\_\text{entityId}\_\text{timestamp}$$
If a network timeout occurs while the cloud backend has already committed the write, the client retries with the same idempotency key. The cloud Firestore adapter checks if the mutation was already executed, preventing duplicate document creation.

### 4.2 Tombstones
When a user deletes a record locally, deleting the row alone would cause a naive sync engine to re-download the remote copy on next pull. Golden Roost records an entry in `sync_tombstones`:
- `entityId`: ID of deleted record
- `entityType`: Table / collection name
- `deletedAt`: ISO 8601 timestamp
During cloud reconciliation, remote entities whose `updatedAt` is older than local tombstone `deletedAt` are deleted from the cloud.

### 4.3 Multi-Device Conflict Resolution
- **Last-Write-Wins (LWW) with Client Timestamps:** When the same entity is modified on two offline devices and later synchronized, the update with the higher `updatedAt` ISO 8601 timestamp prevails.
- **Account-Switching Isolation:** When a user logs out or switches cloud accounts, the local database can be reset or backed up to an isolated JSON snapshot, preventing cross-tenant leakage.

---

## 5. Remote Content Delivery & Localization

### 5.1 Veterinary Articles & Products
- Articles (`Article`) and Equipment Products (`PoultryProduct`) are delivered via Firestore and cached in local SQLite tables (`articles`, `poultry_products`).
- Offline fallback datasets (`sample_articles.dart`, `sample_products.dart`) are embedded in the APK/bundle, guaranteeing that first-time users in rural areas immediately have access to critical veterinary literature without waiting for internet connectivity.

### 5.2 Trilingual Presentation Architecture
- All content supports English (`en`), French (`fr`), and Arabic (`ar`).
- When Arabic is selected:
  - Directionality switches to Right-to-Left (`Directionality(textDirection: TextDirection.rtl)`).
  - Western Arabic numerals (`0-9`) are consistently preserved in mathematical and numeric entry fields to avoid parsing bugs with localized comma separators.
  - Medical disclaimers and affiliate disclosures are fully translated to maintain regulatory compliance across all language markets.
