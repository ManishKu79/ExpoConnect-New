const mongoose = require('mongoose');

const VoiceNoteSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  meeting: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Meeting',
  },
  event: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Event',
  },
  recordingUrl: {
    type: String,
    required: true,
  },
  transcript: String,
  summary: String,
  duration: Number, // seconds
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

VoiceNoteSchema.index({ user: 1 });
VoiceNoteSchema.index({ meeting: 1 });

module.exports = mongoose.model('VoiceNote', VoiceNoteSchema);