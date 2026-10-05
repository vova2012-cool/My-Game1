import mongoose from 'mongoose';

const messageSchema = new mongoose.Schema(
  {
    chatId: { type: mongoose.Schema.Types.ObjectId, ref: 'Chat', required: true, index: true },
    senderId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    text: { type: String, trim: true, default: '' },
    attachments: [
      {
        fileName: String,
        url: String,
        mimeType: String,
        size: Number,
      },
    ],
    editedAt: { type: Date, default: null },
    deletedForEveryone: { type: Boolean, default: false },
    readBy: [
      {
        userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
        readAt: { type: Date, default: Date.now },
      },
    ],
    deliveredTo: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  },
  { timestamps: true }
);

messageSchema.index({ chatId: 1, createdAt: -1 });

export const Message = mongoose.model('Message', messageSchema);
