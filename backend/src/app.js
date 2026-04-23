import express from 'express';
import cors from 'cors';
import morgan from 'morgan';

import authRoutes from './routes/authRoutes.js';
import chatRoutes from './routes/chatRoutes.js';
import profileRoutes from './routes/profileRoutes.js';
import { errorHandler } from './middleware/errorHandler.js';

export function createApp(messageRoutes) {
  const app = express();
  app.use(cors());
  app.use(morgan('dev'));
  app.use(express.json({ limit: '10mb' }));

  app.get('/health', (req, res) => {
    res.json({ status: 'ok' });
  });

  app.use('/api/auth', authRoutes);
  app.use('/api/chats', chatRoutes);
  app.use('/api/messages', messageRoutes);
  app.use('/api/profile', profileRoutes);

  app.use(errorHandler);

  return app;
}
