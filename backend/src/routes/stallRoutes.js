const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const stallController = require('../controllers/stallController');

// Public routes
router.get('/event/:eventId', stallController.getStallsByEvent);
router.get('/:id', stallController.getStallById);

// Protected routes
router.use(auth);
router.post('/', stallController.createStall);
router.put('/:id', stallController.updateStall);
router.put('/:id/assign', stallController.assignStall);
router.delete('/:id', stallController.deleteStall);

module.exports = router;