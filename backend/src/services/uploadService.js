const cloudinary = require('../config/cloudinary');
const logger = require('../utils/logger');
const path = require('path');

class UploadService {
  async uploadToCloudinary(fileBuffer, options = {}) {
    try {
      const result = await new Promise((resolve, reject) => {
        const uploadStream = cloudinary.uploader.upload_stream(
          {
            folder: options.folder || 'expoconnect',
            resource_type: options.resource_type || 'auto',
            transformation: options.transformation || [],
            ...options,
          },
          (error, result) => {
            if (error) reject(error);
            else resolve(result);
          }
        );
        uploadStream.end(fileBuffer);
      });

      return {
        url: result.secure_url,
        publicId: result.public_id,
        width: result.width,
        height: result.height,
        format: result.format,
      };
    } catch (error) {
      logger.error(`Cloudinary upload error: ${error.message}`);
      throw new Error('Failed to upload file');
    }
  }

  async deleteFromCloudinary(publicId) {
    try {
      const result = await cloudinary.uploader.destroy(publicId);
      logger.info(`Deleted from Cloudinary: ${publicId}`);
      return result;
    } catch (error) {
      logger.error(`Cloudinary delete error: ${error.message}`);
      throw new Error('Failed to delete file');
    }
  }

  validateFileType(file, allowedTypes) {
    const mimeType = file.mimetype;
    const ext = path.extname(file.originalname).toLowerCase();
    
    if (!allowedTypes.includes(mimeType) && !allowedTypes.includes(ext)) {
      throw new Error(`File type not allowed. Allowed: ${allowedTypes.join(', ')}`);
    }
    return true;
  }

  validateFileSize(file, maxSizeMB = 5) {
    const maxBytes = maxSizeMB * 1024 * 1024;
    if (file.size > maxBytes) {
      throw new Error(`File size exceeds ${maxSizeMB}MB limit`);
    }
    return true;
  }
}

module.exports = new UploadService();