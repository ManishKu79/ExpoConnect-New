const mongoose = require('mongoose');

const SessionSchema = new mongoose.Schema({
  event: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Event',
    required: true,
  },
  title: {
    type: String,
    required: true,
  },
  description: String,
  speaker: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  startTime: {
    type: Date,
    required: true,
  },
  endTime: {
    type: Date,
    required: true,
  },
  hall: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Hall',
  },
  capacity: Number,
  presentationUrl: String,
  materials: [String],
  isActive: {
    type: Boolean,
    default: true,
  },
  attendees: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  }],
  feedback: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
    },
    rating: {
      type: Number,
      min: 1,
      max: 5,
    },
    comment: String,
    createdAt: {
      type: Date,
      default: Date.now,
    },
  }],
  createdAt: {
    type: Date,
    default: Date.now,
  },
}, {
  timestamps: true,
});

SessionSchema.index({ event: 1 });
SessionSchema.index({ speaker: 1 });
SessionSchema.index({ startTime: 1, endTime: 1 });

module.exports = mongoose.model('Session', SessionSchema);