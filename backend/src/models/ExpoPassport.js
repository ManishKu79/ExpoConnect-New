const mongoose = require('mongoose');

const ExpoPassportSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  event: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Event',
    required: true,
  },
  checkIns: [{
    stall: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Stall',
    },
    timestamp: {
      type: Date,
      default: Date.now,
    },
  }],
  sessionsAttended: [{
    session: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Session',
    },
    timestamp: Date,
  }],
  meetingsAttended: [{
    meeting: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Meeting',
    },
    timestamp: Date,
  }],
  badgesEarned: [String],
  totalPoints: {
    type: Number,
    default: 0,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
}, {
  timestamps: true,
});

ExpoPassportSchema.index({ user: 1, event: 1 }, { unique: true });

module.exports = mongoose.model('ExpoPassport', ExpoPassportSchema);