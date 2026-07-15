const express = require('express');
const router = express.Router();
const { auth, authorize } = require('../middleware/auth');
const adminController = require('../controllers/adminController');

// All routes require admin authentication
router.use(auth);
router.use(authorize('admin'));

// System stats
router.get('/stats', adminController.getSystemStats);
router.get('/activity', adminController.getRecentActivity);

// User management
router.get('/users', adminController.getAllUsers);
router.put('/users/:id', adminController.updateUser);
router.delete('/users/:id', adminController.deleteUser);

// Event management
router.get('/events', adminController.getAllEvents);
router.put('/events/:id', adminController.updateEvent);
router.delete('/events/:id', adminController.deleteEvent);

// Lead management
router.get('/leads', adminController.getAllLeads);

module.exports = router;