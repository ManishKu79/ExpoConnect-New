const logger = require('../utils/logger');
const Notification = require('../models/Notification');

class SocketService {
  constructor(io) {
    this.io = io;
    this.userSockets = new Map(); // userId -> socketId
  }

  initialize() {
    this.io.on('connection', (socket) => {
      logger.info(`New socket connection: ${socket.id}`);

      socket.on('authenticate', (userId) => {
        this.userSockets.set(userId, socket.id);
        socket.userId = userId;
        logger.info(`User ${userId} authenticated with socket ${socket.id}`);
      });

      socket.on('disconnect', () => {
        if (socket.userId) {
          this.userSockets.delete(socket.userId);
          logger.info(`User ${socket.userId} disconnected`);
        }
      });

      // Meeting events
      socket.on('join-meeting', (meetingId) => {
        socket.join(`meeting-${meetingId}`);
      });

      socket.on('leave-meeting', (meetingId) => {
        socket.leave(`meeting-${meetingId}`);
      });

      socket.on('meeting-message', (data) => {
        this.io.to(`meeting-${data.meetingId}`).emit('meeting-message', data);
      });
    });
  }

  sendNotification(userId, notification) {
    const socketId = this.userSockets.get(userId);
    if (socketId) {
      this.io.to(socketId).emit('notification', notification);
      return true;
    }
    return false;
  }

  sendNotificationToMultiple(userIds, notification) {
    let sent = 0;
    userIds.forEach(userId => {
      if (this.sendNotification(userId, notification)) {
        sent++;
      }
    });
    return sent;
  }

  broadcastToRoom(room, event, data) {
    this.io.to(room).emit(event, data);
  }

  async saveAndSendNotification(userId, notificationData) {
    try {
      const notification = await Notification.create({
        user: userId,
        ...notificationData,
      });

      this.sendNotification(userId, notification);
      return notification;
    } catch (error) {
      logger.error(`Failed to save and send notification: ${error.message}`);
      return null;
    }
  }
}

module.exports = SocketService;