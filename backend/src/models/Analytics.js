const mongoose = require('mongoose');

const AnalyticsSchema = new mongoose.Schema({
  event: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Event',
    required: true,
  },
  metric: {
    type: String,
    enum: [
      'visitor_count',
      'exhibitor_count',
      'session_attendance',
      'lead_generated',
      'meetings_scheduled',
      'engagement_score',
      'revenue',
      'sponsor_roi',
    ],
    required: true,
  },
  value: {
    type: Number,
    required: true,
  },
  timestamp: {
    type: Date,
    default: Date.now,
  },
});

AnalyticsSchema.index({ event: 1, metric: 1 });
AnalyticsSchema.index({ timestamp: -1 });

module.exports = mongoose.model('Analytics', AnalyticsSchema);