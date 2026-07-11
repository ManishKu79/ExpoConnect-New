const nodemailer = require('nodemailer');
const logger = require('../utils/logger');
const fs = require('fs');
const path = require('path');

class EmailService {
  constructor() {
    this.transporter = nodemailer.createTransport({
      host: process.env.SMTP_HOST,
      port: process.env.SMTP_PORT,
      secure: false,
      auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASS,
      },
    });
  }

  async sendEmail({ to, subject, html, text }) {
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
      throw new Error('Failed to send email');
    }
  }

  async sendVerificationEmail(email, token, firstName) {
    const verificationUrl = `${process.env.FRONTEND_URL}/verify-email?token=${token}`;
    const html = this.getEmailTemplate('emailVerification', {
      name: firstName,
      verificationUrl,
    });

    return this.sendEmail({
      to: email,
      subject: 'Verify Your Email - ExpoConnect',
      html,
    });
  }

  async sendPasswordResetEmail(email, token, firstName) {
    const resetUrl = `${process.env.FRONTEND_URL}/reset-password?token=${token}`;
    const html = this.getEmailTemplate('passwordReset', {
      name: firstName,
      resetUrl,
    });

    return this.sendEmail({
      to: email,
      subject: 'Reset Your Password - ExpoConnect',
      html,
    });
  }

  getEmailTemplate(templateName, data) {
    const templatePath = path.join(__dirname, '../templates', `${templateName}.html`);
    let html = fs.readFileSync(templatePath, 'utf8');
    
    // Replace placeholders
    for (const [key, value] of Object.entries(data)) {
      html = html.replace(new RegExp(`{{${key}}}`, 'g'), value);
    }
    
    return html;
  }
}

module.exports = new EmailService();