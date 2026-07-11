const PDFDocument = require('pdfkit');
const fs = require('fs');
const path = require('path');
const logger = require('../utils/logger');
const analyticsService = require('./analyticsService');

class ReportService {
  async generateEventReportPDF(eventId) {
    try {
      const reportData = await analyticsService.generateEventReport(eventId);
      const doc = new PDFDocument();

      // Generate PDF
      const fileName = `event-report-${eventId}-${Date.now()}.pdf`;
      const filePath = path.join(__dirname, '../../uploads/reports', fileName);
      
      // Ensure directory exists
      const dir = path.dirname(filePath);
      if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
      }

      const writeStream = fs.createWriteStream(filePath);
      doc.pipe(writeStream);

      // Header
      doc
        .fontSize(25)
        .text('ExpoConnect Event Report', { align: 'center' })
        .moveDown();

      // Event details
      doc
        .fontSize(16)
        .text(`Event: ${reportData.event.title}`)
        .text(`Date: ${new Date(reportData.event.startDate).toLocaleDateString()} - ${new Date(reportData.event.endDate).toLocaleDateString()}`)
        .moveDown();

      // Attendance
      doc
        .fontSize(18)
        .text('Attendance', { underline: true })
        .fontSize(14)
        .text(`Total Attendees: ${reportData.attendance.totalAttendees}`)
        .text(`Total Exhibitors: ${reportData.attendance.totalExhibitors}`)
        .text(`Attendee/Exhibitor Ratio: ${reportData.attendance.ratio.toFixed(2)}`)
        .moveDown();

      // Networking
      doc
        .fontSize(18)
        .text('Networking Metrics', { underline: true })
        .fontSize(14)
        .text(`Total Leads: ${reportData.networking.totalLeads}`)
        .text(`Total Meetings: ${reportData.networking.totalMeetings}`)
        .text(`Meetings Completed: ${reportData.networking.meetingsCompleted}`)
        .text(`Conversion Rate: ${reportData.networking.conversionRate}%`)
        .moveDown();

      // Engagement Score
      doc
        .fontSize(18)
        .text('Engagement Score', { underline: true })
        .fontSize(24)
        .text(`${reportData.engagementScore}/100`, { align: 'center' })
        .moveDown();

      // Lead Quality Distribution
      doc
        .fontSize(18)
        .text('Lead Quality Distribution', { underline: true })
        .fontSize(14);

      Object.entries(reportData.leadQuality).forEach(([status, count]) => {
        doc.text(`${status}: ${count}`);
      });

      doc.end();

      return {
        fileName,
        filePath,
        reportData,
      };
    } catch (error) {
      logger.error(`PDF generation error: ${error.message}`);
      throw error;
    }
  }

  async generateLeadReportPDF(companyId, eventId) {
    const doc = new PDFDocument();
    const fileName = `lead-report-${companyId}-${Date.now()}.pdf`;
    const filePath = path.join(__dirname, '../../uploads/reports', fileName);
    
    const writeStream = fs.createWriteStream(filePath);
    doc.pipe(writeStream);

    // Header
    doc
      .fontSize(25)
      .text('ExpoConnect Lead Report', { align: 'center' })
      .moveDown();

    // Add lead data
    doc
      .fontSize(14)
      .text('Lead Report Generated', { align: 'center' })
      .text(new Date().toLocaleString(), { align: 'center' })
      .moveDown();

    doc.end();

    return {
      fileName,
      filePath,
    };
  }

  async generateCertificatePDF(userId, eventId, certificateType) {
    const doc = new PDFDocument({
      layout: 'landscape',
      size: 'A4',
    });
    const fileName = `certificate-${userId}-${eventId}-${Date.now()}.pdf`;
    const filePath = path.join(__dirname, '../../uploads/certificates', fileName);
    
    const writeStream = fs.createWriteStream(filePath);
    doc.pipe(writeStream);

    // Design certificate
    doc
      .fontSize(40)
      .text('ExpoConnect', { align: 'center' })
      .moveDown();

    doc
      .fontSize(30)
      .text('Certificate of Participation', { align: 'center' })
      .moveDown();

    doc
      .fontSize(20)
      .text('This certificate is presented to', { align: 'center' })
      .moveDown();

    // User name
    doc
      .fontSize(28)
      .text('Participant Name', { align: 'center' })
      .moveDown();

    doc
      .fontSize(16)
      .text(`For ${certificateType} at ExpoConnect`, { align: 'center' })
      .moveDown();

    doc
      .fontSize(12)
      .text(`Date: ${new Date().toLocaleDateString()}`, { align: 'center' });

    doc.end();

    return {
      fileName,
      filePath,
    };
  }
}

module.exports = new ReportService();