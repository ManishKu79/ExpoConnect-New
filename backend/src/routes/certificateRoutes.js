const express = require('express');
const router = express.Router();
const { auth, authorize } = require('../middleware/auth');
const certificateController = require('../controllers/certificateController');

// All routes require authentication
router.use(auth);

// Certificate routes
router.post('/', certificateController.generateCertificate);
router.get('/', certificateController.getCertificates);
router.get('/:id', certificateController.getCertificateById);
router.get('/:id/download', certificateController.downloadCertificate);
router.post('/verify', certificateController.verifyCertificate);
router.delete('/:id', authorize('admin'), certificateController.deleteCertificate);

module.exports = router;