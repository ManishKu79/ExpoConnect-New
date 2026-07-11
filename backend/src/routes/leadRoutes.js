const express = require('express');
const router = express.Router();
const { auth, authorize } = require('../middleware/auth');
const leadController = require('../controllers/leadController');

// All routes require authentication
router.use(auth);

// Lead routes
router.post('/', leadController.createLead);
router.get('/', leadController.getLeads);
router.get('/recommendations', leadController.getLeadRecommendations);
router.get('/:id', leadController.getLeadById);
router.put('/:id', leadController.updateLead);
router.get('/:id/score', leadController.scoreLead);
router.delete('/:id', leadController.deleteLead);

module.exports = router;