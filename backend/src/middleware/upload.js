const multer = require('multer');
const path = require('path');

const storage = multer.memoryStorage();

const fileFilter = (req, file, cb) => {
  const allowedTypes = [
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp',
    'application/pdf',
    'audio/mpeg',
    'audio/wav',
  ];

  if (allowedTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error(`File type ${file.mimetype} not allowed`), false);
  }
};

const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB
  },
});

// Specific upload configurations
const uploadProfile = upload.single('profilePicture');
const uploadCompanyLogo = upload.single('logo');
const uploadEventBanner = upload.single('banner');
const uploadMultiple = upload.array('files', 5);
const uploadDocument = upload.single('document');

module.exports = {
  upload,
  uploadProfile,
  uploadCompanyLogo,
  uploadEventBanner,
  uploadMultiple,
  uploadDocument,
};