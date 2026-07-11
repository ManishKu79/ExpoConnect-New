const express = require('express');
const router = express.Router();
const { auth, authorize } = require('../middleware/auth');
const analyticsController = require('../controllers/analyticsController');

// Public analytics routes (some are public, some require auth)
router.get('/event/:eventId/metrics', auth, analyticsController.getEventMetrics);
router.get('/event/:eventId/engagement', auth, analyticsController.getEngagementScore);
router.get('/event/:eventId/report', auth, analyticsController.generateReport);
router.get('/event/:eventId/download', auth, analyticsController.downloadReport);
router.get('/event/:eventId/top-companies', auth, analyticsController.getTopPerformingCompanies);

// Admin only
router.post('/event/:eventId/track', auth, authorize('admin'), analyticsController.trackMetric);

module.exports = router;