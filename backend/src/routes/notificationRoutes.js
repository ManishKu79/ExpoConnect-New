const express = require('express');
const router = express.Router();
const { auth, authorize } = require('../middleware/auth');
const notificationController = require('../controllers/notificationController');

// All routes require authentication
router.use(auth);

// Notification routes
router.get('/', notificationController.getNotifications);
router.put('/:id/read', notificationController.markAsRead);
router.put('/read-all', notificationController.markAllAsRead);
router.post('/send', authorize('admin'), notificationController.sendNotification);
router.delete('/:id', notificationController.deleteNotification);

module.exports = router;