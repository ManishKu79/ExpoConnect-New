const aiService = require('../services/aiService');
const logger = require('../utils/logger');

exports.getRecommendations = async (req, res, next) => {
  try {
    const recommendations = await aiService.getRecommendations(req.user._id);
    res.status(200).json({
      success: true,
      data: recommendations,
    });
  } catch (error) {
    logger.error(`Get recommendations error: ${error.message}`);
    next(error);
  }
};

exports.analyzeSentiment = async (req, res, next) => {
  try {
    const { text } = req.body;
    const result = await aiService.analyzeSentiment(text);
    res.status(200).json({
      success: true,
      data: result,
    });
  } catch (error) {
    logger.error(`Analyze sentiment error: ${error.message}`);
    next(error);
  }
};

exports.summarizeText = async (req, res, next) => {
  try {
    const { text, maxLength } = req.body;
    const result = await aiService.summarizeText(text, maxLength);
    res.status(200).json({
      success: true,
      data: result,
    });
  } catch (error) {
    logger.error(`Summarize text error: ${error.message}`);
    next(error);
  }
};

exports.extractBusinessInfo = async (req, res, next) => {
  try {
    const { text } = req.body;
    const result = await aiService.extractBusinessInfo(text);
    res.status(200).json({
      success: true,
      data: result,
    });
  } catch (error) {
    logger.error(`Extract business info error: ${error.message}`);
    next(error);
  }
};

exports.matchOpportunities = async (req, res, next) => {
  try {
    const { companyId } = req.body;
    const result = await aiService.matchOpportunities(companyId);
    res.status(200).json({
      success: true,
      data: result,
    });
  } catch (error) {
    logger.error(`Match opportunities error: ${error.message}`);
    next(error);
  }
};

exports.generateInsights = async (req, res, next) => {
  try {
    const { companyId } = req.body;
    const result = await aiService.generateBusinessInsights(companyId);
    res.status(200).json({
      success: true,
      data: result,
    });
  } catch (error) {
    logger.error(`Generate insights error: ${error.message}`);
    next(error);
  }
};

exports.extractBusinessCard = async (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Image file is required',
      });
    }

    // Upload image to Cloudinary first
    const uploadService = require('../services/uploadService');
    const result = await uploadService.uploadToCloudinary(req.file.buffer, {
      folder: 'expoconnect/business-cards',
    });

    const extractedInfo = await aiService.extractBusinessCard(result.url);

    res.status(200).json({
      success: true,
      data: extractedInfo,
    });
  } catch (error) {
    logger.error(`Extract business card error: ${error.message}`);
    next(error);
  }
};

exports.transcribeAudio = async (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Audio file is required',
      });
    }

    // Upload audio to Cloudinary
    const uploadService = require('../services/uploadService');
    const result = await uploadService.uploadToCloudinary(req.file.buffer, {
      folder: 'expoconnect/voice-notes',
      resource_type: 'video', // For audio files
    });

    const transcript = await aiService.transcribeAudio(result.url);

    res.status(200).json({
      success: true,
      data: transcript,
    });
  } catch (error) {
    logger.error(`Transcribe audio error: ${error.message}`);
    next(error);
  }
};