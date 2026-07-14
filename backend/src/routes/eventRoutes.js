const express = require('express');
const router = express.Router();
const { auth, authorize } = require('../middleware/auth');
const eventController = require('../controllers/eventController');

// ============ PUBLIC ROUTES ============
router.get('/', eventController.getAllEvents);

// ============ PROTECTED ROUTES (Require Auth) ============
router.use(auth);

// ============ REGISTRATION ROUTES ============
router.get('/my-registered-events', eventController.getMyRegisteredEvents);
router.get('/my-events', authorize('organizer', 'admin'), eventController.getMyEvents);
router.get('/:id/registration-status', eventController.checkRegistrationStatus);
router.post('/:id/register', eventController.registerForEvent);
router.delete('/:id/register', eventController.unregisterFromEvent);

// ============ QR ROUTES ============
router.get('/:id/entry-qr', eventController.generateEntryQR);
router.post('/verify-qr', eventController.verifyEntryQR);

// ============ ORGANIZER ROUTES ============
router.post('/', authorize('organizer', 'admin'), eventController.createEvent);
router.put('/:id', authorize('organizer', 'admin'), eventController.updateEvent);
router.delete('/:id', authorize('organizer', 'admin'), eventController.deleteEvent);

// ============ GET EVENT BY ID (MUST BE LAST) ============
router.get('/:id', eventController.getEventById);

module.exports = router;