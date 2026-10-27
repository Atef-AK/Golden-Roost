# Golden Roost — Privacy, Data Handling & Account Deletion Protocol

**Compliance Standard:** Google Play Data Safety Policy, GDPR (EU), CCPA (California)  
**Package:** `com.goldenroost.app`  
**Deletion Request Web Landing Page:** `https://atef-ak.github.io/Golden-Roost/delete-account` (or your custom domain)

---

## 1. Data Inventory & Architecture

Golden Roost operates under a **privacy-by-default** and **offline-first** architecture. Unlike cloud-only farm software, Golden Roost does not mandate account registration, email verification, or phone number collection to use the core application.

### 1.1 Local Data Storage (100% On-Device by Default)
All operational farm metrics are stored in a local SQLite database (`flockmate.db`) within the app's sandboxed private storage:
- **Flock Profiles:** Species, breeds, bird counts, acquisition dates, housing.
- **Egg Logs & Sales:** Collection numbers, commercial customer names, sale revenues.
- **Feed Inventory & Transactions:** Grain types, supplier purchase costs, daily bird feeding ledgers.
- **Incubator Records:** Machine IDs, candling observations, hatch outcomes.
- **Financial Accounts:** Operational expenses, capital asset purchases, income entries.
- **Health & Tasks:** Vaccination schedules, medication history, daily reminders.

*This data never leaves the farmer's device unless they explicitly activate Cloud Sync.*

### 1.2 Optional Cloud Sync Data (Firebase)
When a user voluntarily opts into Cloud Synchronization:
- **Authentication:** Firebase Auth User ID (UUID) and associated email.
- **Synchronized Data:** Copies of the user's farm records stored in private, isolated Firestore subcollections (`/users/{uid}/...`).
- **Security:** Protected by strict Firestore security rules preventing access by any other user or tenant.

### 1.3 Advertising & Diagnostics Data
- **Google Mobile Ads (AdMob):** If ads are enabled, Google's Mobile Ads SDK may process advertising identifiers (Google Advertising ID) and approximate location to serve compliant, consent-governed banner ads. Users can disable ads entirely in Farm Settings.
- **Diagnostic / Crash Logs:** Anonymous crash traces are captured only to diagnose system bugs and prevent data loss.

---

## 2. In-App User Privacy Controls

Golden Roost puts farmers in complete control of their data directly inside **Farm Settings**:
1. **Cloud Sync Toggle:** Turn cloud backup on or off with a single switch.
2. **AdMob Banner Toggle:** Disable banner advertising without paying or subscribing.
3. **Automated Feed Deduction Toggle:** Choose whether feed calculations automatically deduct stock or remain strictly advisory.
4. **Export Local Database (JSON Backup):** Export a complete, portable JSON archive of the entire farm history to device storage or personal cloud drive.
5. **In-App Account Deletion:** Direct access to request deletion of cloud records.

---

## 3. Account & Data Deletion Workflows

In compliance with Google Play's User Data Policy, Golden Roost provides two equivalent pathways for users to delete their account and associated data:
1. **In-App Deletion Pathway**
2. **External Web Deletion URL Pathway**

### 3.1 In-App Deletion Pathway
1. Open Golden Roost -> Navigate to **Settings** (`/settings`).
2. Scroll to the **Data Management & Cloud Synchronization** card.
3. Tap **Request Account & Cloud Data Deletion**.
4. The application presents an explicit confirmation dialog detailing what will be permanently removed:
   - User authentication profile and credentials.
   - All cloud-synchronized flock, egg, feed, financial, and incubation records in Firestore.
   - Pending sync outbox queue entries.
5. Upon confirmation, the application calls the cloud deletion endpoint, terminates the active session, clears local sync metadata, and returns to a clean, isolated local-only state.

---

### 3.2 External Web Deletion Landing Page (Google Play Mandatory)

Google Play requires developers to provide a publicly accessible web URL where users can request deletion of their account and associated data without reinstalling the app.

#### URL to Provide in Google Play Console:
```
https://atef-ak.github.io/Golden-Roost/delete-account
```
*(Or your dedicated domain: `https://goldenroost.com/delete-account`)*

#### Recommended Web Landing Page Template (`web/delete_account_template.html`):
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Golden Roost — Account & Data Deletion Request</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; max-width: 650px; margin: 40px auto; padding: 0 20px; color: #222; }
    h1 { color: #1E4D2B; }
    .card { background: #F4F7F4; border-radius: 8px; padding: 20px; margin: 20px 0; border: 1px solid #D2DDD2; }
    .btn { background: #C93B2B; color: #fff; border: none; padding: 12px 24px; border-radius: 6px; font-size: 16px; cursor: pointer; text-decoration: none; display: inline-block; }
    label { font-weight: bold; display: block; margin-top: 15px; }
    input[type="email"], textarea { width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; }
  </style>
</head>
<body>
  <h1>Golden Roost</h1>
  <h2>Request Account & Cloud Data Deletion</h2>
  <p>In accordance with Google Play developer policies and privacy regulations (GDPR/CCPA), Golden Roost users may request the permanent deletion of their account and all associated cloud-synchronized farm data.</p>
  
  <div class="card">
    <h3>What gets deleted:</h3>
    <ul>
      <li>Your Firebase user account, authentication records, and email identifier.</li>
      <li>All cloud-synchronized flock, bird movement, egg collection, feed, finance, and incubator records stored in Firestore.</li>
      <li>All associated notification campaign subscriptions and tokens.</li>
    </ul>
    <p><em>Note: Data stored locally on your physical device remains in your local device SQLite storage until you uninstall the app or clear app data via Android Settings.</em></p>
  </div>

  <form action="mailto:atef.akrem.dev@gmail.com?subject=Golden%20Roost%20Account%20Deletion%20Request" method="POST" enctype="text/plain">
    <label for="email">Account Email Address:</label>
    <input type="email" id="email" name="email" required placeholder="your.email@example.com">

    <label for="reason">Additional Comments (Optional):</label>
    <textarea id="reason" name="reason" rows="3" placeholder="Please delete my cloud farm account."></textarea>

    <br><br>
    <button type="submit" class="btn">Submit Deletion Request</button>
  </form>

  <p><small>Deletion requests are processed within 14 business days. You will receive a confirmation email once your cloud records have been permanently purged.</small></p>
</body>
</html>
```

---

## 4. Data Retention & Archival Policies

- **Cloud Data:** Deleted within a maximum of 30 days following an account deletion request.
- **Local SQLite Data:** Controlled 100% by the device owner. It can be cleared instantly via **Android Settings -> Apps -> Golden Roost -> Storage -> Clear Data**, or by uninstalling the application.
- **Financial Records:** Users wishing to keep historical financial archives before deletion can use Golden Roost's built-in **CSV Exporter** or **PDF Farm Report Generator** to preserve tax-compliant records locally.
