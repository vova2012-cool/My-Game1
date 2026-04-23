import { Router } from 'express';
import {
  createDirectChat,
  createGroupChat,
  getChatMessages,
  listChats,
  pinChat,
  unpinChat,
} from '../controllers/chatController.js';
import { authMiddleware } from '../middleware/auth.js';

const router = Router();

router.use(authMiddleware);
router.get('/', listChats);
router.post('/direct', createDirectChat);
router.post('/group', createGroupChat);
router.get('/:chatId/messages', getChatMessages);
router.post('/:chatId/pin', pinChat);
router.delete('/:chatId/pin', unpinChat);

export default router;
