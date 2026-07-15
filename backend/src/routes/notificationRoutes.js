const express = require('express');
const router = express.Router();
const { auth, authorize } = require('../middleware/auth');
const notificationController = require('../controllers/notificationController');

// All routes require authentication
router.use(auth);

// Get notifications
router.get('/', notificationController.getNotifications);
router.get('/unread-count', notificationController.getUnreadCount);

// Mark as read
router.put('/:id/read', notificationController.markAsRead);
router.put('/read-all', notificationController.markAllAsRead);

// Delete
router.delete('/:id', notificationController.deleteNotification);

// Send notification (organizer only)
router.post('/send-event', authorize('organizer', 'admin'), notificationController.sendEventNotification);

module.exports = router;