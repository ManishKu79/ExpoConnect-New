const Certificate = require('../models/Certificate');
const logger = require('../utils/logger');
const reportService = require('../services/reportService');

exports.generateCertificate = async (req, res, next) => {
  try {
    const { userId, eventId, type, title, description } = req.body;
    
    const certificate = await Certificate.create({
      user: userId,
      event: eventId,
      type,
      title,
      description,
      issueDate: new Date(),
      verificationCode: Math.random().toString(36).substring(2, 15),
    });

    res.status(201).json({
      success: true,
      message: 'Certificate generated successfully',
      data: certificate,
    });
  } catch (error) {
    logger.error(`Generate certificate error: ${error.message}`);
    next(error);
  }
};

exports.getCertificates = async (req, res, next) => {
  try {
    const query = {};
    if (req.query.userId) query.user = req.query.userId;
    if (req.query.eventId) query.event = req.query.eventId;
    
    const certificates = await Certificate.find(query)
      .populate('user', 'firstName lastName email')
      .populate('event', 'title')
      .sort({ issueDate: -1 });

    res.status(200).json({
      success: true,
      data: certificates,
    });
  } catch (error) {
    logger.error(`Get certificates error: ${error.message}`);
    next(error);
  }
};

exports.getCertificateById = async (req, res, next) => {
  try {
    const certificate = await Certificate.findById(req.params.id)
      .populate('user', 'firstName lastName email')
      .populate('event', 'title');

    if (!certificate) {
      return res.status(404).json({
        success: false,
        message: 'Certificate not found',
      });
    }

    res.status(200).json({
      success: true,
      data: certificate,
    });
  } catch (error) {
    logger.error(`Get certificate by id error: ${error.message}`);
    next(error);
  }
};

exports.downloadCertificate = async (req, res, next) => {
  try {
    const certificate = await Certificate.findById(req.params.id);
    if (!certificate) {
      return res.status(404).json({
        success: false,
        message: 'Certificate not found',
      });
    }

    // Generate PDF certificate
    const result = await reportService.generateCertificatePDF(
      certificate.user,
      certificate.event,
      certificate.type
    );

    res.download(result.filePath, result.fileName, (err) => {
      if (err) {
        logger.error(`Download certificate error: ${err.message}`);
        next(err);
      }
    });
  } catch (error) {
    logger.error(`Download certificate error: ${error.message}`);
    next(error);
  }
};

exports.verifyCertificate = async (req, res, next) => {
  try {
    const { verificationCode } = req.body;
    const certificate = await Certificate.findOne({ verificationCode });

    res.status(200).json({
      success: true,
      data: {
        isValid: !!certificate,
        certificate: certificate || null,
      },
    });
  } catch (error) {
    logger.error(`Verify certificate error: ${error.message}`);
    next(error);
  }
};

exports.deleteCertificate = async (req, res, next) => {
  try {
    const certificate = await Certificate.findById(req.params.id);
    if (!certificate) {
      return res.status(404).json({
        success: false,
        message: 'Certificate not found',
      });
    }

    await certificate.remove();

    res.status(200).json({
      success: true,
      message: 'Certificate deleted successfully',
    });
  } catch (error) {
    logger.error(`Delete certificate error: ${error.message}`);
    next(error);
  }
};