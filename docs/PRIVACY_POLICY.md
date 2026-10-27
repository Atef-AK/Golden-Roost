# Privacy Policy for Golden Roost

**Last Updated:** October 27, 2026  
**Effective Date:** October 27, 2026  
**Application:** Golden Roost (`com.goldenroost.app`)  
**Data Controller:** Golden Roost Development Team (`atef.akrem.dev@gmail.com`)

---

## 1. Introduction

Welcome to **Golden Roost** ("we", "our", or "us"). We respect your privacy and are committed to protecting the operational, financial, and personal data you generate while using our poultry farm management mobile application.

This Privacy Policy explains what information Golden Roost collects, how it is used, where it is stored, and the rights you have concerning your data in compliance with global privacy regulations, including the European Union General Data Protection Regulation (GDPR), the California Consumer Privacy Act (CCPA), and Google Play Developer Policies.

---

## 2. Information We Collect and Where It Lives

### 2.1 Local Farm Management Data (Stored Exclusively on Your Device by Default)
Golden Roost is an **offline-first** application. When you use Golden Roost without enabling cloud synchronization, all of your farm data remains sandboxed locally on your physical device in an encrypted/private SQLite database. This includes:
- **Flock Profiles:** Species, breeds, counts, acquisition/hatch dates, housing locations.
- **Egg Records & Commercial Sales:** Daily collection numbers, crack rates, customer names, sales revenues.
- **Feed Ledgers:** Feed types, stock inventory, batch purchase expenses, daily flock feeding records.
- **Incubation Logs:** Machine models, egg setting batches, candling fertility readings, hatch rates.
- **Farm Financials:** Operating expenses, capital equipment investments, income ledgers.
- **Health & Tasks:** Vaccination schedules, medication logs, biosecurity checklists.

We do **not** transmit, sell, or inspect your local farm operational records on our servers without your explicit consent.

### 2.2 Optional Cloud Account & Synchronization Data
If you voluntarily choose to enable **Cloud Synchronization** in Farm Settings:
- **Account Credentials:** We collect your email address and a generated Firebase Authentication User ID (UID).
- **Synchronized Farm Records:** A secure encrypted mirror of your farm records is stored in private Google Cloud Firestore subcollections (`/users/{uid}/...`) accessible only to your authenticated credentials.

### 2.3 Diagnostic, Crash & Device Information
To ensure software stability across Android device hardware:
- We may collect anonymous technical information such as device model, OS version, application version, and automated crash stack traces.
- This data is aggregated and does not identify individual farms or users.

### 2.4 Advertising & Commercial Identifiers (AdMob)
Golden Roost integrates the Google Mobile Ads SDK (AdMob) to display optional, non-intrusive banner advertisements:
- Google AdMob may process your device's Google Advertising ID (GAID), IP address, and general diagnostic information to serve advertisements.
- In jurisdictions requiring consent (EEA, UK, Switzerland, California), we present a certified Consent Management Platform (CMP) dialog. Users can choose non-personalized ads or disable banner ads entirely in the app's settings without paying a fee.

---

## 3. How We Use Your Information

We use the information we collect strictly to:
1. Provide core farm management tools, flock calculations, egg inventory reservations, and financial accounting.
2. Synchronize your farm records across your authorized personal devices when you activate cloud sync.
3. Deliver scheduled farm reminders (vaccinations, candling alerts, feeding tasks) locally on your device.
4. Deliver push notifications for critical agricultural alerts and new veterinary articles (if push notifications are enabled).
5. Display non-intrusive advertising and curated equipment links to support ongoing software development.

We will **never** sell, rent, or trade your farm operational data to third-party data brokers, agricultural commodity speculators, or marketing agencies.

---

## 4. Third-Party Service Providers

Golden Roost works with select enterprise service providers that adhere to rigorous data protection standards:

| Provider | Purpose | Privacy Policy |
| :--- | :--- | :--- |
| **Google Firebase** | Authentication, Cloud Firestore & Cloud Messaging | [Firebase Privacy](https://firebase.google.com/support/privacy) |
| **Google AdMob** | Banner Advertising & Consent Management | [Google Privacy & Terms](https://policies.google.com/technologies/ads) |
| **Affiliate Networks** (Amazon, AliExpress) | Curated Equipment Referral Links | [Amazon Privacy](https://www.amazon.com/privacy) / [AliExpress Privacy](https://terms.alicdn.com/legal-agreement/terms/suit.htm) |

---

## 5. Medical & Veterinary Disclaimer

Golden Roost provides veterinary reference articles, medication schedules, and biosecurity checklists for educational purposes only. **This content does not constitute formal veterinary medical advice or on-site diagnosis.** 

Always consult a licensed veterinarian or authorized government agricultural extension service for disease diagnosis, prescription antimicrobial dosing, or statutory disease reporting (e.g. Highly Pathogenic Avian Influenza).

---

## 6. Affiliate Marketing Disclosure

Golden Roost participates in curated affiliate marketing programs. When you click on equipment links in our Products Catalogue and make a purchase, Golden Roost may earn an affiliate referral commission at no additional cost to you. Products are selected based on editorial utility for poultry farmers.

---

## 7. Your Data Rights & Deletion Protocols

Regardless of your geographic location, Golden Roost honors fundamental privacy rights:
- **Right to Access & Portability:** You can export your entire farm database at any time using our built-in **JSON Backup Tool** or **CSV Exporter**.
- **Right to Rectification:** You can edit or correct any flock, egg, feed, or financial record directly within the app.
- **Right to Erasure / Deletion:**
  - **In-App:** Go to **Settings -> Request Account & Cloud Data Deletion**.
  - **Web Deletion Portal:** Visit our public deletion portal at [https://atef-ak.github.io/Golden-Roost/delete-account](https://atef-ak.github.io/Golden-Roost/delete-account).
  - All cloud-synchronized records and authentication accounts will be permanently destroyed within 30 days.
  - Local device records can be deleted instantly by clearing app storage or uninstalling the app.

---

## 8. Children's Privacy

Golden Roost is a professional agricultural business application not directed at children under the age of 13 (or 16 in the European Union). We do not knowingly collect personal information from children. If you believe a child has provided us with personal data, please contact us immediately.

---

## 9. Contact Us

If you have questions, concerns, or requests regarding this Privacy Policy or our data handling practices, please contact our Data Protection Lead:

- **Email:** `atef.akrem.dev@gmail.com`
- **Developer Organization:** Golden Roost Poultry Technologies
- **Postal Address:** Bizerte / Tunis, Tunisia
- **GitHub Repository:** [https://github.com/Atef-AK/Golden-Roost](https://github.com/Atef-AK/Golden-Roost)
