const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const marketplaceController = require('../controllers/marketplaceController');

// Some routes are public
router.get('/opportunities', marketplaceController.getOpportunities);
router.get('/opportunities/:id', marketplaceController.getOpportunityById);

// Protected routes
router.use(auth);

// Opportunity routes
router.post('/opportunities', marketplaceController.createOpportunity);
router.put('/opportunities/:id', marketplaceController.updateOpportunity);
router.post('/opportunities/:id/interest', marketplaceController.expressInterest);
router.delete('/opportunities/:id', marketplaceController.deleteOpportunity);

// Partnership routes
router.post('/partnerships', marketplaceController.createPartnership);
router.get('/partnerships', marketplaceController.getPartnerships);
router.get('/partnerships/:id', marketplaceController.getPartnershipById);
router.put('/partnerships/:id', marketplaceController.updatePartnership);
router.post('/partnerships/:id/milestone', marketplaceController.addMilestone);
router.delete('/partnerships/:id', marketplaceController.deletePartnership);

// Collaboration routes
router.post('/collaborations', marketplaceController.createCollaboration);
router.get('/collaborations', marketplaceController.getCollaborations);
router.get('/collaborations/:id', marketplaceController.getCollaborationById);
router.put('/collaborations/:id', marketplaceController.updateCollaboration);
router.post('/collaborations/:id/communication', marketplaceController.addCommunication);
router.delete('/collaborations/:id', marketplaceController.deleteCollaboration);

// Knowledge sharing
router.post('/knowledge', marketplaceController.createKnowledgeShare);
router.get('/knowledge', marketplaceController.getKnowledgeShares);
router.get('/knowledge/:id', marketplaceController.getKnowledgeShareById);
router.post('/knowledge/:id/like', marketplaceController.likeKnowledgeShare);
router.post('/knowledge/:id/comment', marketplaceController.addComment);
router.put('/knowledge/:id', marketplaceController.updateKnowledgeShare);
router.delete('/knowledge/:id', marketplaceController.deleteKnowledgeShare);

// Goal tracker
router.post('/goals', marketplaceController.createGoal);
router.get('/goals', marketplaceController.getGoals);
router.get('/goals/:id', marketplaceController.getGoalById);
router.put('/goals/:id', marketplaceController.updateGoal);
router.post('/goals/:id/milestone', marketplaceController.addGoalMilestone);
router.delete('/goals/:id', marketplaceController.deleteGoal);

module.exports = router;