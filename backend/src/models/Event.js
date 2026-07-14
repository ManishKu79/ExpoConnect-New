const mongoose = require('mongoose');

const EventSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    trim: true,
  },
  description: {
    type: String,
    required: true,
  },
  organizer: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  startDate: {
    type: Date,
    required: true,
  },
  endDate: {
    type: Date,
    required: true,
  },
  location: {
    venue: { type: String, default: '' },
    address: { type: String, default: '' },
    city: { type: String, default: '' },
    country: { type: String, default: '' },
    coordinates: {
      lat: { type: Number, default: 0 },
      lng: { type: Number, default: 0 },
    },
  },
  banner: {
    type: String,
    default: '',
  },
  categories: [{
    type: String,
  }],
  status: {
    type: String,
    enum: ['draft', 'published', 'ongoing', 'completed', 'cancelled'],
    default: 'published',
  },
  isPublic: {
    type: Boolean,
    default: true,
  },
  maxAttendees: {
    type: Number,
    default: 0,
  },
  registrationDeadline: {
    type: Date,
  },
  ticketPrice: {
    type: Number,
    default: 0,
  },
  registeredCount: {
    type: Number,
    default: 0,
  },
  registeredUsers: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  }],
  createdAt: {
    type: Date,
    default: Date.now,
  },
}, {
  timestamps: true,
});

EventSchema.index({ startDate: 1, endDate: 1 });
EventSchema.index({ organizer: 1 });
EventSchema.index({ status: 1 });
EventSchema.index({ registeredUsers: 1 });

module.exports = mongoose.model('Event', EventSchema);