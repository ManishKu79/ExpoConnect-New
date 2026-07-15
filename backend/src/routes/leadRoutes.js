const express = require('express');
const router = express.Router();
const { auth, authorize } = require('../middleware/auth');
const leadController = require('../controllers/leadController');

// All routes require authentication
router.use(auth);

// Lead routes (exhibitor only)
router.post('/', authorize('exhibitor', 'admin'), leadController.createLead);
router.get('/', authorize('exhibitor', 'admin'), leadController.getLeads);
router.get('/stats/:eventId', authorize('exhibitor', 'admin'), leadController.getLeadStats);
router.get('/:id', authorize('exhibitor', 'admin'), leadController.getLeadById);
router.put('/:id', authorize('exhibitor', 'admin'), leadController.updateLead);
router.post('/:id/interaction', authorize('exhibitor', 'admin'), leadController.addInteraction);
router.delete('/:id', authorize('exhibitor', 'admin'), leadController.deleteLead);

module.exports = router;