const mongoose = require('mongoose');

const CollaborationSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  description: String,
  companies: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Company',
  }],
  projectType: {
    type: String,
    enum: ['research', 'development', 'marketing', 'event', 'other'],
  },
  goals: [String],
  startDate: Date,
  expectedEndDate: Date,
  status: {
    type: String,
    enum: ['planning', 'active', 'paused', 'completed', 'cancelled'],
    default: 'planning',
  },
  leadCompany: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Company',
  },
  resources: {
    budget: Number,
    teamMembers: Number,
    otherResources: [String],
  },
  progress: {
    type: Number,
    min: 0,
    max: 100,
    default: 0,
  },
  milestones: [{
    title: String,
    description: String,
    dueDate: Date,
    completed: Boolean,
  }],
  communications: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
    },
    message: String,
    timestamp: {
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

CollaborationSchema.index({ companies: 1 });
CollaborationSchema.index({ status: 1 });

module.exports = mongoose.model('Collaboration', CollaborationSchema);