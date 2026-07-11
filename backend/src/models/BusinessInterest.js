const mongoose = require('mongoose');

const BusinessInterestSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  company: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Company',
    required: true,
  },
  interestType: {
    type: String,
    enum: ['collaboration', 'investment', 'partnership', 'supply', 'purchase', 'other'],
    required: true,
  },
  description: String,
  status: {
    type: String,
    enum: ['active', 'archived'],
    default: 'active',
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

BusinessInterestSchema.index({ user: 1, company: 1 }, { unique: true });

module.exports = mongoose.model('BusinessInterest', BusinessInterestSchema);