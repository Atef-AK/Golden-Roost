# Golden Roost — Google Play Release Checklist & Store Submission Suite

**Package ID:** `com.goldenroost.app`  
**Target SDK:** 36 (Android 15+ Compliant)  
**Min SDK:** 21 (Android 5.0 Lollipop)  
**Format:** Android App Bundle (`.aab`)

---

## 1. Technical Toolchain & Build Configuration

Verify technical requirements before generating the release bundle:
- **Compile SDK Version:** 36
- **Target SDK Version:** 36
- **Min SDK Version:** 21
- **Gradle Version:** Gradle 8.x+ with Android Gradle Plugin 8.7+
- **JDK:** Java 17 / OpenJDK 17
- **Architecture Support:** `arm64-v8a`, `armeabi-v7a`, `x86_64`

---

## 2. Release Keystore Generation & Signing Setup

Google Play requires all release App Bundles to be signed with a secure private cryptographic key.

### 2.1 Generate Production Keystore
Execute the following PowerShell command (substitute your real password and farm details):
```powershell
keytool -genkey -v -keystore "c:\DEV\Antigravity\golden-roost-release.jks" `
  -keyalg RSA -keysize 2048 -validity 10000 `
  -alias goldenroost `
  -storetype JKS
```

### 2.2 Create `android/key.properties`
Create a file named `android/key.properties` (this file is excluded from Git via `.gitignore`):
```properties
storePassword=YOUR_SECURE_STORE_PASSWORD
keyPassword=YOUR_SECURE_KEY_PASSWORD
keyAlias=goldenroost
storeFile=c:\\DEV\\Antigravity\\golden-roost-release.jks
```

### 2.3 Verify `build.gradle.kts` Release Signing
In `android/app/build.gradle.kts`, ensure the release signing configuration reads from `key.properties`:
```kotlin
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

signingConfigs {
    create("release") {
        if (keystorePropertiesFile.exists()) {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
}

buildTypes {
    release {
        if (keystorePropertiesFile.exists()) {
            signingConfig = signingConfigs.getByName("release")
        } else {
            gradle.taskGraph.whenReady {
                val isReleaseBuild = allTasks.any { task ->
                    task.name.contains("Release", ignoreCase = true) &&
                    (task.name.startsWith("assemble") || task.name.startsWith("bundle"))
                }
                if (isReleaseBuild && !keystorePropertiesFile.exists()) {
                    throw GradleException(
                        "CRITICAL RELEASE SIGNING ERROR: android/key.properties is missing!\n" +
                        "Production release builds cannot fall back to debug signing.\n" +
                        "Please provide key.properties with storeFile, storePassword, keyAlias, and keyPassword."
                    )
                }
            }
        }
    }
}
```

### 2.4 Google Mobile Ads SDK Configuration
Google Play and the Mobile Ads SDK require `com.google.android.gms.ads.APPLICATION_ID` in `AndroidManifest.xml`.
In `android/app/build.gradle.kts`:
- Development builds fall back to Google's official test App ID: `ca-app-pub-3940256099942544~3347511713`.
- Production builds read `admobAppId` from `android/key.properties`:
```properties
admobAppId=ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX
```
`AndroidManifest.xml` injects this dynamically via `${admobAppId}`.

---

## 3. Building the Production Release App Bundle (.aab)

Run the following command in the workspace root to generate the optimized, code-shrunk Android App Bundle:
```bash
flutter build appbundle --release
```
**Output Artifact:**  
`build/app/outputs/bundle/release/app-release.aab`

---

## 4. Google Play Store Listing Copy (Trilingual Suite)

Google Play allows distinct localized descriptions for English, French, and Arabic.

---

### 🇬🇧 English (`en-US` / Global)

**App Title** *(Max 30 characters)*:  
`Golden Roost: Poultry Manager`

**Short Description** *(Max 80 characters)*:  
`Smart offline poultry farm manager: flocks, eggs, feed, incubator & finances.`

**Full Description**:  
```
Take complete control of your poultry farm with Golden Roost — the professional, offline-first management platform designed for poultry producers, hatchery operators, and smallholder farmers.

Whether you raise laying hens, broilers, quails, ducks, or turkeys, Golden Roost provides precision tracking without requiring an active internet connection.

KEY FEATURES:

🐓 COMPLETE FLOCK & BIRD LIFECYCLE
- Track population dynamics: starting counts, purchases, natural hatches, mortalities, culls, and sales.
- Live population recalculated deterministically with full sex breakdown (hens & roosters).
- Calibrate age automatically using true hatch or acquisition dates.
- Filter by purpose: Layers, Broilers, Breeders, or Dual-Purpose.

🥚 EGG HARVESTING & COMMERCIAL SALES
- Log daily collections: clean eggs, cracked, damaged, and rejects.
- Real-time laying rate percentage computed strictly on mature laying females.
- Inventory reservation engine: prevents overselling eggs dedicated to incubation batches.
- Commercial sales ledger with customer tracking, debt balances, and unit pricing.

🌽 FEED SILO & INVENTORY MANAGEMENT
- Manage multiple feed formulations: Starter, Grower, Layer, Finisher, and Custom.
- Daily consumption forecasting based on calibrated species nutrition curves.
- Burn-rate predictor: warns you exactly how many days of feed remain before depletion.
- Atomic stock deduction prevents negative inventory.

🐣 MULTI-STAGE INCUBATION & HATCHERY WIZARD
- Profiles for Chickens (21d), Quails (17d), Ducks (28d), Turkeys, and Geese.
- Log candling milestones, fertility checks, incubator temperature, and humidity.
- Calculate exact fertility rate, hatch rate from set, and hatch rate from fertile eggs.
- 1-Tap Chick Transfer: transfers hatched chicks directly into a new flock without double-counting financial expenses.

💰 FINANCIALS, CASH FLOW & ELECTRICITY
- Net operating results computed from operational revenue minus expenses.
- Capital investment tracking separated from daily operating costs.
- Built-in electricity calculator: meter readings or wattage-hours formula with custom tariffs.

📚 VETERINARY ADVISORY & EQUIPMENT
- Peer-reviewed veterinary articles on biosecurity, disease prevention, and nutrition.
- Curated equipment catalogue with verified incubators and poultry supplies.

🌐 OFFLINE-FIRST & MULTILINGUAL
- 100% functional without internet connectivity.
- Full native support for English, French (Français), and Arabic (العربية RTL).
- Optional cloud sync with Firebase and instant JSON database backup.

Download Golden Roost today and elevate your poultry productivity to professional heights!
```

---

### 🇫🇷 Français (`fr-FR` / Francophone)

**Titre de l'application** *(Max 30 caractères)* :  
`Golden Roost : Élevage Avicole`

**Description courte** *(Max 80 caractères)* :  
`Gestionnaire avicole hors-ligne : volailles, pontes, aliments, couvoir et bilan.`

**Description complète** :  
```
Prenez le contrôle total de votre élevage avicole avec Golden Roost — l'application professionnelle hors-ligne conçue pour les éleveurs de volailles, les couvoirs et les fermes avicoles modernes.

Que vous éleviez des poules pondeuses, des poulets de chair, des cailles, des canards ou des dindes, Golden Roost vous garantit une gestion rigoureuse, même sans connexion Internet.

FONCTIONNALITÉS CLÉS :

🐓 GESTION DES VOLAILLES ET DU CHEPTEL
- Suivi rigoureux des effectifs : effectif initial, achats, éclosions, mortalités, réformes et ventes.
- Recalcul déterministe de la population avec répartition par sexe (mâles et femelles).
- Calcul précis de l'âge en semaines et jours à partir de la date d'éclosion réelle.
- Classification par vocation : Pondeuses, Chair, Reproducteurs ou Mixte.

🥚 COLLECTE DES ŒUFS ET COMMERCIALISATION
- Enregistrement quotidien des pontes : œufs propres, fêlés, cassés et rebuts.
- Taux de ponte réel calculé uniquement sur les femelles matures en âge de pondre.
- Gestion intelligente des réservations : empêche la vente d'œufs déjà réservés pour l'incubation.
- Facturation des ventes d'œufs avec gestion des créances clients et prix unitaire.

🌽 SILO D'ALIMENTS ET CONSOMMATION
- Gestion des stocks : Démarrage, Croissance, Ponte, Finition et formules personnalisées.
- Prévision journalière basée sur les courbes de consommation réelles par espèce et par âge.
- Estimation d'autonomie : visualisez exactement le nombre de jours d'aliments restants avant rupture.

🐣 COUVOIR ET GESTION DE L'INCUBATION
- Profils configurés pour Poules (21j), Cailles (17j), Canards (28j), Dindes et Oies.
- Suivi du mirage au 7e et 14e jour, taux de fertilité, température et hygrométrie.
- Taux d'éclosion automatique sur œufs mis en incubation et sur œufs fertiles.
- Transfert de poussins en un clic vers un nouveau lot sans double comptabilisation financière.

💰 FINANCES, RÉSULTAT NET ET ÉLECTRICITÉ
- Calcul transparent de la rentabilité : Recettes d'exploitation - Dépenses courantes.
- Distinction stricte entre investissements en matériel et charges d'exploitation.
- Calculateur d'électricité intégré : relevé de compteur ou formule de puissance avec tarif au kWh modifiable.

📚 GUIDE VÉTÉRINAIRE ET MATÉRIEL
- Fiches de santé vétérinaire sur la biosécurité, la prévention des maladies et la nutrition.
- Catalogue de matériel sélectionné (incubateurs automatiques, abreuvoirs, régulateurs).

🌐 100% HORS-LIGNE ET TRILINGUE
- Fonctionne parfaitement sans connexion Internet sur le terrain.
- Support complet du Français, de l'Anglais et de l'Arabe (العربية avec orientation RTL native).
- Sauvegarde JSON intégrée et synchronisation cloud optionnelle.

Téléchargez Golden Roost dès aujourd'hui pour maximiser la rentabilité de votre élevage !
```

---

### 🇹🇳/🇸🇦 العربية (`ar` / MENA)

**اسم التطبيق** *(أقل من 30 حرفاً)*:  
`Golden Roost: إدارة مزارع الدواجن`

**الوصف القصير** *(أقل من 80 حرفاً)*:  
`إدارة شاملة لمزارع الدواجن دون إنترنت: القطعان، البيض، الأعلاف، التفقيس والأرباح.`

**الوصف الكامل**:  
```
تحكّم بشكل كامل في مزرعة الدواجن الخاصة بك مع Golden Roost — التطبيق الاحترافي المتكامل لإدارة حقول الدواجن، الحاضنات والمفارخ، المصمم ليعمل بكفاءة مطلقة دون الحاجة للاتصال بالإنترنت.

سواء كنت تدير قطيع دجاج بياض، دجاج لحم (تسمين)، سمان، بط، أو حبش، يوفر لك Golden Roost الدقة والسهولة في متابعة أدق التفاصيل اليومية للمزرعة.

أبرز مميزات التطبيق:

🐓 إدارة القطعان وحركة الطيور:
- تسجيل حركة الطيور: الأعداد الابتدائية، المشتريات، المواليد، النفوق، الاستبعاد، والمبيعات.
- حساب فوري دقيق لعدد الطيور الحية وتوزيع الذكور والإناث بدقة تامة.
- حساب دقيق لعمر الطيور بالأسابيع والأيام وفق تاريخ الفقس الفعلي.
- تصنيف نوع الإنتاج: بيض مائدة، لحم وتسمين، أمهات وتفريخ، أو قطيع مزدوج.

🥚 جمع وتسويق البيض:
- تسجيل جمع البيض اليومي: سليم، مشروخ، مكسور، وتالف.
- حساب نسبة وضع البيض الفعلية بالاعتماد الحصري على الإناث البالغة المؤهلة للإنتاج.
- نظام حجز البيض: يمنع بيع البيض المخصص مسبقاً لحاضنات التفقيس.
- دفتر مبيعات البيض مع متابعة العملاء، المدفوعات والديون المتبقية.

🌽 مخزون الأعلاف والاستهلاك اليومي:
- إدارة أنواع الأعلاف: بادئ، نامي، بياض، ناهي، وخلطات مخصصة.
- التنبؤ الذكي بحاجة القطيع من العلف استناداً لمعادلات التغذية الدقيقة لكل سلالة وعمر.
- تنبيه الأيام المتبقية: حساب عدد الأيام حتى نفاد المخزون لتفادي انقطاع العلف.

🐣 إدارة حاضنات البيض والتفقيس:
- برامج مسبقة الضبط للدجاج (21 يوماً)، السمان (17 يوماً)، البط (28 يوماً) وغيرها.
- تسجيل الفحص الضوئي، نسبة الخصوبة، درجات الحرارة والرطوبة اليومية.
- حساب نسب الخصوبة ونسب الفقس الإجمالية ومن البيض المخصب.
- معالج نقل الصيصان: تحويل الكتاكيت الفاقسة مباشرة إلى قطيع جديد دون تكرار تكاليف الشراء.

💰 الحسابات المالية وفاتورة الكهرباء:
- كشف الأرباح التشغيلية: الإيرادات ناقص المصروفات الفعلية.
- فصل النفقات الاستثمارية الرأسمالية (الأقفاص والمعدات) عن التكاليف التشغيلية (العلف والأدوية).
- حاسبة استهلاك الكهرباء: قراءة العداد أو حساب قدرة الأجهزة بالواط مع تعديل سعر الكيلوواط/ساعة.

📚 المقالات البيطرية والتجهيزات:
- مقالات وإرشادات بيطرية معتمدة حول الأمن الحيوي، الوقاية من الأمراض والتغذية السليمة.
- دليل معدات وأجهزة الدواجن مع روابط التزود المباشرة.

🌐 بدون إنترنت ومتعدد اللغات بالكامل:
- يعمل التطبيق 100% دون إنترنت في الحقول والمزارع النائية.
- واجهة كاملة باللغة العربية مع دعم تام للكتابة من اليمين إلى اليسار (RTL) والأرقام الغربية.
- دعم كامل للفرنسية والإنجليزية، ونسخ احتياطي فوري لقاعدة البيانات.

حمّل Golden Roost اليوم وارتقِ بإنتاجية مزرعتك إلى أعلى المعايير الاحترافية!
```

---

## 5. Google Play Data Safety Declaration Sheet

Use these exact answers when completing the **Data Safety** questionnaire in Google Play Console:

| Section | Question | Answer |
| :--- | :--- | :--- |
| **Data Collection** | Does your app collect or share any user data? | **Yes** *(Cloud sync & AdMob)* |
| **Data in Transit** | Is all user data encrypted in transit? | **Yes** *(HTTPS / TLS 1.3)* |
| **Account Deletion** | Do you provide a way for users to request data deletion? | **Yes** *(In-app dialog + Web URL)* |
| **Personal Info** | Email address | Collected optionally for Cloud Sync authentication. Not shared. |
| **Financial Info** | Purchase history | Stored locally on device. Not shared. |
| **Approximate Location** | Coarse location | Collected by Google AdMob if ads are active. Shared with ad networks. |
| **App Diagnostics** | Crash logs & diagnostics | Collected for app stability monitoring. |
| **Device Identifiers** | Advertising ID (GAID) | Collected by Google Mobile Ads SDK for advertising. |

---

## 6. Pre-Submission Verification Steps

1. [x] Minimum SDK set to 21, Target SDK set to 36.
2. [x] Package name confirmed as `com.goldenroost.app`.
3. [x] Automated test suite executed and 100% passing (`flutter test`).
4. [x] Static analyzer clean with 0 warnings or errors (`flutter analyze`).
5. [x] Privacy policy hosted and URL ready for submission.
6. [x] Account deletion web page ready and accessible.
7. [x] Signed App Bundle generated with valid production keystore.
8. [x] Store listing descriptions ready in English, French, and Arabic.
