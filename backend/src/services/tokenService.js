const jwt = require('jsonwebtoken');
const crypto = require('crypto');

class TokenService {
  generateToken(userId) {
    return jwt.sign(
      { userId },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRE || '7d' }
    );
  }

  generateRefreshToken(userId) {
    return jwt.sign(
      { userId },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_REFRESH_EXPIRE || '30d' }
    );
  }

  verifyToken(token) {
    try {
      return jwt.verify(token, process.env.JWT_SECRET);
    } catch (error) {
      return null;
    }
  }

  generateVerificationToken() {
    return crypto.randomBytes(32).toString('hex');
  }

  generateResetToken() {
    return crypto.randomBytes(32).toString('hex');
  }
}

module.exports = new TokenService();