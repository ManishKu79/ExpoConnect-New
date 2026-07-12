const express = require('express');
const router = express.Router();
const { validate } = require('../middleware/validation');
const { auth, authorize } = require('../middleware/auth');
const {
  registerValidator,
  loginValidator,
  forgotPasswordValidator,
  resetPasswordValidator,
  verifyEmailValidator,
} = require('../validators/authValidator');
const authController = require('../controllers/authController');

// ============ PUBLIC ROUTES ============
router.post('/register', validate(registerValidator), authController.register);
router.post('/login', validate(loginValidator), authController.login);
router.post('/verify-email', validate(verifyEmailValidator), authController.verifyEmail);
router.post('/forgot-password', validate(forgotPasswordValidator), authController.forgotPassword);
router.post('/reset-password', validate(resetPasswordValidator), authController.resetPassword);
router.post('/refresh-token', authController.refreshToken);

// ============ PROTECTED ROUTES ============
router.get('/me', auth, authController.getMe);
router.post('/logout', auth, authController.logout);
router.put('/profile', auth, authController.updateProfile);
router.put('/profile/:id', auth, authController.updateProfile);
router.post('/change-password', auth, authController.changePassword);
router.delete('/account', auth, authController.deleteAccount);
router.delete('/account/:id', auth, authorize('admin'), authController.deleteAccount);

module.exports = router;