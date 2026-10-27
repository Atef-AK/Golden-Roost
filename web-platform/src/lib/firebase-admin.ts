import { initializeApp, getApps, cert, App } from 'firebase-admin/app';
import { getAuth, Auth } from 'firebase-admin/auth';
import { getMessaging, Messaging } from 'firebase-admin/messaging';

function getFirebaseAdminApp(): App {
  const existingApps = getApps();
  if (existingApps.length > 0) {
    return existingApps[0]!;
  }

  const projectId =
    process.env.FIREBASE_ADMIN_PROJECT_ID || process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID;
  const clientEmail = process.env.FIREBASE_ADMIN_CLIENT_EMAIL;
  let privateKey = process.env.FIREBASE_ADMIN_PRIVATE_KEY;

  if (privateKey) {
    // Replace escaped newlines from environment variable strings
    privateKey = privateKey.replace(/\\n/g, '\n');
  }

  if (projectId && clientEmail && privateKey) {
    return initializeApp({
      credential: cert({
        projectId,
        clientEmail,
        privateKey,
      }),
    });
  }

  // Fallback for environments with GOOGLE_APPLICATION_CREDENTIALS or local dev
  return initializeApp({
    projectId: projectId || 'golden-roost-app',
  });
}

export const firebaseAdmin = {
  getApp: getFirebaseAdminApp,
  auth: () => getAuth(getFirebaseAdminApp()),
  messaging: () => getMessaging(getFirebaseAdminApp()),
};

export default firebaseAdmin;
