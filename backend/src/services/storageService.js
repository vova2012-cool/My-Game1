import { v4 as uuidv4 } from 'uuid';

export class StorageService {
  async upload(file) {
    const id = uuidv4();
    return {
      fileName: file.originalname,
      url: `https://storage.mock/${id}-${file.originalname}`,
      mimeType: file.mimetype,
      size: file.size,
    };
  }
}

export const storageService = new StorageService();
