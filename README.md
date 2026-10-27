# Golden Roost — Poultry Farm Manager 🐔🥚🐣

**Golden Roost** is an Android-first, offline-first Flutter application designed for modern poultry farmers. Built with Riverpod, SQLite, and GoRouter, it manages the complete end-to-end lifecycle of a commercial or homestead poultry operation: raising chickens, quails, ducks, and custom species, tracking egg collection and commercial sales, managing multi-stage incubator batches with hatch wizards, scheduling veterinary care and daily tasks with local notifications, and tracking exact financial performance and electricity costs.

---

## 🌟 Key Features

### 1. 📊 Real-Time Operations Dashboard
- **Top Metric Cards**: Live bird population, eggs collected today, feed stock with estimated depletion days countdown, today's income/expenses, and current-month net operating result.
- **Urgent Action Center**: Active incubator batches countdown alerts, upcoming vaccinations, and overdue task warnings.
- **Interactive Timeline**: Real-time chronological audit trail of all farm operations.
- **Quick-Action Bottom Sheet**: 1-tap logging for daily feed, water inspections, egg collection, bird sales, mortalities, expenses, incubation events, and custom tasks.

### 2. 🐓 Flock & Bird Management
- **Multi-Species Support**: Built-in support for chickens (e.g. Lohmann Brown, Rhode Island Red), quails (e.g. Coturnix), ducks, turkeys, geese, and customizable custom species.
- **Purpose Categorization**: Layers, Meat/Broilers, Breeders, or Dual-Purpose/Mixed.
- **Exact Population Accounting**: Tracks starting birds, purchases, hatches/intakes, natural mortalities, culls, and sales. Live count automatically recalculates from movement ledger without discrepancies.
- **Historical Back-Entry**: Back-date existing flocks to their true acquisition or hatch date.
- **Flock Detail Timeline**: Age in days/weeks, production history, feed consumption, health records, expenses, and revenues per flock.

### 3. 🌽 Feed, Water & Inventory
- **Feed Formulations**: Starter, Grower, Layer, Breeder, Quail-specific, and custom feeds.
- **Unit Conversions & Daily Logs**: Converts daily grams per bird to kilograms accurately, debits stock, and warns against negative inventory.
- **Burn-Rate Estimation**: Automatically projects remaining inventory days based on current flock size and average daily consumption.
- **Water Checks & Sanitation**: Tracks drinker maintenance, sanitation tasks, and optional water volume intake in liters.

### 4. 🐣 Incubator & Hatchery Management
- **Incubation Batches**: Logs incubator machine identifier, species, setting date, eggs set, and unit egg cost.
- **Species Duration Profiles**: Configurable incubation periods (e.g. 21 days for chickens, 17 days for quails, 28 days for ducks).
- **Milestones & Diagnostics**: Tracks candling on Day 7/14, fertile eggs count, temperature (°C) & humidity (%) inspections, turning status, pipped eggs, and dead-in-shell losses.
- **Performance Metrics**: Automated fertility rate, hatch rate from set eggs, and hatch rate from fertile eggs.
- **One-Click Chick Transfer Wizard**: Converts successfully hatched chicks directly into a new active flock with accumulated egg and electricity/sanitation costs transferred without double-counting.

### 5. 📅 Task Calendar, Health & Vaccination
- **Configurable Vaccination Schedules**: User-defined schedules per species or flock with target age, administration route (drinking water, eye drop, injection, spray), status, and notes.
- **Daily Task Management**: Filter by Daily, Weekly, or Monthly views. Supports one-time, daily, weekly, and monthly recurrence.
- **Push Notification Reminders**: Powered by `flutter_local_notifications` with explicit permission handling, channel configurations, and boot recovery support.

### 6. 💰 Financials, Electricity & Profitability
- **Transparent Calculations**: Net Operating Result = Recorded Operating Income - Recorded Operating Expenses.
- **Capital Investments vs. Operating Costs**: Separates fixed assets (incubators, cages, feeders) from recurring operational expenses (feed, vaccines, bedding, electricity).
- **Electricity Calculator**: 
  - Option A: Direct meter readings in kWh.
  - Option B: Wattage-hours formula (`Wattage × Daily Hours × Days ÷ 1000 × Tariff/kWh`).
  - Editable electricity tariff (default: 0.220 TND/kWh for STEG Tunisia).
- **Accounts Receivable**: Tracks paid, unpaid, and partial client balances for bird and egg sales.

### 7. 📈 Interactive Analytics & Export
- **Visual Analytics**: Interactive charts built with `fl_chart` (egg production curves, laying percentage, financial breakdown, species comparisons).
- **CSV Data Exporter**: Clean CSV spreadsheets for Flocks, Egg Logs, Feed Transactions, and Financial Ledgers.
- **PDF Farm Report**: Printable, high-resolution A4 farm reports with summary metrics, flock health statuses, and financial results.
- **Full JSON Backup & Restore**: One-tap full database backup export and restore directly from device storage.

---

## 🎨 Design System & Localization

- **Color Palette**: Forest Green (`#1E4D2B`), Deep Hunter Green (`#12351E`), Warm Cream (`#FDFBF7`), Pale Sage (`#F4F7F4`), and Amber Gold (`#E08E0B`).
- **Typography**: Clean, readable sans-serif typography tailored for high legibility in farm/field environments.
- **Localization**:
  - 🇬🇧 English (`en`)
  - 🇫🇷 Français (`fr`)
  - 🇹🇳 العربية (`ar` with full native Right-To-Left directionality)
- **Regional Defaults**:
  - **Currency**: Tunisian Dinar (`TND` / `DT`)
  - **Units**: Metric (`kg`, `g`, `kWh`, `°C`, `Liters`)
  - **Timezone**: `Africa/Tunis` (editable in Farm Settings)

---

## 🏗️ Architecture & Tech Stack

```
lib/
├── core/
│   ├── database/
│   │   ├── database_helper.dart      # SQLite schema, indices, migrations & JSON backup
│   │   └── sample_data.dart          # Realistic Tunisian demonstration farm dataset
│   ├── localization/
│   │   └── app_translations.dart     # EN, FR, AR translation dictionaries & RTL helpers
│   ├── notifications/
│   │   └── notification_service.dart # Local notification scheduling & channel config
│   ├── theme/
│   │   └── app_theme.dart            # Farm-themed light & dark design system
│   └── utils/
│       ├── calculations.dart         # Pure business logic formulas & mathematical models
│       ├── csv_exporter.dart         # CSV generation and sharing
│       ├── formatters.dart           # Date, currency, percentage, and weight formatting
│       └── pdf_report_generator.dart # A4 printable PDF report rendering
├── models/
│   ├── bird_movement.dart            # Birth, purchase, mortality, cull, sale records
│   ├── electricity.dart              # Meter readings and wattage appliances
│   ├── egg_record.dart               # Daily egg logs and commercial egg sales
│   ├── farm_settings.dart            # Farm name, currency, language, electricity tariff
│   ├── feed.dart                     # Inventory items and daily consumption transactions
│   ├── finance.dart                  # Income, operating expenses, capital investments
│   ├── flock.dart                    # Flock profile, species, breed, housing, counts
│   ├── incubation.dart               # Incubation batches and daily inspection readings
│   ├── task_item.dart                # Farm tasks with recurrence and notification times
│   └── vaccination.dart              # Species vaccination programs and completion dates
├── providers/                        # Riverpod state notifiers and providers
├── views/                            # Screen widgets, dialogs, charts, and shell
├── router.dart                       # GoRouter route declarations
└── main.dart                         # Application entrypoint & ProviderScope initialization
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>=3.24.0` (tested with Flutter 3.41 / Dart 3.11)
- Android Studio / Android SDK with API level 21+ (minSdkVersion 21, targetSdkVersion 34)
- Java 17

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

4. Launch the application:
   ```bash
   flutter run
   ```

---

## 📱 Android Permissions & Configuration

The following permissions are configured in `android/app/src/main/AndroidManifest.xml`:
- `android.permission.POST_NOTIFICATIONS`: Android 13+ runtime push notifications.
- `android.permission.SCHEDULE_EXACT_ALARM`: Accurate scheduling of feeding and vaccination reminders.
- `android.permission.RECEIVE_BOOT_COMPLETED`: Reschedule task reminders when device reboots.
- `android.permission.VIBRATE` & `android.permission.WAKE_LOCK`: Alert alerts during scheduled task events.

Desugaring is enabled via `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")` in `build.gradle.kts` for Java 8+ time APIs on older Android devices.

---

## 🧪 Automated Testing

FlockMate includes unit tests and widget smoke tests verifying:
- Live bird counts after purchases, mortality, culling, and sales.
- Laying rates and egg usable percentage computations.
- Feed consumption conversions (grams per bird to kilograms) and stock depletion forecasting.
- Incubation fertility rates, hatch from set eggs, and hatch from fertile eggs.
- Chick cost allocation from egg costs and incubator electricity.
- Net operating results (Operating Income minus Operating Expenses, excluding unallocated costs).
- Electricity wattage-to-kWh cost models.
- Database model age calculations and low stock triggers.

Execute tests via:
```bash
flutter test
```

---

## 🔒 Offline-First & Data Safety

- **No Mandatory Account**: The app functions 100% locally with zero internet requirement.
- **SQLite Database**: Persistent SQLite database stored in device app sandbox (`flockmate.db`).
- **Sample Data Toggle**: Load a realistic Tunisian layer & quail farm dataset to preview all screens, and clear it cleanly from Settings with zero residual files.
- **JSON Backup & Restore**: Export full database snapshot anytime to cloud storage or local SD card and restore on any device running FlockMate.
