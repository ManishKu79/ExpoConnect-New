// backend/src/services/emailService.js - Updated version
const nodemailer = require('nodemailer');
const logger = require('../utils/logger');

class EmailService {
  constructor() {
    // Only create transporter if credentials are valid
    if (process.env.SMTP_USER && process.env.SMTP_PASS && 
        process.env.SMTP_USER !== 'your_email@gmail.com') {
      this.transporter = nodemailer.createTransport({
        host: process.env.SMTP_HOST || 'smtp.gmail.com',
        port: parseInt(process.env.SMTP_PORT) || 587,
        secure: false,
        auth: {
          user: process.env.SMTP_USER,
          pass: process.env.SMTP_PASS,
        },
      });
    } else {
      this.transporter = null;
      logger.warn('Email service disabled: Invalid credentials');
    }
  }

  async sendEmail({ to, subject, html, text }) {
    // If transporter is not configured, just log and return success
    if (!this.transporter) {
      logger.info(`Email would be sent to ${to}: ${subject}`);
      return { messageId: 'mock-email-id' };
    }

    try {
      const mailOptions = {
        from: process.env.EMAIL_FROM || 'noreply@expoconnect.com',
        to,
        subject,
        html,
        text,
      };

      const info = await this.transporter.sendMail(mailOptions);
      logger.info(`Email sent to ${to}: ${info.messageId}`);
      return info;
    } catch (error) {
      logger.error(`Email sending failed: ${error.message}`);
      // Don't throw - just log and return mock response
      return { messageId: 'mock-email-id-failed' };
    }
  }

  // ... rest of methods
}

module.exports = new EmailService();