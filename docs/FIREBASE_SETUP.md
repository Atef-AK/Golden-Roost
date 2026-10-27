# Golden Roost — Firebase Cloud Integration & Setup Guide

**Application ID:** `com.goldenroost.app`  
**Firebase Services:** Cloud Firestore, Firebase Authentication, Firebase Cloud Messaging (FCM)

---

## 1. Firebase Project Creation

1. Navigate to the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add project** and name it `Golden-Roost` (or your preferred identifier).
3. Disable or enable Google Analytics according to your preference (for Google Play compliance, keep crash analytics enabled).
4. Click **Create project**.

---

## 2. Registering the Android Application

1. In the Project Overview screen, click the **Android** icon (`+ Add app`).
2. Enter the exact Android package name:
   ```
   com.goldenroost.app
   ```
3. Enter the App nickname: `Golden Roost Android`.
4. **Obtain Debug SHA-1 & SHA-256 Fingerprints:**
   Open PowerShell in the workspace and execute:
   ```powershell
   keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
   ```
   Copy the `SHA1:` and `SHA256:` hexadecimal strings into Firebase Console.

5. **Obtain Release SHA-1 & SHA-256 Fingerprints:**
   Once you generate your production release keystore (e.g. `golden-roost-release.jks`):
   ```powershell
   keytool -list -v -keystore "C:\path\to\golden-roost-release.jks" -alias goldenroost
   ```
   Add these release fingerprints in Firebase Console -> Project Settings -> Your apps -> Android.

6. Download `google-services.json`.
7. Place the downloaded file into the Android app directory:
   ```
   c:\DEV\Antigravity\Poultry\android\app\google-services.json
   ```

---

## 3. Cloud Firestore Security Rules

Navigate to **Firestore Database** in Firebase Console, click **Rules**, and deploy the following production security rules. These rules ensure:
- Strict multi-tenant user farm data isolation.
- Public read access to educational veterinary articles and equipment products.
- Administrator-only write permissions for remote CMS content.

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper function to check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }

    // Helper function to check if user owns the document
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    // Helper function to check if user has verified admin role
    function isAdmin() {
      return isAuthenticated() && (
        request.auth.token.admin == true ||
        exists(/databases/$(database)/documents/admins/$(request.auth.uid))
      );
    }

    // ==========================================
    // 1. User Isolated Farm Data (Multi-Tenant)
    // ==========================================
    match /users/{userId} {
      allow read, write: if isOwner(userId);

      // Sub-collections for farm domain models
      match /flocks/{document=**} {
        allow read, write: if isOwner(userId);
      }
      match /egg_records/{document=**} {
        allow read, write: if isOwner(userId);
      }
      match /egg_sales/{document=**} {
        allow read, write: if isOwner(userId);
      }
      match /feed_items/{document=**} {
        allow read, write: if isOwner(userId);
      }
      match /feed_transactions/{document=**} {
        allow read, write: if isOwner(userId);
      }
      match /finances/{document=**} {
        allow read, write: if isOwner(userId);
      }
      match /incubation_batches/{document=**} {
        allow read, write: if isOwner(userId);
      }
      match /tasks/{document=**} {
        allow read, write: if isOwner(userId);
      }
      match /electricity/{document=**} {
        allow read, write: if isOwner(userId);
      }
      match /tombstones/{document=**} {
        allow read, write: if isOwner(userId);
      }
    }

    // ==========================================
    // 2. Educational Veterinary Articles (CMS)
    // ==========================================
    match /articles/{articleId} {
      // Anyone can read published articles, including offline anonymous caches
      allow read: if true;
      // Only designated administrators can publish, edit, or delete articles
      allow write: if isAdmin();
    }

    // ==========================================
    // 3. Curated Equipment Products (CMS)
    // ==========================================
    match /poultry_products/{productId} {
      // Anyone can browse curated equipment products and affiliate links
      allow read: if true;
      // Only designated administrators can manage products
      allow write: if isAdmin();
    }

    // ==========================================
    // 4. Notification Campaigns & Broadcasts
    // ==========================================
    match /notification_campaigns/{campaignId} {
      allow read: if isAuthenticated();
      allow write: if isAdmin();
    }

    // ==========================================
    // 5. Admin Directory & Security Audit Logs
    // ==========================================
    match /admins/{adminId} {
      allow read: if isAuthenticated();
      allow write: if false; // Only manageable via Firebase Admin SDK
    }

    match /admin_audit_logs/{logId} {
      allow read: if isAdmin();
      allow create: if isAdmin();
      allow update, delete: if false; // Append-only audit trail
    }
  }
}
```

---

## 4. Cloud Functions for FCM Broadcasts

When an administrator creates a new document in `/notification_campaigns/{campaignId}`, a Firebase Cloud Function automatically dispatches the message to subscribers via Firebase Cloud Messaging.

### `functions/src/index.ts`
```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

export const onNotificationCampaignCreated = functions.firestore
  .document('notification_campaigns/{campaignId}')
  .onCreate(async (snapshot, context) => {
    const campaign = snapshot.data();
    if (!campaign || campaign.status !== 'pending') {
      return null;
    }

    const title = campaign.titleEn || campaign.titleFr || campaign.titleAr || 'Golden Roost Update';
    const body = campaign.bodyEn || campaign.bodyFr || campaign.bodyAr || '';
    const deepLink = campaign.deepLink || 'goldenroost://home';

    const message: admin.messaging.Message = {
      notification: {
        title,
        body,
      },
      data: {
        deepLink,
        campaignId: context.params.campaignId,
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
      topic: campaign.targetAudience === 'all' ? 'all_users' : `lang_${campaign.targetAudience}`,
    };

    try {
      const response = await admin.messaging().send(message);
      await snapshot.ref.update({
        status: 'sent',
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        fcmMessageId: response,
      });
      console.log('Successfully sent broadcast campaign:', response);
      return response;
    } catch (error) {
      console.error('Error sending campaign notification:', error);
      await snapshot.ref.update({
        status: 'failed',
        error: String(error),
      });
      return null;
    }
  });
```

---

## 5. First Administrator Bootstrap

To grant administrator access to the Golden Roost remote CMS, run a Node.js script using the Firebase Admin SDK.

### Step 1: Generate Service Account Key
1. In Firebase Console, go to **Project settings** -> **Service accounts**.
2. Click **Generate new private key** and save it securely as `serviceAccountKey.json`.

### Step 2: Set Admin Claim Script (`bootstrap_admin.js`)
```javascript
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

async function setAdminRole(targetEmail) {
  try {
    const user = await admin.auth().getUserByEmail(targetEmail);
    await admin.auth().setCustomUserClaims(user.uid, { admin: true });
    
    // Also record in the Firestore admins collection
    await admin.firestore().collection('admins').doc(user.uid).set({
      email: targetEmail,
      grantedAt: admin.firestore.FieldValue.serverTimestamp(),
      role: 'super_admin'
    });

    console.log(`Success! User ${targetEmail} (UID: ${user.uid}) is now a Golden Roost Administrator.`);
  } catch (error) {
    console.error('Failed to set admin claim:', error);
  }
}

// Replace with your email address
setAdminRole('atef@goldenroost.com');
```

Execute the script:
```bash
npm install firebase-admin
node bootstrap_admin.js
```
The user will now have verified admin access to the CMS and Firestore write capabilities.
