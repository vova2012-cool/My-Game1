import mongoose from 'mongoose';

const userSchema = new mongoose.Schema(
  {
    email: { type: String, trim: true, lowercase: true, unique: true, sparse: true },
    phone: { type: String, trim: true, unique: true, sparse: true },
    passwordHash: { type: String, required: true },
    displayName: { type: String, required: true, trim: true },
    avatarUrl: { type: String, default: '' },
    bio: { type: String, default: 'Available' },
    status: { type: String, enum: ['online', 'offline', 'away'], default: 'offline' },
    lastSeenAt: { type: Date, default: Date.now },
    fcmTokens: [{ type: String }],
  },
  { timestamps: true }
);

userSchema.index({ displayName: 'text', email: 'text', phone: 'text' });

export const User = mongoose.model('User', userSchema);
