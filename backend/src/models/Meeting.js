const mongoose = require('mongoose');

const MeetingSchema = new mongoose.Schema({
  event: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Event',
    required: true,
  },
  requester: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  recipient: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  proposedTime: {
    type: Date,
    required: true,
  },
  duration: {
    type: Number, // minutes
    default: 30,
  },
  status: {
    type: String,
    enum: ['pending', 'accepted', 'declined', 'rescheduled', 'cancelled', 'completed'],
    default: 'pending',
  },
  agenda: String,
  notes: String,
  location: String,
  meetingLink: String,
  feedback: {
    rating: {
      type: Number,
      min: 1,
      max: 5,
    },
    comment: String,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
}, {
  timestamps: true,
});

MeetingSchema.index({ event: 1, requester: 1, recipient: 1 });
MeetingSchema.index({ status: 1 });

module.exports = mongoose.model('Meeting', MeetingSchema);