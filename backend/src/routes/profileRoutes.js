import { Router } from 'express';
import { authMiddleware } from '../middleware/auth.js';
import { registerFcmToken, updateProfile } from '../controllers/profileController.js';

const router = Router();

router.use(authMiddleware);
router.patch('/', updateProfile);
router.post('/fcm-token', registerFcmToken);

export default router;
