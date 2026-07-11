const logger = require('../utils/logger');
const uploadService = require('../services/uploadService');

exports.uploadDocuments = async (req, res, next) => {
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Files are required',
      });
    }

    const uploadPromises = req.files.map(file =>
      uploadService.uploadToCloudinary(file.buffer, {
        folder: 'expoconnect/documents',
      })
    );

    const results = await Promise.all(uploadPromises);

    res.status(201).json({
      success: true,
      message: 'Documents uploaded successfully',
      data: results.map(result => ({
        url: result.url,
        publicId: result.publicId,
      })),
    });
  } catch (error) {
    logger.error(`Upload documents error: ${error.message}`);
    next(error);
  }
};

exports.getDocuments = async (req, res, next) => {
  try {
    // This would typically fetch from a Document model
    // For now, return a placeholder
    res.status(200).json({
      success: true,
      data: [],
      message: 'Document management to be implemented with storage',
    });
  } catch (error) {
    logger.error(`Get documents error: ${error.message}`);
    next(error);
  }
};

exports.getDocumentById = async (req, res, next) => {
  try {
    res.status(200).json({
      success: true,
      data: { id: req.params.id },
      message: 'Document details to be implemented',
    });
  } catch (error) {
    logger.error(`Get document by id error: ${error.message}`);
    next(error);
  }
};

exports.downloadDocument = async (req, res, next) => {
  try {
    res.status(200).json({
      success: true,
      message: 'Download functionality to be implemented',
    });
  } catch (error) {
    logger.error(`Download document error: ${error.message}`);
    next(error);
  }
};

exports.deleteDocument = async (req, res, next) => {
  try {
    res.status(200).json({
      success: true,
      message: 'Document deleted successfully',
    });
  } catch (error) {
    logger.error(`Delete document error: ${error.message}`);
    next(error);
  }
};