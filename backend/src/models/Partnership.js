const mongoose = require('mongoose');

const PartnershipSchema = new mongoose.Schema({
  company1: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Company',
    required: true,
  },
  company2: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Company',
    required: true,
  },
  type: {
    type: String,
    enum: ['strategic', 'financial', 'operational', 'joint_venture', 'other'],
    required: true,
  },
  description: String,
  terms: String,
  startDate: {
    type: Date,
    required: true,
  },
  endDate: Date,
  status: {
    type: String,
    enum: ['proposed', 'negotiation', 'signed', 'active', 'terminated', 'expired'],
    default: 'proposed',
  },
  milestones: [{
    title: String,
    description: String,
    dueDate: Date,
    completed: {
      type: Boolean,
      default: false,
    },
    completedAt: Date,
  }],
  documents: [String],
  rating: {
    type: Number,
    min: 1,
    max: 5,
  },
  collaborationHistory: [{
    type: {
      type: String,
      enum: ['meeting', 'milestone', 'document', 'communication'],
    },
    description: String,
    date: {
      type: Date,
      default: Date.now,
    },
  }],
  createdAt: {
    type: Date,
    default: Date.now,
  },
}, {
  timestamps: true,
});

PartnershipSchema.index({ company1: 1, company2: 1 });
PartnershipSchema.index({ status: 1 });

module.exports = mongoose.model('Partnership', PartnershipSchema);