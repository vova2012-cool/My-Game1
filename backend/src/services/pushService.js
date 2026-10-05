import { getFirebaseMessaging } from '../config/firebase.js';

export class PushService {
  async sendToTokens(tokens, title, body, data = {}) {
    if (!tokens?.length) {
      return { successCount: 0, failureCount: 0 };
    }

    const messaging = getFirebaseMessaging();
    if (!messaging) {
      console.log('[Push Mock]', { tokensCount: tokens.length, title, body, data });
      return { successCount: tokens.length, failureCount: 0 };
    }

    const response = await messaging.sendEachForMulticast({
      tokens,
      notification: { title, body },
      data,
    });

    return response;
  }
}

export const pushService = new PushService();
