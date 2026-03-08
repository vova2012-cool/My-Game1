import bcrypt from 'bcryptjs';
import { connectDatabase } from '../src/config/database.js';
import { User } from '../src/models/User.js';
import { Chat } from '../src/models/Chat.js';
import { Message } from '../src/models/Message.js';

async function seed() {
  await connectDatabase();

  await Promise.all([User.deleteMany({}), Chat.deleteMany({}), Message.deleteMany({})]);

  const passwordHash = await bcrypt.hash('password123', 10);

  const alice = await User.create({
    email: 'alice@demo.com',
    passwordHash,
    displayName: 'Alice Nova',
    bio: 'Cyber navigator',
  });

  const bob = await User.create({
    email: 'bob@demo.com',
    passwordHash,
    displayName: 'Bob Vector',
    bio: 'Dark mode forever',
  });

  const chat = await Chat.create({
    type: 'direct',
    members: [alice._id, bob._id],
    admins: [alice._id, bob._id],
  });

  const firstMessage = await Message.create({
    chatId: chat._id,
    senderId: alice._id,
    text: 'Welcome to Black Red Messenger.',
    readBy: [{ userId: alice._id }],
    deliveredTo: [alice._id, bob._id],
  });

  chat.lastMessageId = firstMessage._id;
  await chat.save();

  console.log('Database seeded');
  process.exit(0);
}

seed();
