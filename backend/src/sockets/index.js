import { verifyToken } from '../utils/jwt.js';
import { User } from '../models/User.js';

export function registerSocketHandlers(io, onlineUsers) {
  io.use(async (socket, next) => {
    try {
      const { token } = socket.handshake.auth;
      if (!token) {
        return next(new Error('Unauthorized'));
      }
      const decoded = verifyToken(token);
      const user = await User.findById(decoded.userId);
      if (!user) {
        return next(new Error('Unauthorized'));
      }
      socket.user = user;
      return next();
    } catch (error) {
      return next(new Error('Unauthorized'));
    }
  });

  io.on('connection', async (socket) => {
    const userId = socket.user._id.toString();
    onlineUsers.set(userId, socket.id);

    socket.user.status = 'online';
    socket.user.lastSeenAt = new Date();
    await socket.user.save();

    socket.emit('session:ready', { userId });
    io.emit('presence:update', { userId, status: 'online' });

    socket.on('chat:join', ({ chatId }) => {
      socket.join(chatId);
    });

    socket.on('chat:leave', ({ chatId }) => {
      socket.leave(chatId);
    });

    socket.on('typing:start', ({ chatId }) => {
      socket.to(chatId).emit('typing:start', { chatId, userId });
    });

    socket.on('typing:stop', ({ chatId }) => {
      socket.to(chatId).emit('typing:stop', { chatId, userId });
    });

    socket.on('disconnect', async () => {
      onlineUsers.delete(userId);
      socket.user.status = 'offline';
      socket.user.lastSeenAt = new Date();
      await socket.user.save();
      io.emit('presence:update', { userId, status: 'offline', lastSeenAt: socket.user.lastSeenAt });
    });
  });
}
