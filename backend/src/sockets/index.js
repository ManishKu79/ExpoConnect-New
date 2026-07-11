const { Server } = require('socket.io');
const SocketService = require('../services/socketService');
const logger = require('../utils/logger');
const { auth } = require('../middleware/auth');

let io;
let socketService;

const initSocket = (server) => {
  io = new Server(server, {
    cors: {
      origin: process.env.FRONTEND_URL || '*',
      methods: ['GET', 'POST'],
    },
  });

  socketService = new SocketService(io);
  socketService.initialize();

  // Middleware for socket authentication
  io.use((socket, next) => {
    const token = socket.handshake.auth.token;
    if (!token) {
      return next(new Error('Authentication required'));
    }

    try {
      // Verify token here (simplified)
      // In production, use proper JWT verification
      socket.userId = socket.handshake.auth.userId;
      next();
    } catch (error) {
      next(new Error('Invalid token'));
    }
  });

  logger.info('Socket.IO initialized');
  return io;
};

const getIO = () => {
  if (!io) {
    throw new Error('Socket.IO not initialized');
  }
  return io;
};

const getSocketService = () => {
  if (!socketService) {
    throw new Error('Socket service not initialized');
  }
  return socketService;
};

module.exports = { initSocket, getIO, getSocketService };