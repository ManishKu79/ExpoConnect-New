const logger = require('../utils/logger');

const errorHandler = (err, req, res, next) => {
  let error = { ...err };
  error.message = err.message;

  logger.error(`${err.statusCode || 500} - ${err.message} - ${req.originalUrl} - ${req.method} - ${req.ip}`);

  if (err.code === 11000) {
    const field = Object.keys(err.keyPattern)[0];
    const message = `Duplicate field value entered for ${field}`;
    error = { statusCode: 400, message };
  }

  if (err.name === 'ValidationError') {
    const message = Object.values(err.errors).map(val => val.message).join(', ');
    error = { statusCode: 400, message };
  }

  if (err.name === 'CastError') {
    const message = `Resource not found with id of ${err.value}`;
    error = { statusCode: 404, message };
  }

  if (err.name === 'JsonWebTokenError') {
    error = { statusCode: 401, message: 'Invalid token' };
  }

  if (err.name === 'TokenExpiredError') {
    error = { statusCode: 401, message: 'Token expired' };
  }

  const statusCode = error.statusCode || 500;
  const message = error.message || 'Server Error';

  res.status(statusCode).json({
    success: false,
    message,
    stack: process.env.NODE_ENV === 'development' ? err.stack : undefined,
  });
};

module.exports = errorHandler;