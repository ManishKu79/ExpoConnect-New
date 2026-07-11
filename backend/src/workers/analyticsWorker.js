const cron = require('node-cron');
const analyticsService = require('../services/analyticsService');
const Event = require('../models/Event');
const logger = require('../utils/logger');

const setupCronJobs = () => {
  // Calculate daily analytics every day at midnight
  cron.schedule('0 0 * * *', async () => {
    logger.info('Running daily analytics calculation...');
    try {
      const events = await Event.find({
        status: { $in: ['ongoing', 'completed'] },
      });

      for (const event of events) {
        const score = await analyticsService.calculateEngagementScore(event._id);
        await analyticsService.trackMetric(event._id, 'daily_engagement', score);
      }

      logger.info(`Updated analytics for ${events.length} events`);
    } catch (error) {
      logger.error(`Daily analytics error: ${error.message}`);
    }
  });

  // Generate weekly reports every Sunday at midnight
  cron.schedule('0 0 * * 0', async () => {
    logger.info('Generating weekly reports...');
    try {
      const events = await Event.find({
        status: { $in: ['ongoing', 'completed'] },
      });

      for (const event of events) {
        const report = await analyticsService.generateEventReport(event._id);
        // Store report
        await analyticsService.trackMetric(event._id, 'weekly_report', report.engagementScore);
      }

      logger.info(`Generated weekly reports for ${events.length} events`);
    } catch (error) {
      logger.error(`Weekly report generation error: ${error.message}`);
    }
  });
};

module.exports = { setupCronJobs };