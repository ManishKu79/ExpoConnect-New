const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { auth } = require('../middleware/auth');
const logger = require('../utils/logger');

// Configure multer for disk storage (local fallback)
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDir = path.join(__dirname, '../../uploads/banners');
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + '-' + file.originalname);
  }
});

const fileFilter = (req, file, cb) => {
  const allowedTypes = ['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'image/jpg'];
  if (allowedTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('Only JPEG, PNG, WEBP and GIF images are allowed'), false);
  }
};

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 10 * 1024 * 1024,
  },
  fileFilter: fileFilter,
});

// Upload banner image - Local storage version
router.post('/banner', auth, upload.single('banner'), async (req, res, next) => {
  try {
    logger.info(`📤 Uploading banner for user: ${req.user._id}`);

    if (!req.file) {
      logger.error('❌ No file uploaded');
      return res.status(400).json({
        success: false,
        message: 'No file uploaded',
      });
    }

    logger.info(`📄 File saved: ${req.file.path}`);

    // Generate URL for the uploaded file
    const baseUrl = process.env.BACKEND_URL || 'http://localhost:5000';
    const fileUrl = `${baseUrl}/uploads/banners/${req.file.filename}`;

    res.status(201).json({
      success: true,
      message: 'Banner uploaded successfully',
      data: {
        url: fileUrl,
        publicId: req.file.filename,
      },
    });
  } catch (error) {
    logger.error(`❌ Banner upload error: ${error.message}`);
    next(error);
  }
});

module.exports = router;