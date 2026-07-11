const mongoose = require('mongoose');

const CompanySchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Company name is required'],
    trim: true,
    unique: true,
  },
  description: {
    type: String,
    required: true,
  },
  logo: {
    type: String,
    default: '',
  },
  coverImage: {
    type: String,
    default: '',
  },
  website: {
    type: String,
    match: [/^(https?:\/\/)?([\da-z.-]+)\.([a-z.]{2,6})([/\w .-]*)*\/?$/, 'Please provide a valid URL'],
  },
  industry: {
    type: String,
    required: true,
    enum: ['technology', 'finance', 'healthcare', 'education', 'manufacturing', 'retail', 'other'],
  },
  size: {
    type: String,
    enum: ['1-10', '11-50', '51-200', '201-500', '501-1000', '1000+'],
  },
  foundedYear: {
    type: Number,
    min: 1900,
    max: new Date().getFullYear(),
  },
  headquarters: {
    city: String,
    country: String,
  },
  socialLinks: {
    linkedin: String,
    twitter: String,
    facebook: String,
  },
  isVerified: {
    type: Boolean,
    default: false,
  },
  reputationScore: {
    type: Number,
    default: 0,
    min: 0,
    max: 100,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  updatedAt: {
    type: Date,
    default: Date.now,
  },
}, {
  timestamps: true,
});

CompanySchema.index({ name: 1 });
CompanySchema.index({ industry: 1 });
CompanySchema.index({ reputationScore: -1 });

module.exports = mongoose.model('Company', CompanySchema);