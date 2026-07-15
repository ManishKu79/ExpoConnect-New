const mongoose = require('mongoose');

const StallSchema = new mongoose.Schema({
  event: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Event',
    required: true,
  },
  hall: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Hall',
    required: true,
  },
  number: {
    type: String,
    required: true,
  },
  company: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Company',
  },
  size: {
    type: String,
    enum: ['small', 'medium', 'large', 'premium'],
    default: 'medium',
  },
  price: {
    type: Number,
    required: true,
  },
  isBooked: {
    type: Boolean,
    default: false,
  },
  isAvailable: {
    type: Boolean,
    default: true,
  },
  features: [String],
  qrCode: {
    type: String,
  },
  description: {
    type: String,
    default: '',
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
}, {
  timestamps: true,
});

StallSchema.index({ event: 1, hall: 1, number: 1 }, { unique: true });
StallSchema.index({ company: 1 });

module.exports = mongoose.model('Stall', StallSchema);