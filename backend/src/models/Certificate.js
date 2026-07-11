const mongoose = require('mongoose');

const CertificateSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  event: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Event',
  },
  type: {
    type: String,
    enum: ['attendance', 'speaker', 'sponsor', 'participation'],
    required: true,
  },
  title: String,
  description: String,
  issueDate: {
    type: Date,
    default: Date.now,
  },
  expiryDate: Date,
  certificateUrl: {
    type: String, // URL to generated PDF
  },
  verificationCode: {
    type: String,
    unique: true,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
}, {
  timestamps: true,
});

CertificateSchema.index({ user: 1 });
CertificateSchema.index({ verificationCode: 1 }, { unique: true });

module.exports = mongoose.model('Certificate', CertificateSchema);