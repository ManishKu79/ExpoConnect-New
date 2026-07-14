const express = require('express');
const router = express.Router();

// Import route modules
const authRoutes = require('./authRoutes');
const userRoutes = require('./userRoutes');
const companyRoutes = require('./companyRoutes');
const eventRoutes = require('./eventRoutes');
const stallRoutes = require('./stallRoutes');
const leadRoutes = require('./leadRoutes');
const meetingRoutes = require('./meetingRoutes');
const notificationRoutes = require('./notificationRoutes');
const analyticsRoutes = require('./analyticsRoutes');
const certificateRoutes = require('./certificateRoutes');
const voiceNoteRoutes = require('./voiceNoteRoutes');
const documentRoutes = require('./documentRoutes');
const marketplaceRoutes = require('./marketplaceRoutes');
const aiRoutes = require('./aiRoutes');
const uploadRoutes = require('./uploadRoutes');

// Health check
router.get('/health', (req, res) => {
  res.status(200).json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Mount routes
router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/companies', companyRoutes);
router.use('/events', eventRoutes);
router.use('/stalls', stallRoutes);
router.use('/leads', leadRoutes);
router.use('/meetings', meetingRoutes);
router.use('/notifications', notificationRoutes);
router.use('/analytics', analyticsRoutes);
router.use('/certificates', certificateRoutes);
router.use('/voice-notes', voiceNoteRoutes);
router.use('/documents', documentRoutes);
router.use('/marketplace', marketplaceRoutes);
router.use('/ai', aiRoutes);
router.use('/upload', uploadRoutes);

module.exports = router;