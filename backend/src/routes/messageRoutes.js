import { Router } from 'express';
import multer from 'multer';
import { authMiddleware } from '../middleware/auth.js';

const upload = multer({ storage: multer.memoryStorage() });

export function createMessageRoutes(messageController) {
  const router = Router();
  router.use(authMiddleware);

  router.post('/', messageController.sendMessage);
  router.post('/image', upload.single('file'), messageController.uploadImage);
  router.patch('/:messageId', messageController.editMessage);
  router.delete('/:messageId', messageController.deleteMessage);
  router.post('/:messageId/read', messageController.markRead);

  return router;
}
