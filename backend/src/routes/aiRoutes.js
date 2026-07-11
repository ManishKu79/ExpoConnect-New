const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const { uploadDocument, uploadProfile } = require('../middleware/upload');
const aiController = require('../controllers/aiController');

// All routes require authentication
router.use(auth);

// AI routes
router.post('/recommendations', aiController.getRecommendations);
router.post('/sentiment', aiController.analyzeSentiment);
router.post('/summarize', aiController.summarizeText);
router.post('/extract-business', aiController.extractBusinessInfo);
router.post('/match-opportunities', aiController.matchOpportunities);
router.post('/insights', aiController.generateInsights);
router.post('/business-card', uploadProfile, aiController.extractBusinessCard);
router.post('/transcribe', uploadDocument, aiController.transcribeAudio);

module.exports = router;