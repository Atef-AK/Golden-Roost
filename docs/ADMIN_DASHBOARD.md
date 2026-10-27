# Golden Roost — Administration Dashboard & CMS Operations Manual

**Route:** `/admin`  
**Access Tier:** Protected Administrative Tier  
**Implementation:** `lib/views/admin/admin_dashboard_screen.dart`

---

## 1. Overview & Security Architecture

The Golden Roost Administration Dashboard is an in-app Content Management System (CMS) designed for farm managers, veterinary consultants, and agricultural content creators. It provides centralized control over:
1. **Veterinary & Educational Articles:** Trilingual knowledge base management with peer-review citations and medical disclaimers.
2. **Curated Equipment Catalogue:** Poultry supplies and equipment with affiliate tracking links and commercial disclosures.
3. **Notification Broadcast Campaigns:** Push notification campaigns with audience segmentation and deep-link routing.
4. **Security Audit Log:** An immutable ledger recording all administrative changes with timestamps and entity IDs.

### Access Verification
In client mode, the admin dashboard is protected by an administrative PIN verification modal. The default local administrative PIN is:
```
8822
```
When connected to Firebase, authentication automatically checks the user's Firebase Custom Claims (`request.auth.token.admin == true`) or queries the secure `/admins/{uid}` Firestore collection before granting write privileges.

---

## 2. Managing Educational Veterinary Articles

The veterinary article platform empowers farmers with peer-reviewed medical guidance on biosecurity, disease management, and production efficiency.

### 2.1 Publishing a New Article
1. Open **Administrator Dashboard** -> Select the **Articles** tab.
2. Tap the **+ New Article** button.
3. Fill in the required metadata:
   - **URL Slug:** URL-safe unique identifier (e.g. `coccidiosis-prevention-protocol`).
   - **Category:** Select from `Disease Prevention`, `Nutrition`, `Incubation`, `Housing & Equipment`, or `Flock Management`.
   - **Author Name & Credentials:** (e.g. `Dr. Atef K., DVM`).
   - **Veterinary Reviewer:** (e.g. `Tunisian Veterinary Poultry Board`).
   - **Reading Time:** Estimated minutes (e.g. `6 min`).
   - **Trilingual Content:**
     - **English:** Title, concise 2-sentence summary, and full markdown body.
     - **French:** Titre, résumé, et texte complet.
     - **Arabic:** العنوان، الملخص، والنص الإرشادي الكامل.
   - **References:** Scientific publications, FAO guidelines, or academic sources.
   - **Medical Disclaimer:** The standard veterinary guidance disclaimer is pre-filled:
     > *"This guidance is educational and does not replace on-site clinical diagnosis by a licensed veterinarian."*
4. Toggle **Published** to active.
5. Tap **Save Article**. The article is immediately committed to SQLite and queued for cloud sync.

---

## 3. Curated Equipment Products & Affiliate Links

Golden Roost enables farm monetization through curated recommendations of high-quality poultry equipment (incubators, automatic drinkers, brooder heaters, nutritional supplements).

### 3.1 Adding an Affiliate Product
1. Open **Administrator Dashboard** -> Select the **Products** tab.
2. Tap the **+ Add Product** button.
3. Complete the product details:
   - **Product Title:** (e.g. `Automatic Digital 56-Egg Incubator`).
   - **Merchant:** (e.g. `Amazon`, `AliExpress`, or `Local Poultry Supply Co.`).
   - **Price & Currency:** (e.g. `120.00` `TND` or `USD`).
   - **Category:** `Incubation`, `Feeding & Water`, `Health & Hygiene`, `Lighting & Climate`, `Cages & Housing`.
   - **Affiliate Target URL:** The authenticated link including partner/tag IDs (e.g. `https://www.amazon.com/dp/B08XYZ123?tag=goldenroost-20`).
   - **Image URL:** High-resolution product image hosted on CDN or HTTPS endpoint.
   - **Affiliate Disclosure Notice:** Clear statement of commercial relationship (pre-populated):
     > *"Golden Roost earns a referral commission on qualifying purchases at no extra cost to you."*
4. Tap **Save Product**.

### 3.2 Compliance Rules for Affiliate Monetization
- **Strict Separation:** Affiliate products are never presented as mandatory medication or biased clinical prescriptions.
- **Transparency:** The affiliate disclaimer badge is rendered on every product card and detail view.
- **FTC & International Ad Standards:** All commercial links conform to FTC Endorsement Guides and European consumer protection directives.

---

## 4. Notification Broadcast Campaigns

Broadcast campaigns allow administrators to deliver critical alerts (e.g. seasonal avian influenza warnings, feeding schedule tips, new article releases).

### 4.1 Composing a Campaign
1. Open **Administrator Dashboard** -> Select the **Campaigns** tab.
2. Tap **+ Create Campaign**.
3. Configure the broadcast:
   - **Campaign Title:** Short, high-impact headline.
   - **Body Text:** Educational or instructional alert message.
   - **Target Audience:**
     - `all`: Broadcast to every installed device on topic `all_users`.
     - `ar`: Broadcast specifically to Arabic-speaking farmers on topic `lang_ar`.
     - `fr`: Broadcast specifically to French-speaking farmers on topic `lang_fr`.
     - `en`: Broadcast specifically to English-speaking farmers on topic `lang_en`.
   - **Deep Link Navigation:** Direct user interaction upon tapping:
     - `goldenroost://home` — Launches main farm dashboard.
     - `goldenroost://article/:slug` — Opens specific veterinary article.
     - `goldenroost://product/:id` — Opens specific equipment recommendation.
4. Tap **Schedule Broadcast**. The campaign status becomes `pending` and is processed by the cloud FCM dispatcher.

---

## 5. Security Audit Trail

To prevent unauthorized changes and maintain full operational transparency:
- Every insert, update, or deletion of articles, products, or campaigns generates an atomic entry in `admin_audit_logs`.
- **Recorded Attributes:**
  - `id`: Unique UUID for the audit event.
  - `actor`: User ID or local admin handle.
  - `action`: `CREATE_ARTICLE`, `UPDATE_ARTICLE`, `DELETE_ARTICLE`, `ADD_PRODUCT`, etc.
  - `entityId`: Identifier of the affected record.
  - `timestamp`: Precise ISO 8601 UTC timestamp.
  - `details`: JSON summary of modified properties.
- In the dashboard, select the **Audit Logs** tab to view the reverse-chronological event history.
