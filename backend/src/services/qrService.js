const QRCode = require('qrcode');
const crypto = require('crypto');
const logger = require('../utils/logger');

class QRService {
  generateQRCode(data, options = {}) {
    return new Promise((resolve, reject) => {
      QRCode.toDataURL(JSON.stringify(data), {
        errorCorrectionLevel: 'H',
        width: options.width || 400,
        margin: options.margin || 2,
        color: {
          dark: options.color || '#000000',
          light: options.backgroundColor || '#FFFFFF',
        },
      }, (err, url) => {
        if (err) {
          logger.error(`QR code generation error: ${err.message}`);
          reject(err);
        } else {
          resolve(url);
        }
      });
    });
  }

  generateEntryPassQR(userId, eventId) {
    const data = {
      type: 'entry_pass',
      userId,
      eventId,
      timestamp: Date.now(),
      token: crypto.randomBytes(16).toString('hex'),
    };
    return this.generateQRCode(data, {
      width: 300,
      color: '#2563EB',
      margin: 4,
    });
  }

  generateStallQR(stallId, eventId) {
    const data = {
      type: 'stall_checkin',
      stallId,
      eventId,
      timestamp: Date.now(),
      token: crypto.randomBytes(16).toString('hex'),
    };
    return this.generateQRCode(data, {
      width: 300,
      color: '#10B981',
      margin: 4,
    });
  }

  generateBusinessCardQR(userId) {
    const data = {
      type: 'business_card',
      userId,
      timestamp: Date.now(),
      token: crypto.randomBytes(16).toString('hex'),
    };
    return this.generateQRCode(data, {
      width: 300,
      color: '#6366F1',
      margin: 4,
    });
  }

  verifyQRToken(qrData) {
    try {
      const data = JSON.parse(qrData);
      // Verify token is valid (not expired)
      if (data.timestamp && Date.now() - data.timestamp > 24 * 60 * 60 * 1000) {
        return { valid: false, reason: 'QR code expired' };
      }
      // Verify token structure
      if (!data.token || data.token.length !== 32) {
        return { valid: false, reason: 'Invalid token' };
      }
      return { valid: true, data };
    } catch (error) {
      logger.error(`QR verification error: ${error.message}`);
      return { valid: false, reason: 'Invalid QR code format' };
    }
  }
}

module.exports = new QRService();