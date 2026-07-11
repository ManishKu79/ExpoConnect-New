const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const { uploadDocument } = require('../middleware/upload');
const voiceNoteController = require('../controllers/voiceNoteController');

// All routes require authentication
router.use(auth);

// Voice note routes
router.post('/', uploadDocument, voiceNoteController.createVoiceNote);
router.get('/', voiceNoteController.getVoiceNotes);
router.get('/:id', voiceNoteController.getVoiceNoteById);
router.get('/:id/transcript', voiceNoteController.getTranscript);
router.delete('/:id', voiceNoteController.deleteVoiceNote);

module.exports = router;