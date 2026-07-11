const express = require('express');
const router = express.Router();
const { auth, authorize } = require('../middleware/auth');
const { uploadProfile } = require('../middleware/upload');
const userController = require('../controllers/userController');

// All routes require authentication
router.use(auth);

// User management
router.get('/', authorize('admin'), userController.getAllUsers);
router.get('/:id', userController.getUserById);
router.put('/:id', userController.updateUser);
router.delete('/:id', userController.deleteUser);
router.post('/change-password', userController.changePassword);

// Profile picture
router.put('/:id/profile-picture', uploadProfile, userController.updateProfilePicture);

module.exports = router;