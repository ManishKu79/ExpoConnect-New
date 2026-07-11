const express = require('express');
const router = express.Router();
const { auth, authorize } = require('../middleware/auth');
const { uploadEventBanner } = require('../middleware/upload');
const eventController = require('../controllers/eventController');

// Public routes
router.get('/', eventController.getAllEvents);
router.get('/:id', eventController.getEventById);

// Protected routes
router.use(auth);
router.post('/', eventController.createEvent);
router.put('/:id', eventController.updateEvent);
router.put('/:id/banner', uploadEventBanner, eventController.uploadBanner);
router.delete('/:id', eventController.deleteEvent);

module.exports = router;