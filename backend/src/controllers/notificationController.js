const Notification = require('../models/Notification');
const { getSocketService } = require('../sockets');
const logger = require('../utils/logger');

exports.getNotifications = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const query = { user: req.user._id };
    if (req.query.read !== undefined) {
      query.read = req.query.read === 'true';
    }

    const notifications = await Notification.find(query)
      .skip(skip)
      .limit(limit)
      .sort({ createdAt: -1 });

    const total = await Notification.countDocuments(query);
    const unreadCount = await Notification.countDocuments({
      user: req.user._id,
      read: false,
    });

    res.status(200).json({
      success: true,
      data: {
        notifications,
        unreadCount,
        pagination: {
          page,
          limit,
          total,
          pages: Math.ceil(total / limit),
        },
      },
    });
  } catch (error) {
    logger.error(`Get notifications error: ${error.message}`);
    next(error);
  }
};

exports.markAsRead = async (req, res, next) => {
  try {
    const notification = await Notification.findOne({
      _id: req.params.id,
      user: req.user._id,
    });

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: 'Notification not found',
      });
    }

    notification.read = true;
    await notification.save();

    res.status(200).json({
      success: true,
      message: 'Notification marked as read',
    });
  } catch (error) {
    logger.error(`Mark as read error: ${error.message}`);
    next(error);
  }
};

exports.markAllAsRead = async (req, res, next) => {
  try {
    await Notification.updateMany(
      { user: req.user._id, read: false },
      { read: true }
    );

    res.status(200).json({
      success: true,
      message: 'All notifications marked as read',
    });
  } catch (error) {
    logger.error(`Mark all as read error: ${error.message}`);
    next(error);
  }
};

exports.sendNotification = async (req, res, next) => {
  try {
    const { userId, type, title, message, link } = req.body;

    if (req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Only administrators can send notifications',
      });
    }

    const socketService = getSocketService();
    const notification = await socketService.saveAndSendNotification(userId, {
      type,
      title,
      message,
      link,
    });

    res.status(201).json({
      success: true,
      message: 'Notification sent successfully',
      data: notification,
    });
  } catch (error) {
    logger.error(`Send notification error: ${error.message}`);
    next(error);
  }
};

exports.deleteNotification = async (req, res, next) => {
  try {
    const notification = await Notification.findOne({
      _id: req.params.id,
      user: req.user._id,
    });

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: 'Notification not found',
      });
    }

    await notification.remove();

    res.status(200).json({
      success: true,
      message: 'Notification deleted successfully',
    });
  } catch (error) {
    logger.error(`Delete notification error: ${error.message}`);
    next(error);
  }
};