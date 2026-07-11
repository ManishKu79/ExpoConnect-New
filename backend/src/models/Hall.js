const mongoose = require('mongoose');

const HallSchema = new mongoose.Schema({
  event: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Event',
    required: true,
  },
  name: {
    type: String,
    required: true,
  },
  capacity: {
    type: Number,
    required: true,
  },
  description: String,
  floorPlan: {
    type: String, // URL to image
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
}, {
  timestamps: true,
});

HallSchema.index({ event: 1 });

module.exports = mongoose.model('Hall', HallSchema);