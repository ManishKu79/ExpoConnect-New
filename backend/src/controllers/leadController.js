const Lead = require('../models/Lead');
const User = require('../models/User');
const Company = require('../models/Company');
const aiService = require('../services/aiService');
const logger = require('../utils/logger');
const Event = require('../models/Event');

exports.createLead = async (req, res, next) => {
  try {
    const { visitorId, eventId, interestLevel, notes } = req.body;
    
    const lead = await Lead.create({
      exhibitor: req.user.company,
      visitor: visitorId,
      event: eventId,
      interestLevel,
      notes,
      interactions: [{
        type: 'visit',
        description: 'Initial interaction',
      }],
    });

    // Score the lead
    await aiService.scoreLead(lead._id);

    // Get follow-up suggestions
    const suggestions = await aiService.generateFollowUpSuggestions(lead._id);

    res.status(201).json({
      success: true,
      message: 'Lead created successfully',
      data: { lead, suggestions },
    });
  } catch (error) {
    logger.error(`Create lead error: ${error.message}`);
    next(error);
  }
};

exports.getLeads = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    const query = {};
    if (req.user.role === 'exhibitor') {
      query.exhibitor = req.user.company;
    }
    if (req.query.status) query.status = req.query.status;
    if (req.query.eventId) query.event = req.query.eventId;

    const leads = await Lead.find(query)
      .skip(skip)
      .limit(limit)
      .populate('visitor', 'firstName lastName email profilePicture')
      .populate('exhibitor', 'name logo')
      .populate('event', 'title')
      .sort({ score: -1, createdAt: -1 });

    const total = await Lead.countDocuments(query);

    res.status(200).json({
      success: true,
      data: leads,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    logger.error(`Get leads error: ${error.message}`);
    next(error);
  }
};

exports.updateLead = async (req, res, next) => {
  try {
    const lead = await Lead.findById(req.params.id);
    if (!lead) {
      return res.status(404).json({
        success: false,
        message: 'Lead not found',
      });
    }

    // Check ownership
    if (lead.exhibitor.toString() !== req.user.company?.toString() && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'You do not have permission to update this lead',
      });
    }

    const updates = req.body;
    Object.keys(updates).forEach(key => {
      lead[key] = updates[key];
    });

    if (updates.interestLevel) {
      await aiService.scoreLead(lead._id);
    }

    await lead.save();

    res.status(200).json({
      success: true,
      message: 'Lead updated successfully',
      data: lead,
    });
  } catch (error) {
    logger.error(`Update lead error: ${error.message}`);
    next(error);
  }
};

exports.scoreLead = async (req, res, next) => {
  try {
    const result = await aiService.scoreLead(req.params.id);
    res.status(200).json({
      success: true,
      data: result,
    });
  } catch (error) {
    logger.error(`Score lead error: ${error.message}`);
    next(error);
  }
};

exports.getLeadRecommendations = async (req, res, next) => {
  try {
    const recommendations = await aiService.getRecommendations(req.user._id);
    res.status(200).json({
      success: true,
      data: recommendations,
    });
  } catch (error) {
    logger.error(`Get lead recommendations error: ${error.message}`);
    next(error);
  }
};

exports.deleteLead = async (req, res, next) => {
  try {
    const lead = await Lead.findById(req.params.id);
    if (!lead) {
      return res.status(404).json({
        success: false,
        message: 'Lead not found',
      });
    }

    // Check ownership
    if (lead.exhibitor.toString() !== req.user.company?.toString() && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'You do not have permission to delete this lead',
      });
    }

    await lead.remove();

    res.status(200).json({
      success: true,
      message: 'Lead deleted successfully',
    });
  } catch (error) {
    logger.error(`Delete lead error: ${error.message}`);
    next(error);
  }
};