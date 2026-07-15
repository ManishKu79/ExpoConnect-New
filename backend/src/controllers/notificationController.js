const Notification = require('../models/Notification');
const Event = require('../models/Event');
const User = require('../models/User');
const { getIO } = require('../sockets');
const logger = require('../utils/logger');

// ============ GET USER NOTIFICATIONS ============
exports.getNotifications = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const { page = 1, limit = 20, unreadOnly = false } = req.query;

    const query = { user: userId };
    if (unreadOnly === 'true') {
      query.isRead = false;
    }

    const notifications = await Notification.find(query)
      .sort({ createdAt: -1 })
      .skip((parseInt(page) - 1) * parseInt(limit))
      .limit(parseInt(limit));

    const total = await Notification.countDocuments(query);
    const unreadCount = await Notification.countDocuments({
      user: userId,
      isRead: false,
    });

    res.status(200).json({
      success: true,
      data: {
        notifications,
        unreadCount,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / parseInt(limit)),
        },
      },
    });
  } catch (error) {
    console.error('❌ Get notifications error:', error);
    next(error);
  }
};

// ============ MARK NOTIFICATION AS READ ============
exports.markAsRead = async (req, res, next) => {
  try {
    const { id } = req.params;
    const userId = req.user._id;

    const notification = await Notification.findOne({
      _id: id,
      user: userId,
    });

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: 'Notification not found',
      });
    }

    notification.isRead = true;
    await notification.save();

    res.status(200).json({
      success: true,
      message: 'Notification marked as read',
    });
  } catch (error) {
    console.error('❌ Mark as read error:', error);
    next(error);
  }
};

// ============ MARK ALL NOTIFICATIONS AS READ ============
exports.markAllAsRead = async (req, res, next) => {
  try {
    const userId = req.user._id;

    await Notification.updateMany(
      { user: userId, isRead: false },
      { isRead: true }
    );

    res.status(200).json({
      success: true,
      message: 'All notifications marked as read',
    });
  } catch (error) {
    console.error('❌ Mark all as read error:', error);
    next(error);
  }
};

// ============ DELETE NOTIFICATION ============
exports.deleteNotification = async (req, res, next) => {
  try {
    const { id } = req.params;
    const userId = req.user._id;

    const notification = await Notification.findOne({
      _id: id,
      user: userId,
    });

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: 'Notification not found',
      });
    }

    await notification.deleteOne();

    res.status(200).json({
      success: true,
      message: 'Notification deleted successfully',
    });
  } catch (error) {
    console.error('❌ Delete notification error:', error);
    next(error);
  }
};

// ============ CREATE NOTIFICATION (Internal) ============
exports.createNotification = async (userId, type, title, message, data = {}) => {
  try {
    const notification = await Notification.create({
      user: userId,
      type,
      title,
      message,
      data,
    });

    // Emit real-time notification via Socket.IO
    const io = getIO();
    io.to(`user_${userId}`).emit('new_notification', notification);

    logger.info(`📨 Notification sent to user ${userId}: ${title}`);
    return notification;
  } catch (error) {
    logger.error('❌ Create notification error:', error);
    return null;
  }
};

// ============ SEND EVENT NOTIFICATION ============
exports.sendEventNotification = async (req, res, next) => {
  try {
    const { eventId, title, message } = req.body;

    const event = await Event.findById(eventId);
    if (!event) {
      return res.status(404).json({
        success: false,
        message: 'Event not found',
      });
    }

    // Check if user is organizer
    if (event.organizer.toString() !== req.user._id.toString() && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'You do not have permission to send notifications for this event',
      });
    }

    // Get all registered users for the event
    const registeredUsers = event.registeredUsers || [];
    
    if (registeredUsers.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'No registered users to notify',
      });
    }

    // Send notification to each registered user
    const notifications = [];
    for (const userId of registeredUsers) {
      const notification = await exports.createNotification(
        userId,
        'event',
        title || `Update: ${event.title}`,
        message || `New update for event: ${event.title}`,
        { eventId: event._id.toString(), eventTitle: event.title }
      );
      if (notification) {
        notifications.push(notification);
      }
    }

    res.status(201).json({
      success: true,
      message: `Notification sent to ${notifications.length} users`,
      data: {
        sentCount: notifications.length,
        totalUsers: registeredUsers.length,
      },
    });
  } catch (error) {
    console.error('❌ Send event notification error:', error);
    next(error);
  }
};

// ============ GET UNREAD COUNT ============
exports.getUnreadCount = async (req, res, next) => {
  try {
    const userId = req.user._id;

    const count = await Notification.countDocuments({
      user: userId,
      isRead: false,
    });

    res.status(200).json({
      success: true,
      data: {
        unreadCount: count,
      },
    });
  } catch (error) {
    console.error('❌ Get unread count error:', error);
    next(error);
  }
};