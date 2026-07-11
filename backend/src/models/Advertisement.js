const mongoose = require('mongoose');

const AdvertisementSchema = new mongoose.Schema({
  sponsor: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Company',
    required: true,
  },
  event: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Event',
    required: true,
  },
  title: String,
  content: String,
  media: [String],
  placement: {
    type: String,
    enum: ['banner', 'sidebar', 'popup', 'video'],
  },
  startDate: Date,
  endDate: Date,
  impressions: {
    type: Number,
    default: 0,
  },
  clicks: {
    type: Number,
    default: 0,
  },
  isActive: {
    type: Boolean,
    default: true,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
}, {
  timestamps: true,
});

AdvertisementSchema.index({ event: 1, sponsor: 1 });
AdvertisementSchema.index({ startDate: 1, endDate: 1 });

module.exports = mongoose.model('Advertisement', AdvertisementSchema);