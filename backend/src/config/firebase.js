import admin from 'firebase-admin';
import { env } from './env.js';

let app = null;

export function initFirebase() {
  if (!env.useFirebase) {
    console.log('[Push] Firebase disabled, using mock mode');
    return null;
  }

  if (app) {
    return app;
  }

  app = admin.initializeApp({
    credential: admin.credential.cert({
      projectId: env.firebaseProjectId,
      clientEmail: env.firebaseClientEmail,
      privateKey: env.firebasePrivateKey,
    }),
  });

  console.log('[Push] Firebase initialized');
  return app;
}

export function getFirebaseMessaging() {
  if (!app) {
    return null;
  }
  return admin.messaging(app);
}
