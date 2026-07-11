const mongoose = require('mongoose');

const ServiceSchema = new mongoose.Schema({
  company: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Company',
    required: true,
  },
  name: {
    type: String,
    required: true,
    trim: true,
  },
  description: {
    type: String,
    required: true,
  },
  category: {
    type: String,
    required: true,
  },
  priceRange: {
    min: Number,
    max: Number,
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

ServiceSchema.index({ company: 1 });
ServiceSchema.index({ category: 1 });

module.exports = mongoose.model('Service', ServiceSchema);