const mongoose = require('mongoose');

const LeadSchema = new mongoose.Schema({
  exhibitor: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Company',
    required: true,
  },
  visitor: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  event: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Event',
    required: true,
  },
  interestLevel: {
    type: Number,
    min: 1,
    max: 10,
    default: 5,
  },
  score: {
    type: Number,
    min: 0,
    max: 100,
    default: 0,
  },
  status: {
    type: String,
    enum: ['new', 'contacted', 'qualified', 'lost', 'won'],
    default: 'new',
  },
  notes: {
    type: String,
    default: '',
  },
  followUpDate: {
    type: Date,
  },
  interactions: [{
    type: {
      type: String,
      enum: ['visit', 'message', 'meeting', 'call', 'email', 'qr_scan'],
    },
    description: String,
    date: {
      type: Date,
      default: Date.now,
    },
  }],
  source: {
    type: String,
    enum: ['qr_scan', 'visit', 'manual', 'recommendation'],
    default: 'manual',
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
}, {
  timestamps: true,
});

LeadSchema.index({ exhibitor: 1, visitor: 1 }, { unique: true });
LeadSchema.index({ event: 1 });
LeadSchema.index({ score: -1 });
LeadSchema.index({ status: 1 });

module.exports = mongoose.model('Lead', LeadSchema);