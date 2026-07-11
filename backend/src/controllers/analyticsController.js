const analyticsService = require('../services/analyticsService');
const reportService = require('../services/reportService');
const Event = require('../models/Event');
const logger = require('../utils/logger');

exports.getEventMetrics = async (req, res, next) => {
  try {
    const { eventId } = req.params;
    const { startDate, endDate } = req.query;

    const metrics = await analyticsService.getEventMetrics(eventId, startDate, endDate);

    res.status(200).json({
      success: true,
      data: metrics,
    });
  } catch (error) {
    logger.error(`Get event metrics error: ${error.message}`);
    next(error);
  }
};

exports.getEngagementScore = async (req, res, next) => {
  try {
    const { eventId } = req.params;
    const score = await analyticsService.calculateEngagementScore(eventId);

    res.status(200).json({
      success: true,
      data: { engagementScore: score },
    });
  } catch (error) {
    logger.error(`Get engagement score error: ${error.message}`);
    next(error);
  }
};

exports.generateReport = async (req, res, next) => {
  try {
    const { eventId } = req.params;
    const report = await analyticsService.generateEventReport(eventId);

    res.status(200).json({
      success: true,
      data: report,
    });
  } catch (error) {
    logger.error(`Generate report error: ${error.message}`);
    next(error);
  }
};

exports.downloadReport = async (req, res, next) => {
  try {
    const { eventId } = req.params;
    const result = await reportService.generateEventReportPDF(eventId);

    res.download(result.filePath, result.fileName, (err) => {
      if (err) {
        logger.error(`Download report error: ${err.message}`);
        next(err);
      }
    });
  } catch (error) {
    logger.error(`Download report error: ${error.message}`);
    next(error);
  }
};

exports.getTopPerformingCompanies = async (req, res, next) => {
  try {
    const { eventId } = req.params;
    const companies = await analyticsService.getTopPerformingCompanies(eventId);

    res.status(200).json({
      success: true,
      data: companies,
    });
  } catch (error) {
    logger.error(`Get top performing companies error: ${error.message}`);
    next(error);
  }
};

exports.trackMetric = async (req, res, next) => {
  try {
    const { eventId } = req.params;
    const { metric, value } = req.body;

    const result = await analyticsService.trackMetric(eventId, metric, value);

    res.status(201).json({
      success: true,
      message: 'Metric tracked successfully',
      data: result,
    });
  } catch (error) {
    logger.error(`Track metric error: ${error.message}`);
    next(error);
  }
};