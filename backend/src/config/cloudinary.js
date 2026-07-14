const cloudinary = require('cloudinary').v2;

// Check if Cloudinary credentials are available
const cloudName = process.env.CLOUDINARY_CLOUD_NAME;
const apiKey = process.env.CLOUDINARY_API_KEY;
const apiSecret = process.env.CLOUDINARY_API_SECRET;

if (!cloudName || !apiKey || !apiSecret) {
  console.warn('⚠️ Cloudinary credentials not found. Image upload will not work.');
  console.warn('   Please set CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET in .env');
}

cloudinary.config({
  cloud_name: cloudName || 'demo',
  api_key: apiKey || 'dummy',
  api_secret: apiSecret || 'dummy',
});

module.exports = cloudinary;