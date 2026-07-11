const mongoose = require('mongoose');

const OpportunitySchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    trim: true,
  },
  description: {
    type: String,
    required: true,
  },
  type: {
    type: String,
    enum: ['collaboration', 'investment', 'partnership', 'supply', 'purchase', 'other'],
    required: true,
  },
  company: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Company',
    required: true,
  },
  event: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Event',
  },
  budget: {
    min: Number,
    max: Number,
    currency: {
      type: String,
      default: 'USD',
    },
  },
  requirements: [String],
  status: {
    type: String,
    enum: ['open', 'in_progress', 'closed', 'expired'],
    default: 'open',
  },
  interestedCompanies: [{
    company: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Company',
    },
    status: {
      type: String,
      enum: ['interested', 'applied', 'shortlisted', 'accepted', 'rejected'],
      default: 'interested',
    },
    appliedAt: {
      type: Date,
      default: Date.now,
    },
  }],
  views: {
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

OpportunitySchema.index({ company: 1, status: 1 });
OpportunitySchema.index({ type: 1 });
OpportunitySchema.index({ createdAt: -1 });

module.exports = mongoose.model('Opportunity', OpportunitySchema);