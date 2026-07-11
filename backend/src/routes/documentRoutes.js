const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const { uploadMultiple } = require('../middleware/upload');
const documentController = require('../controllers/documentController');

// All routes require authentication
router.use(auth);

// Document routes
router.post('/upload', uploadMultiple, documentController.uploadDocuments);
router.get('/', documentController.getDocuments);
router.get('/:id', documentController.getDocumentById);
router.get('/:id/download', documentController.downloadDocument);
router.delete('/:id', documentController.deleteDocument);

module.exports = router;