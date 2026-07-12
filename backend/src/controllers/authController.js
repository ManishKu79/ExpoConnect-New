const User = require('../models/User');
const tokenService = require('../services/tokenService');
const emailService = require('../services/emailService');
const logger = require('../utils/logger');

// ============ REGISTER ============
exports.register = async (req, res, next) => {
  try {
    const { firstName, lastName, email, password, role, phone } = req.body;

    // Log the incoming request
    console.log('📝 Registration Request:');
    console.log('   firstName:', firstName);
    console.log('   lastName:', lastName);
    console.log('   email:', email);
    console.log('   role:', role);
    console.log('   phone:', phone);
    console.log('   password length:', password?.length);

    // Basic validation
    if (!email) {
      return res.status(400).json({
        success: false,
        message: 'Email is required',
      });
    }

    if (!password) {
      return res.status(400).json({
        success: false,
        message: 'Password is required',
      });
    }

    if (password.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'Password must be at least 6 characters',
      });
    }

    // Check if user already exists
    const existingUser = await User.findOne({ email: email.toLowerCase() });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'User with this email already exists',
      });
    }

    // Create user with defaults
    const userData = {
      firstName: firstName || 'User',
      lastName: lastName || 'Name',
      email: email.toLowerCase(),
      password: password,
      role: role || 'visitor',
      phone: phone || '',
      isEmailVerified: true, // Auto-verify for development
    };

    console.log('📝 Creating user with data:', userData);

    const user = await User.create(userData);
    console.log('✅ User created successfully:', user._id);

    // Generate JWT token
    const jwtToken = tokenService.generateToken(user._id);
    const refreshToken = tokenService.generateRefreshToken(user._id);

    // Try to send verification email (don't fail if it doesn't work)
    try {
      const verificationToken = tokenService.generateVerificationToken();
      user.resetPasswordToken = verificationToken;
      user.resetPasswordExpire = Date.now() + 24 * 60 * 60 * 1000;
      await user.save();
      
      await emailService.sendVerificationEmail(email, verificationToken, user.firstName);
      console.log('📧 Verification email sent to:', email);
    } catch (emailError) {
      console.warn('⚠️ Email sending failed but user was created:', emailError.message);
      // Continue anyway - user is already verified for development
    }

    // Return success response
    res.status(201).json({
      success: true,
      message: 'Registration successful',
      data: {
        user: {
          id: user._id,
          firstName: user.firstName,
          lastName: user.lastName,
          email: user.email,
          role: user.role,
          isEmailVerified: user.isEmailVerified,
          profilePicture: user.profilePicture,
          phone: user.phone,
        },
        token: jwtToken,
        refreshToken,
      },
    });
  } catch (error) {
    console.error('❌ Registration error:', error);
    console.error('❌ Error stack:', error.stack);
    
    // Handle MongoDB validation errors
    if (error.name === 'ValidationError') {
      const errors = Object.values(error.errors).map(err => ({
        field: err.path,
        message: err.message
      }));
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors,
      });
    }

    // Handle duplicate key error
    if (error.code === 11000) {
      return res.status(400).json({
        success: false,
        message: 'User with this email already exists',
      });
    }

    next(error);
  }
};

// ============ LOGIN ============
exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    console.log('🔐 Login attempt:', email);

    // Find user with password
    const user = await User.findOne({ email: email.toLowerCase() }).select('+password');
    if (!user) {
      console.log('❌ User not found:', email);
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials',
      });
    }

    // Check password
    const isMatch = await user.matchPassword(password);
    if (!isMatch) {
      console.log('❌ Invalid password for:', email);
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials',
      });
    }

    // Update last login
    user.lastLogin = new Date();
    await user.save();

    console.log('✅ Login successful:', email);

    // Generate tokens
    const token = tokenService.generateToken(user._id);
    const refreshToken = tokenService.generateRefreshToken(user._id);

    res.status(200).json({
      success: true,
      message: 'Login successful',
      data: {
        user: {
          id: user._id,
          firstName: user.firstName,
          lastName: user.lastName,
          email: user.email,
          role: user.role,
          isEmailVerified: user.isEmailVerified,
          profilePicture: user.profilePicture,
          phone: user.phone,
          company: user.company,
          bio: user.bio,
        },
        token,
        refreshToken,
      },
    });
  } catch (error) {
    console.error('❌ Login error:', error);
    next(error);
  }
};

// ============ VERIFY EMAIL ============
exports.verifyEmail = async (req, res, next) => {
  try {
    const { token } = req.body;

    console.log('📧 Verifying email with token:', token.substring(0, 10) + '...');

    const user = await User.findOne({
      resetPasswordToken: token,
      resetPasswordExpire: { $gt: Date.now() },
    });

    if (!user) {
      return res.status(400).json({
        success: false,
        message: 'Invalid or expired verification token',
      });
    }

    user.isEmailVerified = true;
    user.resetPasswordToken = undefined;
    user.resetPasswordExpire = undefined;
    await user.save();

    console.log('✅ Email verified for:', user.email);

    res.status(200).json({
      success: true,
      message: 'Email verified successfully',
    });
  } catch (error) {
    console.error('❌ Email verification error:', error);
    next(error);
  }
};

// ============ FORGOT PASSWORD ============
exports.forgotPassword = async (req, res, next) => {
  try {
    const { email } = req.body;

    console.log('🔑 Password reset requested for:', email);

    const user = await User.findOne({ email: email.toLowerCase() });
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User with this email does not exist',
      });
    }

    // Generate reset token
    const resetToken = tokenService.generateResetToken();
    user.resetPasswordToken = resetToken;
    user.resetPasswordExpire = Date.now() + 24 * 60 * 60 * 1000; // 24 hours
    await user.save();

    // Send reset email
    try {
      await emailService.sendPasswordResetEmail(email, resetToken, user.firstName);
      console.log('📧 Password reset email sent to:', email);
    } catch (emailError) {
      console.warn('⚠️ Email sending failed:', emailError.message);
    }

    res.status(200).json({
      success: true,
      message: 'Password reset email sent successfully',
    });
  } catch (error) {
    console.error('❌ Forgot password error:', error);
    next(error);
  }
};

// ============ RESET PASSWORD ============
exports.resetPassword = async (req, res, next) => {
  try {
    const { token, password } = req.body;

    console.log('🔑 Resetting password with token:', token.substring(0, 10) + '...');

    const user = await User.findOne({
      resetPasswordToken: token,
      resetPasswordExpire: { $gt: Date.now() },
    });

    if (!user) {
      return res.status(400).json({
        success: false,
        message: 'Invalid or expired reset token',
      });
    }

    // Update password
    user.password = password;
    user.resetPasswordToken = undefined;
    user.resetPasswordExpire = undefined;
    await user.save();

    console.log('✅ Password reset successfully for:', user.email);

    res.status(200).json({
      success: true,
      message: 'Password reset successfully',
    });
  } catch (error) {
    console.error('❌ Reset password error:', error);
    next(error);
  }
};

// ============ REFRESH TOKEN ============
exports.refreshToken = async (req, res, next) => {
  try {
    const { refreshToken } = req.body;

    console.log('🔄 Refreshing token');

    if (!refreshToken) {
      return res.status(400).json({
        success: false,
        message: 'Refresh token is required',
      });
    }

    const decoded = tokenService.verifyToken(refreshToken);
    if (!decoded) {
      return res.status(401).json({
        success: false,
        message: 'Invalid refresh token',
      });
    }

    const user = await User.findById(decoded.userId);
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'User not found',
      });
    }

    const newToken = tokenService.generateToken(user._id);
    const newRefreshToken = tokenService.generateRefreshToken(user._id);

    console.log('✅ Token refreshed for:', user.email);

    res.status(200).json({
      success: true,
      data: {
        token: newToken,
        refreshToken: newRefreshToken,
      },
    });
  } catch (error) {
    console.error('❌ Refresh token error:', error);
    next(error);
  }
};

// ============ LOGOUT ============
exports.logout = async (req, res, next) => {
  try {
    console.log('👋 Logout request for:', req.user?.email || 'unknown user');
    
    res.status(200).json({
      success: true,
      message: 'Logged out successfully',
    });
  } catch (error) {
    console.error('❌ Logout error:', error);
    next(error);
  }
};

// ============ GET CURRENT USER ============
exports.getMe = async (req, res, next) => {
  try {
    console.log('👤 Getting current user:', req.user?.email);

    const user = await User.findById(req.user._id)
      .populate('company')
      .select('-password');

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    res.status(200).json({
      success: true,
      data: user,
    });
  } catch (error) {
    console.error('❌ Get current user error:', error);
    next(error);
  }
};

// ============ UPDATE PROFILE ============
exports.updateProfile = async (req, res, next) => {
  try {
    const { firstName, lastName, phone, bio, interests } = req.body;
    const userId = req.params.id || req.user._id;

    console.log('📝 Updating profile for:', userId);

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    // Check ownership or admin
    if (user._id.toString() !== req.user._id.toString() && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'You can only update your own profile',
      });
    }

    // Update fields
    if (firstName) user.firstName = firstName;
    if (lastName) user.lastName = lastName;
    if (phone) user.phone = phone;
    if (bio) user.bio = bio;
    if (interests) user.interests = interests;

    await user.save();

    console.log('✅ Profile updated for:', user.email);

    res.status(200).json({
      success: true,
      message: 'Profile updated successfully',
      data: user,
    });
  } catch (error) {
    console.error('❌ Update profile error:', error);
    next(error);
  }
};

// ============ CHANGE PASSWORD ============
exports.changePassword = async (req, res, next) => {
  try {
    const { currentPassword, newPassword } = req.body;

    console.log('🔑 Password change request for:', req.user.email);

    const user = await User.findById(req.user._id).select('+password');
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    // Verify current password
    const isMatch = await user.matchPassword(currentPassword);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Current password is incorrect',
      });
    }

    // Update password
    user.password = newPassword;
    await user.save();

    console.log('✅ Password changed for:', user.email);

    res.status(200).json({
      success: true,
      message: 'Password changed successfully',
    });
  } catch (error) {
    console.error('❌ Change password error:', error);
    next(error);
  }
};

// ============ DELETE ACCOUNT ============
exports.deleteAccount = async (req, res, next) => {
  try {
    const userId = req.params.id || req.user._id;

    console.log('🗑️ Deleting account:', userId);

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    // Check ownership or admin
    if (user._id.toString() !== req.user._id.toString() && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'You can only delete your own account',
      });
    }

    // Soft delete - deactivate account
    user.isActive = false;
    await user.save();

    console.log('✅ Account deactivated for:', user.email);

    res.status(200).json({
      success: true,
      message: 'Account deactivated successfully',
    });
  } catch (error) {
    console.error('❌ Delete account error:', error);
    next(error);
  }
};