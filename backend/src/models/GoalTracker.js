const mongoose = require('mongoose');

const GoalTrackerSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  title: {
    type: String,
    required: true,
  },
  description: String,
  category: {
    type: String,
    enum: ['networking', 'business', 'learning', 'personal', 'other'],
    required: true,
  },
  targetDate: Date,
  priority: {
    type: String,
    enum: ['low', 'medium', 'high'],
    default: 'medium',
  },
  status: {
    type: String,
    enum: ['not_started', 'in_progress', 'completed', 'abandoned'],
    default: 'not_started',
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
    completed: Boolean,
    completedAt: Date,
  }],
  relatedGoals: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'GoalTracker',
  }],
  createdAt: {
    type: Date,
    default: Date.now,
  },
}, {
  timestamps: true,
});

GoalTrackerSchema.index({ user: 1, status: 1 });
GoalTrackerSchema.index({ category: 1 });

module.exports = mongoose.model('GoalTracker', GoalTrackerSchema);