const express = require('express');
const router = express.Router();
const { auth, authorize } = require('../middleware/auth');
const eventController = require('../controllers/eventController');

// Public routes
router.get('/', eventController.getAllEvents);
router.get('/:id', eventController.getEventById);

// Protected routes
router.use(auth);

// Organizer routes
router.post('/', authorize('organizer', 'admin'), eventController.createEvent);
router.put('/:id', authorize('organizer', 'admin'), eventController.updateEvent);
router.delete('/:id', authorize('organizer', 'admin'), eventController.deleteEvent);
router.get('/my-events', authorize('organizer', 'admin'), eventController.getMyEvents);

// Registration routes
router.post('/:id/register', eventController.registerForEvent);
router.delete('/:id/register', eventController.unregisterFromEvent);

module.exports = router;