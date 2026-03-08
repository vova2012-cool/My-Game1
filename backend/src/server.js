import http from 'http';
import { Server } from 'socket.io';

import { env } from './config/env.js';
import { connectDatabase } from './config/database.js';
import { initFirebase } from './config/firebase.js';
import { createApp } from './app.js';
import { makeMessageController } from './controllers/messageController.js';
import { createMessageRoutes } from './routes/messageRoutes.js';
import { registerSocketHandlers } from './sockets/index.js';

const onlineUsers = new Map();

async function bootstrap() {
  await connectDatabase();
  initFirebase();

  const io = new Server({
    cors: { origin: '*' },
  });

  const messageController = makeMessageController(io, onlineUsers);
  const messageRoutes = createMessageRoutes(messageController);

  const app = createApp(messageRoutes);

  const server = http.createServer(app);
  io.attach(server);

  registerSocketHandlers(io, onlineUsers);

  server.listen(env.port, () => {
    console.log(`[Server] API listening on ${env.port}`);
  });
}

bootstrap().catch((error) => {
  console.error('[Bootstrap Error]', error);
  process.exit(1);
});
