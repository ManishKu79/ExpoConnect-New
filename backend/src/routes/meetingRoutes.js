const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const meetingController = require('../controllers/meetingController');

// All routes require authentication
router.use(auth);

// Meeting routes
router.post('/', meetingController.createMeeting);
router.get('/', meetingController.getMeetings);
router.get('/:id', meetingController.getMeetingById);
router.put('/:id/status', meetingController.updateMeetingStatus);
router.put('/:id/complete', meetingController.completeMeeting);
router.delete('/:id', meetingController.deleteMeeting);

module.exports = router;