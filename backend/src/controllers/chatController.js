import mongoose from 'mongoose';
import { Chat } from '../models/Chat.js';
import { Message } from '../models/Message.js';

function normalizeChat(chat, userId) {
  const pinned = chat.pinnedBy.some((id) => id.toString() === userId.toString());
  return {
    id: chat._id,
    type: chat.type,
    title: chat.title,
    avatarUrl: chat.avatarUrl,
    members: chat.members,
    admins: chat.admins,
    pinned,
    lastMessage: chat.lastMessageId,
    updatedAt: chat.updatedAt,
  };
}

export async function createDirectChat(req, res) {
  const { peerUserId } = req.body;

  if (!peerUserId || !mongoose.Types.ObjectId.isValid(peerUserId)) {
    return res.status(400).json({ message: 'Valid peerUserId required' });
  }

  const selfId = req.user._id;

  let chat = await Chat.findOne({
    type: 'direct',
    members: { $all: [selfId, peerUserId], $size: 2 },
  }).populate('members', 'displayName avatarUrl status');

  if (!chat) {
    chat = await Chat.create({
      type: 'direct',
      members: [selfId, peerUserId],
      admins: [selfId, peerUserId],
    });
    chat = await chat.populate('members', 'displayName avatarUrl status');
  }

  return res.status(201).json({ chat: normalizeChat(chat, selfId) });
}

export async function createGroupChat(req, res) {
  const { title, memberIds = [] } = req.body;

  if (!title || memberIds.length < 1) {
    return res.status(400).json({ message: 'title and at least one member required' });
  }

  const uniqueMembers = [...new Set([req.user._id.toString(), ...memberIds])];

  let chat = await Chat.create({
    type: 'group',
    title,
    members: uniqueMembers,
    admins: [req.user._id],
  });

  chat = await chat.populate('members', 'displayName avatarUrl status');

  return res.status(201).json({ chat: normalizeChat(chat, req.user._id) });
}

export async function listChats(req, res) {
  const { search = '' } = req.query;
  const userId = req.user._id;

  const chats = await Chat.find({
    members: userId,
    ...(search
      ? {
          $or: [
            { title: { $regex: search, $options: 'i' } },
          ],
        }
      : {}),
  })
    .populate('members', 'displayName avatarUrl status')
    .populate('lastMessageId')
    .sort({ updatedAt: -1 });

  return res.json({ chats: chats.map((chat) => normalizeChat(chat, userId)) });
}

export async function pinChat(req, res) {
  const { chatId } = req.params;
  const userId = req.user._id;

  const chat = await Chat.findOne({ _id: chatId, members: userId });
  if (!chat) {
    return res.status(404).json({ message: 'Chat not found' });
  }

  const hasPin = chat.pinnedBy.some((id) => id.toString() === userId.toString());
  if (!hasPin) {
    chat.pinnedBy.push(userId);
    await chat.save();
  }

  return res.status(204).send();
}

export async function unpinChat(req, res) {
  const { chatId } = req.params;
  const userId = req.user._id;

  const chat = await Chat.findOne({ _id: chatId, members: userId });
  if (!chat) {
    return res.status(404).json({ message: 'Chat not found' });
  }

  chat.pinnedBy = chat.pinnedBy.filter((id) => id.toString() !== userId.toString());
  await chat.save();

  return res.status(204).send();
}

export async function getChatMessages(req, res) {
  const { chatId } = req.params;
  const userId = req.user._id;

  const chat = await Chat.findOne({ _id: chatId, members: userId });
  if (!chat) {
    return res.status(404).json({ message: 'Chat not found' });
  }

  const messages = await Message.find({ chatId }).sort({ createdAt: -1 }).limit(50);

  return res.json({ messages: messages.reverse() });
}
