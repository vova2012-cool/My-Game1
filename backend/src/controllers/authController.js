import bcrypt from 'bcryptjs';
import { User } from '../models/User.js';
import { signToken } from '../utils/jwt.js';

function buildAuthResponse(user) {
  const token = signToken({ userId: user._id.toString() });
  return {
    token,
    user: {
      id: user._id,
      email: user.email,
      phone: user.phone,
      displayName: user.displayName,
      avatarUrl: user.avatarUrl,
      bio: user.bio,
      status: user.status,
    },
  };
}

export async function register(req, res) {
  const { email, phone, password, displayName } = req.body;

  if ((!email && !phone) || !password || !displayName) {
    return res.status(400).json({ message: 'email/phone, password, displayName required' });
  }

  const existing = await User.findOne({
    $or: [
      ...(email ? [{ email }] : []),
      ...(phone ? [{ phone }] : []),
    ],
  });

  if (existing) {
    return res.status(409).json({ message: 'User already exists' });
  }

  const passwordHash = await bcrypt.hash(password, 10);
  const user = await User.create({ email, phone, passwordHash, displayName });

  return res.status(201).json(buildAuthResponse(user));
}

export async function login(req, res) {
  const { email, phone, password } = req.body;

  if ((!email && !phone) || !password) {
    return res.status(400).json({ message: 'email or phone and password are required' });
  }

  const user = await User.findOne({
    $or: [
      ...(email ? [{ email }] : []),
      ...(phone ? [{ phone }] : []),
    ],
  });

  if (!user) {
    return res.status(401).json({ message: 'Invalid credentials' });
  }

  const valid = await bcrypt.compare(password, user.passwordHash);
  if (!valid) {
    return res.status(401).json({ message: 'Invalid credentials' });
  }

  user.status = 'online';
  user.lastSeenAt = new Date();
  await user.save();

  return res.json(buildAuthResponse(user));
}

export async function me(req, res) {
  return res.json({
    user: {
      id: req.user._id,
      email: req.user.email,
      phone: req.user.phone,
      displayName: req.user.displayName,
      avatarUrl: req.user.avatarUrl,
      bio: req.user.bio,
      status: req.user.status,
      lastSeenAt: req.user.lastSeenAt,
    },
  });
}
