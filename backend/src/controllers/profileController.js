export async function updateProfile(req, res) {
  const { displayName, bio, avatarUrl } = req.body;

  if (typeof displayName === 'string') {
    req.user.displayName = displayName.trim();
  }
  if (typeof bio === 'string') {
    req.user.bio = bio.trim();
  }
  if (typeof avatarUrl === 'string') {
    req.user.avatarUrl = avatarUrl.trim();
  }

  await req.user.save();

  return res.json({
    user: {
      id: req.user._id,
      displayName: req.user.displayName,
      bio: req.user.bio,
      avatarUrl: req.user.avatarUrl,
      status: req.user.status,
    },
  });
}

export async function registerFcmToken(req, res) {
  const { token } = req.body;
  if (!token) {
    return res.status(400).json({ message: 'Token required' });
  }

  const exists = req.user.fcmTokens.includes(token);
  if (!exists) {
    req.user.fcmTokens.push(token);
    await req.user.save();
  }

  return res.status(204).send();
}
