const express = require('express');
const router = express.Router();
const { auth, authorize } = require('../middleware/auth');
const { uploadCompanyLogo } = require('../middleware/upload');
const companyController = require('../controllers/companyController');

// Public routes
router.get('/', companyController.getAllCompanies);
router.get('/:id', companyController.getCompanyById);

// Protected routes
router.use(auth);
router.post('/', companyController.createCompany);
router.put('/:id', companyController.updateCompany);
router.put('/:id/logo', uploadCompanyLogo, companyController.uploadLogo);
router.delete('/:id', authorize('admin'), companyController.deleteCompany);

module.exports = router;