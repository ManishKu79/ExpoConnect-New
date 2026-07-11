const mongoose = require('mongoose');

const MeetingHistorySchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  meeting: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Meeting',
    required: true,
  },
  action: {
    type: String,
    enum: ['created', 'accepted', 'declined', 'rescheduled', 'cancelled', 'completed'],
  },
  timestamp: {
    type: Date,
    default: Date.now,
  },
});

MeetingHistorySchema.index({ user: 1, meeting: 1 });

module.exports = mongoose.model('MeetingHistory', MeetingHistorySchema);