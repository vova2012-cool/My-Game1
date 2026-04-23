import { Chat } from '../models/Chat.js';
import { Message } from '../models/Message.js';
import { User } from '../models/User.js';
import { pushService } from '../services/pushService.js';
import { storageService } from '../services/storageService.js';

export function makeMessageController(io, onlineUsers) {
  async function sendMessage(req, res) {
    const { chatId, text = '' } = req.body;

    const chat = await Chat.findById(chatId);
    if (!chat || !chat.members.some((id) => id.toString() === req.user._id.toString())) {
      return res.status(404).json({ message: 'Chat not found' });
    }

    const message = await Message.create({
      chatId,
      senderId: req.user._id,
      text,
      deliveredTo: [req.user._id],
      readBy: [{ userId: req.user._id }],
    });

    chat.lastMessageId = message._id;
    chat.updatedAt = new Date();
    await chat.save();

    const payload = { message };
    io.to(chatId).emit('message:new', payload);

    const recipients = await User.find({ _id: { $in: chat.members, $ne: req.user._id } });

    await Promise.all(
      recipients.map(async (recipient) => {
        const isOnline = onlineUsers.has(recipient._id.toString());
        if (!isOnline) {
          await pushService.sendToTokens(
            recipient.fcmTokens,
            req.user.displayName,
            text || 'Sent an attachment',
            { chatId: chatId.toString(), messageId: message._id.toString() }
          );
        }
      })
    );

    return res.status(201).json({ message });
  }

  async function uploadImage(req, res) {
    const { chatId } = req.body;
    const chat = await Chat.findById(chatId);
    if (!chat || !chat.members.some((id) => id.toString() === req.user._id.toString())) {
      return res.status(404).json({ message: 'Chat not found' });
    }

    if (!req.file) {
      return res.status(400).json({ message: 'File required' });
    }

    const attachment = await storageService.upload(req.file);

    const message = await Message.create({
      chatId,
      senderId: req.user._id,
      attachments: [attachment],
      deliveredTo: [req.user._id],
      readBy: [{ userId: req.user._id }],
    });

    chat.lastMessageId = message._id;
    chat.updatedAt = new Date();
    await chat.save();

    io.to(chatId).emit('message:new', { message });

    return res.status(201).json({ message });
  }

  async function editMessage(req, res) {
    const { messageId } = req.params;
    const { text } = req.body;

    const message = await Message.findById(messageId);
    if (!message) {
      return res.status(404).json({ message: 'Message not found' });
    }
    if (message.senderId.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Forbidden' });
    }

    message.text = text;
    message.editedAt = new Date();
    await message.save();

    io.to(message.chatId.toString()).emit('message:updated', { message });

    return res.json({ message });
  }

  async function deleteMessage(req, res) {
    const { messageId } = req.params;

    const message = await Message.findById(messageId);
    if (!message) {
      return res.status(404).json({ message: 'Message not found' });
    }
    if (message.senderId.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Forbidden' });
    }

    message.text = '';
    message.attachments = [];
    message.deletedForEveryone = true;
    await message.save();

    io.to(message.chatId.toString()).emit('message:deleted', { messageId: message._id });

    return res.status(204).send();
  }

  async function markRead(req, res) {
    const { messageId } = req.params;
    const message = await Message.findById(messageId);

    if (!message) {
      return res.status(404).json({ message: 'Message not found' });
    }

    const hasRead = message.readBy.some((entry) => entry.userId.toString() === req.user._id.toString());
    if (!hasRead) {
      message.readBy.push({ userId: req.user._id, readAt: new Date() });
      await message.save();
    }

    io.to(message.chatId.toString()).emit('message:read', {
      messageId: message._id,
      userId: req.user._id,
      readAt: new Date().toISOString(),
    });

    return res.status(204).send();
  }

  return {
    sendMessage,
    uploadImage,
    editMessage,
    deleteMessage,
    markRead,
  };
}
