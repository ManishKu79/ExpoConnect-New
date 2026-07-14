const express = require('express');
const router = express.Router();
const { auth, authorize } = require('../middleware/auth');
const analyticsController = require('../controllers/analyticsController');

// All routes require authentication
router.use(auth);

// Organizer analytics routes
router.get('/organizer/stats', authorize('organizer', 'admin'), analyticsController.getOrganizerStats);
router.get('/events/all', authorize('organizer', 'admin'), analyticsController.getAllEventsAnalytics);
router.get('/event/:eventId', authorize('organizer', 'admin'), analyticsController.getEventAnalytics);

module.exports = router;