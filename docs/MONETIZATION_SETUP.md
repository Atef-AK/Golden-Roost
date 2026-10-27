# Golden Roost — Monetization Architecture & AdMob Integration Guide

**Monetization Channels:** Non-Intrusive Google AdMob Banners & Curated Affiliate Product Recommendations  
**Implementation Files:**  
- Service: `lib/core/ads/ad_service.dart`  
- Widget: `lib/views/widgets/banner_ad_widget.dart`  
- Settings: `lib/views/settings/settings_screen.dart`

---

## 1. Monetization Philosophy & Placement Policy

Farm management applications are critical operational tools. Farmers interact with Golden Roost while managing livestock, measuring feed, and entering financial data. 

### Core Placement Principles:
1. **Zero Interference with Operational Workflows:** Banner ads are **strictly prohibited** from overlaying egg collection dialogs, bird movement forms, incubation candling wizards, or financial ledgers.
2. **Contextual Placement:** Non-intrusive banner ads are restricted to secondary knowledge discovery surfaces (e.g. bottom of veterinary article views, bottom of equipment catalogue).
3. **User Opt-Out Control:** Users can toggle ads off at any time in **Farm Settings -> Application Preferences -> Enable Non-Intrusive Banner Ads**.
4. **Graceful Offline Fallback:** When offline or when ad networks fail to fill inventory, the ad container collapses completely with zero height, avoiding blank white boxes or visual layout shifts.

---

## 2. Google AdMob Mobile Configuration

> [!IMPORTANT]
> **AdMob vs. AdSense Distinction:**  
> **Google AdMob** is exclusively designed for native mobile applications (Android / iOS).  
> **Google AdSense** is exclusively designed for public web pages and browser portals.  
> Do not attempt to load AdSense web scripts inside Flutter native views, and never configure mobile app IDs in an AdSense portal. Always use the Google AdMob console for Golden Roost.

### 2.1 Official Google Test Identifiers (Current Default)
The codebase is currently pre-configured with Google's official, verified test IDs to prevent accidental policy violations during development and Google Play internal testing:

| Identifier Type | Platform | Google Official Test ID |
| :--- | :--- | :--- |
| **Test App ID** | Android | `ca-app-pub-3940256099942544~3347511713` |
| **Test Banner Unit ID** | Android | `ca-app-pub-3940256099942544/6300978111` |

### 2.2 Transitioning to Production AdMob IDs

When you are ready to release commercially on Google Play:

#### Step 1: Create AdMob App & Ad Unit
1. Log into your [Google AdMob Console](https://apps.admob.com/).
2. Click **Apps** -> **Add App** -> Select **Android** -> Choose **Yes** if listed or **No** if not yet published.
3. Name your app `Golden Roost`.
4. Copy your **AdMob App ID** (format: `ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX`).
5. Click **Add Ad Unit** -> Select **Banner** -> Name it `Golden Roost Discovery Banner`.
6. Copy your **Banner Ad Unit ID** (format: `ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX`).

#### Step 2: Update `AndroidManifest.xml`
Open `android/app/src/main/AndroidManifest.xml` and replace the test application metadata with your production App ID:
```xml
<!-- Google AdMob Application ID -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX"/>
```

#### Step 3: Update `AdService`
In `lib/core/ads/ad_service.dart`, update the `bannerAdUnitId` getter:
```dart
String get bannerAdUnitId {
  if (kReleaseMode) {
    return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // Your real Production Banner ID
  }
  return testBannerAdUnitId; // Google Test ID during debug/profile runs
}
```

---

## 3. Privacy, Consent & GDPR (User Messaging Platform)

To comply with Google Play policies, European General Data Protection Regulation (GDPR), and California Consumer Privacy Act (CCPA):
1. The `AdService` uses Google Mobile Ads SDK consent lifecycle.
2. For EEA (European Economic Area) and UK users, Google's User Messaging Platform (UMP) displays a certified Consent Management Platform (CMP) message prior to requesting personalized ad bids.
3. If consent is declined or non-personalized ads are selected, `AdService` automatically requests non-personalized ad requests (`NonPersonalizedAdsPreference`).

---

## 4. Affiliate Marketing Architecture

In addition to banner advertising, Golden Roost generates revenue by recommending high-grade poultry farming equipment, incubators, automated waterers, and nutritional supplements.

### 4.1 Affiliate Networks Supported
- **Amazon Associates:** Worldwide poultry equipment and smallholder supplies.
- **AliExpress Portals:** Industrial incubator parts, humidity controllers, digital candlers.
- **Regional Suppliers:** Direct partnerships with local agricultural equipment distributors (e.g. Tunisia, North Africa, France, USA).

### 4.2 Regulatory Disclosures & Compliance
Under FTC (Federal Trade Commission) guidelines and European e-Commerce directives:
1. Every product recommendation rendered via `lib/views/products/products_catalogue_screen.dart` displays an explicit commercial disclosure:
   > *"Golden Roost earns a referral commission on qualifying purchases at no extra cost to you."*
2. Affiliate links are marked with `target="_blank"` and proper referral tags.
3. Links are opened securely in the device's external browser using `url_launcher` (`LaunchMode.externalApplication`).
