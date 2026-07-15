const Lead = require('../models/Lead');
const Event = require('../models/Event');
const User = require('../models/User');
const Company = require('../models/Company');
const notificationController = require('./notificationController');
const logger = require('../utils/logger');

// ============ CREATE LEAD ============
exports.createLead = async (req, res, next) => {
  try {
    const { visitorId, eventId, interestLevel, notes, source } = req.body;

    const event = await Event.findById(eventId);
    if (!event) {
      return res.status(404).json({
        success: false,
        message: 'Event not found',
      });
    }

    const visitor = await User.findById(visitorId);
    if (!visitor) {
      return res.status(404).json({
        success: false,
        message: 'Visitor not found',
      });
    }

    // Check if lead already exists
    const existingLead = await Lead.findOne({
      exhibitor: req.user.company,
      visitor: visitorId,
      event: eventId,
    });

    if (existingLead) {
      return res.status(400).json({
        success: false,
        message: 'Lead already exists for this visitor',
      });
    }

    const lead = await Lead.create({
      exhibitor: req.user.company,
      visitor: visitorId,
      event: eventId,
      interestLevel: interestLevel || 5,
      notes: notes || '',
      source: source || 'manual',
      interactions: [{
        type: source === 'qr_scan' ? 'qr_scan' : 'visit',
        description: source === 'qr_scan' ? 'Lead captured via QR scan' : 'Lead created manually',
      }],
    });

    // Calculate initial score
    await exports.scoreLead(lead._id);

    // Send notification to visitor
    const company = await Company.findById(req.user.company);
    await notificationController.createNotification(
      visitorId,
      'lead',
      'New Lead',
      `${company?.name || 'An exhibitor'} has shown interest in you`,
      { leadId: lead._id.toString() }
    );

    res.status(201).json({
      success: true,
      message: 'Lead created successfully',
      data: lead,
    });
  } catch (error) {
    console.error('❌ Create lead error:', error);
    next(error);
  }
};

// ============ GET LEADS ============
exports.getLeads = async (req, res, next) => {
  try {
    const { eventId, status, page = 1, limit = 20 } = req.query;

    const query = { exhibitor: req.user.company };
    if (eventId) query.event = eventId;
    if (status) query.status = status;

    const leads = await Lead.find(query)
      .populate('visitor', 'firstName lastName email profilePicture')
      .populate('event', 'title startDate')
      .sort({ score: -1, createdAt: -1 })
      .skip((parseInt(page) - 1) * parseInt(limit))
      .limit(parseInt(limit));

    const total = await Lead.countDocuments(query);

    // Calculate statistics
    const stats = {
      total: total,
      new: await Lead.countDocuments({ ...query, status: 'new' }),
      contacted: await Lead.countDocuments({ ...query, status: 'contacted' }),
      qualified: await Lead.countDocuments({ ...query, status: 'qualified' }),
      won: await Lead.countDocuments({ ...query, status: 'won' }),
      lost: await Lead.countDocuments({ ...query, status: 'lost' }),
    };

    res.status(200).json({
      success: true,
      data: {
        leads,
        stats,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / parseInt(limit)),
        },
      },
    });
  } catch (error) {
    console.error('❌ Get leads error:', error);
    next(error);
  }
};

// ============ GET LEAD BY ID ============
exports.getLeadById = async (req, res, next) => {
  try {
    const lead = await Lead.findById(req.params.id)
      .populate('visitor', 'firstName lastName email profilePicture phone bio')
      .populate('event', 'title startDate location')
      .populate('exhibitor', 'name logo');

    if (!lead) {
      return res.status(404).json({
        success: false,
        message: 'Lead not found',
      });
    }

    // Check if user is the exhibitor or admin
    if (lead.exhibitor._id.toString() !== req.user.company?.toString() && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'You do not have permission to view this lead',
      });
    }

    res.status(200).json({
      success: true,
      data: lead,
    });
  } catch (error) {
    console.error('❌ Get lead by id error:', error);
    next(error);
  }
};

// ============ UPDATE LEAD ============
exports.updateLead = async (req, res, next) => {
  try {
    const lead = await Lead.findById(req.params.id);
    if (!lead) {
      return res.status(404).json({
        success: false,
        message: 'Lead not found',
      });
    }

    if (lead.exhibitor.toString() !== req.user.company?.toString() && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'You do not have permission to update this lead',
      });
    }

    const updates = req.body;
    const allowedUpdates = ['interestLevel', 'status', 'notes', 'followUpDate'];

    allowedUpdates.forEach(key => {
      if (updates[key] !== undefined) {
        lead[key] = updates[key];
      }
    });

    if (updates.status && updates.status !== lead.status) {
      lead.interactions.push({
        type: 'message',
        description: `Status changed to ${updates.status}`,
      });
    }

    await lead.save();

    // Recalculate score if interest level changed
    if (updates.interestLevel) {
      await exports.scoreLead(lead._id);
    }

    res.status(200).json({
      success: true,
      message: 'Lead updated successfully',
      data: lead,
    });
  } catch (error) {
    console.error('❌ Update lead error:', error);
    next(error);
  }
};

// ============ SCORE LEAD ============
exports.scoreLead = async (leadId) => {
  try {
    const lead = await Lead.findById(leadId);
    if (!lead) return null;

    // Calculate score based on multiple factors
    let score = 0;

    // Interest level (1-10) -> max 40 points
    score += (lead.interestLevel / 10) * 40;

    // Number of interactions -> max 30 points
    const interactionCount = lead.interactions?.length || 0;
    score += Math.min(interactionCount * 5, 30);

    // Status weight
    const statusWeights = {
      'new': 0,
      'contacted': 10,
      'qualified': 20,
      'won': 30,
      'lost': 0,
    };
    score += statusWeights[lead.status] || 0;

    // Cap at 100
    lead.score = Math.min(Math.round(score), 100);
    await lead.save();

    return lead.score;
  } catch (error) {
    console.error('❌ Score lead error:', error);
    return null;
  }
};

// ============ ADD INTERACTION ============
exports.addInteraction = async (req, res, next) => {
  try {
    const { type, description } = req.body;

    const lead = await Lead.findById(req.params.id);
    if (!lead) {
      return res.status(404).json({
        success: false,
        message: 'Lead not found',
      });
    }

    if (lead.exhibitor.toString() !== req.user.company?.toString() && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'You do not have permission to update this lead',
      });
    }

    lead.interactions.push({
      type: type || 'message',
      description: description || 'New interaction',
    });

    await lead.save();
    await exports.scoreLead(lead._id);

    res.status(200).json({
      success: true,
      message: 'Interaction added successfully',
      data: lead,
    });
  } catch (error) {
    console.error('❌ Add interaction error:', error);
    next(error);
  }
};

// ============ DELETE LEAD ============
exports.deleteLead = async (req, res, next) => {
  try {
    const lead = await Lead.findById(req.params.id);
    if (!lead) {
      return res.status(404).json({
        success: false,
        message: 'Lead not found',
      });
    }

    if (lead.exhibitor.toString() !== req.user.company?.toString() && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'You do not have permission to delete this lead',
      });
    }

    await lead.deleteOne();

    res.status(200).json({
      success: true,
      message: 'Lead deleted successfully',
    });
  } catch (error) {
    console.error('❌ Delete lead error:', error);
    next(error);
  }
};

// ============ GET LEAD STATS ============
exports.getLeadStats = async (req, res, next) => {
  try {
    const { eventId } = req.params;
    const companyId = req.user.company;

    const query = { exhibitor: companyId };
    if (eventId) query.event = eventId;

    const stats = {
      total: await Lead.countDocuments(query),
      new: await Lead.countDocuments({ ...query, status: 'new' }),
      contacted: await Lead.countDocuments({ ...query, status: 'contacted' }),
      qualified: await Lead.countDocuments({ ...query, status: 'qualified' }),
      won: await Lead.countDocuments({ ...query, status: 'won' }),
      lost: await Lead.countDocuments({ ...query, status: 'lost' }),
      avgScore: 0,
    };

    const leads = await Lead.find(query).select('score');
    if (leads.length > 0) {
      const totalScore = leads.reduce((sum, l) => sum + (l.score || 0), 0);
      stats.avgScore = Math.round(totalScore / leads.length);
    }

    res.status(200).json({
      success: true,
      data: stats,
    });
  } catch (error) {
    console.error('❌ Get lead stats error:', error);
    next(error);
  }
};