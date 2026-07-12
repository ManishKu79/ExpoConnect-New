const { body } = require('express-validator');

const registerValidator = [
  body('firstName')
    .optional({ checkFalsy: true })
    .isLength({ min: 1, max: 50 })
    .withMessage('First name must be between 1 and 50 characters')
    .default('User'),
  
  body('lastName')
    .optional({ checkFalsy: true })
    .isLength({ min: 1, max: 50 })
    .withMessage('Last name must be between 1 and 50 characters')
    .default('Name'),
  
  body('email')
    .notEmpty()
    .withMessage('Email is required')
    .isEmail()
    .withMessage('Please provide a valid email')
    .normalizeEmail(),
  
  body('password')
    .notEmpty()
    .withMessage('Password is required')
    .isLength({ min: 6 })
    .withMessage('Password must be at least 6 characters'),
  
  body('role')
    .optional()
    .isIn(['visitor', 'exhibitor', 'organizer', 'sponsor', 'speaker', 'investor'])
    .withMessage('Invalid role selected')
    .default('visitor'),
  
  body('phone')
    .optional()
    .matches(/^\+?[1-9]\d{1,14}$/)
    .withMessage('Please provide a valid phone number')
    .default(''),
];

const loginValidator = [
  body('email')
    .notEmpty()
    .withMessage('Email is required')
    .isEmail()
    .withMessage('Please provide a valid email')
    .normalizeEmail(),
  
  body('password')
    .notEmpty()
    .withMessage('Password is required'),
];

const forgotPasswordValidator = [
  body('email')
    .notEmpty()
    .withMessage('Email is required')
    .isEmail()
    .withMessage('Please provide a valid email')
    .normalizeEmail(),
];

const resetPasswordValidator = [
  body('token')
    .notEmpty()
    .withMessage('Reset token is required'),
  
  body('password')
    .notEmpty()
    .withMessage('Password is required')
    .isLength({ min: 6 })
    .withMessage('Password must be at least 6 characters'),
];

const verifyEmailValidator = [
  body('token')
    .notEmpty()
    .withMessage('Verification token is required'),
];

module.exports = {
  registerValidator,
  loginValidator,
  forgotPasswordValidator,
  resetPasswordValidator,
  verifyEmailValidator,
};