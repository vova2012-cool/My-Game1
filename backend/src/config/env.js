import dotenv from 'dotenv';

dotenv.config();

export const env = {
  port: process.env.PORT || 8080,
  mongoUri: process.env.MONGODB_URI || 'mongodb://localhost:27017/black_red_messenger',
  jwtSecret: process.env.JWT_SECRET || 'dev_secret',
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '7d',
  clientUrl: process.env.CLIENT_URL || '*',
  useFirebase: process.env.USE_FIREBASE === 'true',
  firebaseProjectId: process.env.FIREBASE_PROJECT_ID || '',
  firebaseClientEmail: process.env.FIREBASE_CLIENT_EMAIL || '',
  firebasePrivateKey: (process.env.FIREBASE_PRIVATE_KEY || '').replace(/\\n/g, '\n'),
};
