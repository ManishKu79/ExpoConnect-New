const VoiceNote = require('../models/VoiceNote');
const logger = require('../utils/logger');
const aiService = require('../services/aiService');

exports.createVoiceNote = async (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Audio file is required',
      });
    }

    const { meetingId, eventId } = req.body;

    // Upload audio to Cloudinary
    const uploadService = require('../services/uploadService');
    const result = await uploadService.uploadToCloudinary(req.file.buffer, {
      folder: 'expoconnect/voice-notes',
      resource_type: 'video',
    });

    const voiceNote = await VoiceNote.create({
      user: req.user._id,
      meeting: meetingId,
      event: eventId,
      recordingUrl: result.url,
      duration: req.body.duration || 0,
    });

    // Transcribe audio
    const transcript = await aiService.transcribeAudio(result.url);
    voiceNote.transcript = transcript.transcript;
    await voiceNote.save();

    res.status(201).json({
      success: true,
      message: 'Voice note created successfully',
      data: voiceNote,
    });
  } catch (error) {
    logger.error(`Create voice note error: ${error.message}`);
    next(error);
  }
};

exports.getVoiceNotes = async (req, res, next) => {
  try {
    const query = { user: req.user._id };
    if (req.query.meetingId) query.meeting = req.query.meetingId;
    if (req.query.eventId) query.event = req.query.eventId;

    const voiceNotes = await VoiceNote.find(query)
      .populate('meeting', 'proposedTime status')
      .populate('event', 'title')
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      data: voiceNotes,
    });
  } catch (error) {
    logger.error(`Get voice notes error: ${error.message}`);
    next(error);
  }
};

exports.getVoiceNoteById = async (req, res, next) => {
  try {
    const voiceNote = await VoiceNote.findById(req.params.id)
      .populate('meeting', 'proposedTime status')
      .populate('event', 'title');

    if (!voiceNote) {
      return res.status(404).json({
        success: false,
        message: 'Voice note not found',
      });
    }

    res.status(200).json({
      success: true,
      data: voiceNote,
    });
  } catch (error) {
    logger.error(`Get voice note by id error: ${error.message}`);
    next(error);
  }
};

exports.getTranscript = async (req, res, next) => {
  try {
    const voiceNote = await VoiceNote.findById(req.params.id);
    if (!voiceNote) {
      return res.status(404).json({
        success: false,
        message: 'Voice note not found',
      });
    }

    res.status(200).json({
      success: true,
      data: {
        transcript: voiceNote.transcript,
        summary: voiceNote.summary,
      },
    });
  } catch (error) {
    logger.error(`Get transcript error: ${error.message}`);
    next(error);
  }
};

exports.deleteVoiceNote = async (req, res, next) => {
  try {
    const voiceNote = await VoiceNote.findById(req.params.id);
    if (!voiceNote) {
      return res.status(404).json({
        success: false,
        message: 'Voice note not found',
      });
    }

    await voiceNote.remove();

    res.status(200).json({
      success: true,
      message: 'Voice note deleted successfully',
    });
  } catch (error) {
    logger.error(`Delete voice note error: ${error.message}`);
    next(error);
  }
};