const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const UserSchema = new mongoose.Schema({
  firstName: {
    type: String,
    default: 'User',
    trim: true,
  },
  lastName: {
    type: String,
    default: 'Name',
    trim: true,
  },
  email: {
    type: String,
    required: [true, 'Email is required'],
    unique: true,
    lowercase: true,
    trim: true,
    match: [/^\S+@\S+\.\S+$/, 'Please provide a valid email'],
  },
  password: {
    type: String,
    required: [true, 'Password is required'],
    minlength: 6,
    select: false,
  },
  role: {
    type: String,
    enum: ['visitor', 'exhibitor', 'organizer', 'admin', 'sponsor', 'speaker', 'investor'],
    default: 'visitor',
  },
  phone: {
    type: String,
    default: '',
  },
  profilePicture: {
    type: String,
    default: '',
  },
  bio: {
    type: String,
    maxlength: 500,
    default: '',
  },
  company: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Company',
  },
  interests: [{
    type: String,
    enum: ['technology', 'finance', 'healthcare', 'education', 'manufacturing', 'retail', 'other'],
  }],
  isEmailVerified: {
    type: Boolean,
    default: false,
  },
  isActive: {
    type: Boolean,
    default: true,
  },
  lastLogin: {
    type: Date,
  },
  resetPasswordToken: String,
  resetPasswordExpire: Date,
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

// Pre-save middleware: hash password
UserSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});

// Compare password method
UserSchema.methods.matchPassword = async function(enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

// Indexes
UserSchema.index({ email: 1 });
UserSchema.index({ role: 1 });
UserSchema.index({ company: 1 });

module.exports = mongoose.model('User', UserSchema);