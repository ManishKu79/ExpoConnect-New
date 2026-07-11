const mongoose = require('mongoose');

const ReportSchema = new mongoose.Schema({
  event: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Event',
  },
  company: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Company',
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  },
  type: {
    type: String,
    enum: ['lead', 'attendance', 'sales', 'engagement', 'sponsor', 'custom'],
    required: true,
  },
  data: {
    type: Map,
    of: mongoose.Schema.Types.Mixed,
  },
  generatedAt: {
    type: Date,
    default: Date.now,
  },
});

ReportSchema.index({ event: 1, type: 1 });
ReportSchema.index({ company: 1 });

module.exports = mongoose.model('Report', ReportSchema);