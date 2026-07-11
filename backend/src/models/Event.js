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
    venue: String,
    address: String,
    city: String,
    country: String,
    coordinates: {
      lat: Number,
      lng: Number,
    },
  },
  banner: {
    type: String,
  },
  categories: [String],
  status: {
    type: String,
    enum: ['draft', 'published', 'ongoing', 'completed', 'cancelled'],
    default: 'draft',
  },
  isPublic: {
    type: Boolean,
    default: true,
  },
  maxAttendees: {
    type: Number,
  },
  registrationDeadline: {
    type: Date,
  },
  ticketPrice: {
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

EventSchema.index({ startDate: 1, endDate: 1 });
EventSchema.index({ organizer: 1 });
EventSchema.index({ status: 1 });

module.exports = mongoose.model('Event', EventSchema);