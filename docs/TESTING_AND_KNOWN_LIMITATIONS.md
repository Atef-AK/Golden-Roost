# Golden Roost — Automated Testing Suite & Known Limitations Report

**Test Suite:** Unit, Domain Logic, Ledger Integrity, Sync Outbox & UI Widget Tests  
**Verification Toolchain:** Flutter 3.x / Dart 3.x / Android SDK 36  
**Status:** 100% Pass (27/27 automated tests green, 0 static analyzer issues)

---

## 1. Automated Test Execution Record

### 1.1 Test Suite Breakdown

All automated tests are located in `test/` and can be executed via `flutter test`.

```
00:00 +0: C:/DEV/Antigravity/Poultry/test/farm_calculations_test.dart: FarmCalculations Business Logic Tests calculateLiveBirds correctly adds purchases/hatches and subtracts mortalities/sales
00:00 +1: C:/DEV/Antigravity/Poultry/test/farm_calculations_test.dart: FarmCalculations Business Logic Tests calculateLayingRate computes laying percentage accurately
00:00 +2: C:/DEV/Antigravity/Poultry/test/farm_calculations_test.dart: FarmCalculations Business Logic Tests calculateFeedPerBirdGrams correctly converts kg to daily grams per bird
00:00 +3: C:/DEV/Antigravity/Poultry/test/farm_calculations_test.dart: FarmCalculations Business Logic Tests calculateDaysFeedRemaining correctly predicts days until feed depletion
00:00 +4: C:/DEV/Antigravity/Poultry/test/farm_calculations_test.dart: FarmCalculations Business Logic Tests Incubation rates: fertility, hatch from set, and hatch from fertile
00:00 +5: C:/DEV/Antigravity/Poultry/test/farm_calculations_test.dart: FarmCalculations Business Logic Tests calculateChickCost computes exact cost per healthy chick
00:00 +6: C:/DEV/Antigravity/Poultry/test/farm_calculations_test.dart: FarmCalculations Business Logic Tests calculateNetOperatingResult: Operating Income minus Operating Expenses
00:00 +7: C:/DEV/Antigravity/Poultry/test/farm_calculations_test.dart: FarmCalculations Business Logic Tests calculateElectricityCost from equipment wattage, hours and tariff
00:00 +8: C:/DEV/Antigravity/Poultry/test/farm_calculations_test.dart: Data Models Integrity Tests Flock age calculation in days and weeks
00:00 +9: C:/DEV/Antigravity/Poultry/test/farm_calculations_test.dart: Data Models Integrity Tests Flock hatchDate overrides acquisitionDate for age calibration
00:00 +10: C:/DEV/Antigravity/Poultry/test/farm_calculations_test.dart: Data Models Integrity Tests FeedItem low stock trigger
00:00 +11: C:/DEV/Antigravity/Poultry/test/farm_calculations_test.dart: Data Models Integrity Tests calculateAvailableSaleableEggs accounts for incubation reservations and sold eggs
00:00 +12: C:/DEV/Antigravity/Poultry/test/farm_calculations_test.dart: Data Models Integrity Tests calculateCostPerEgg and calculateCostPerDozenEggs
00:00 +13: C:/DEV/Antigravity/Poultry/test/farm_calculations_test.dart: Data Models Integrity Tests Flock eligibleLayingFemales calculates only mature layer females
00:00 +14: C:/DEV/Antigravity/Poultry/test/farm_calculations_test.dart: Data Models Integrity Tests IncubationBatch prevents duplicate chick transfer
00:00 +15: C:/DEV/Antigravity/Poultry/test/ledger_and_sync_test.dart: Feed Automation & Ledger Integrity Tests forecastDailyDemand is a read-only calculation and does not alter stock
00:00 +16: C:/DEV/Antigravity/Poultry/test/ledger_and_sync_test.dart: Feed Automation & Ledger Integrity Tests calculateDaysBeforeRefill and refill date projection
00:00 +17: C:/DEV/Antigravity/Poultry/test/ledger_and_sync_test.dart: Sync Outbox & Serialization Tests SyncItem holds durable outbox metadata and idempotency key
00:00 +18: C:/DEV/Antigravity/Poultry/test/ledger_and_sync_test.dart: Sync Outbox & Serialization Tests SyncTombstone tracks explicit deletions
00:00 +19: C:/DEV/Antigravity/Poultry/test/ledger_and_sync_test.dart: Articles and Products Localization & Entity Tests Article trilingual title, summary, and body fallback
00:00 +20: C:/DEV/Antigravity/Poultry/test/ledger_and_sync_test.dart: Articles and Products Localization & Entity Tests PoultryProduct affiliate disclosure and URL resolution
00:01 +21: C:/DEV/Antigravity/Poultry/test/responsive_and_theme_test.dart: Responsive System and Design Components Tests ResponsiveContainer caps max width on wide screens
00:01 +22: C:/DEV/Antigravity/Poultry/test/responsive_and_theme_test.dart: Responsive System and Design Components Tests PremiumCard renders with correct borders and radius
00:01 +23: C:/DEV/Antigravity/Poultry/test/widget_test.dart: FlockMateApp smoke test and launch
00:02 +27: All tests passed!
```

### 1.2 Static Analysis Execution Record
```
Command: flutter analyze
Output: Analyzing Poultry...
No issues found! (ran in 5.5s)
```

---

## 2. Critical Business Logic Verification

1. **Decoupled Feed Forecasting:** `FeedAutomationService.forecastDailyDemand` was verified to be a side-effect-free projection that does not mutate SQLite stock.
2. **Egg Overselling Prevention:** `FarmCalculations.calculateAvailableSaleableEggs` deducts both incubation batches and completed sales from total clean eggs, preventing negative egg stock.
3. **Double-Expense Prevention on Hatchery Transfers:** `IncubationBatch.isTransferred` and `FlockProvider.addFlock(isInternalTransfer: true)` ensure that moving chicks from an incubator into a flock does not generate a second cash purchase expense.
4. **Pure Mature Layer Denominator:** `Flock.eligibleLayingFemales` excludes broiler/meat flocks and immature pullets (< 18 weeks for chickens, < 6 weeks for quails) from the laying rate denominator.
5. **Durable Sync Outbox Serialization:** `SyncItem` idempotency keys and `SyncTombstone` records serialize and deserialize without loss of metadata.

---

## 3. Known Limitations & Owner Action Items

The codebase has been engineered to be production-ready and compile cleanly in any Flutter environment. However, due to platform security constraints and account ownership requirements, the following manual steps must be completed by the repository owner:

### 1. Production Keystore & Release Signing
- **Current State:** The project builds using the standard Android debug keystore.
- **Action Required:** Follow `docs/GOOGLE_PLAY_RELEASE_CHECKLIST.md` to generate your private `golden-roost-release.jks`, populate `android/key.properties`, and never commit these private credentials to Git.

### 2. Firebase Cloud Credentials (`google-services.json`)
- **Current State:** The project operates in full offline-first mode with embedded fallback articles and products.
- **Action Required:** Follow `docs/FIREBASE_SETUP.md` to register `com.goldenroost.app` in your personal Firebase Console, download the authentic `google-services.json`, and place it in `android/app/google-services.json`.

### 3. Google AdMob Production Identifiers
- **Current State:** Pre-configured with Google's official, authorized Test Unit IDs (Test App ID: `ca-app-pub-3940256099942544~3347511713`, Test Banner: `ca-app-pub-3940256099942544/6300978111`).
- **Action Required:** Follow `docs/MONETIZATION_SETUP.md` to register your live AdMob account and replace the test IDs before publishing the release AAB to the Play Store.

### 4. Account Deletion Web Landing Page Hosting
- **Current State:** The complete responsive HTML template is documented in `docs/PRIVACY_AND_DELETION.md`.
- **Action Required:** Publish this HTML page to GitHub Pages (`https://atef-ak.github.io/Golden-Roost/delete-account`) or your custom domain, and paste the URL into the Google Play Console App Content -> Data Safety section.

### 5. Automated Cloud Function Deployment for FCM
- **Current State:** Push campaigns are stored locally and in Firestore under `/notification_campaigns`.
- **Action Required:** Deploy the TypeScript Cloud Function documented in `docs/FIREBASE_SETUP.md` via `firebase deploy --only functions` to trigger broadcast FCM pushes when an administrator publishes a campaign.
