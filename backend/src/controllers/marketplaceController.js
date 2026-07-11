const Opportunity = require('../models/Opportunity');
const Partnership = require('../models/Partnership');
const Collaboration = require('../models/Collaboration');
const KnowledgeShare = require('../models/KnowledgeShare');
const GoalTracker = require('../models/GoalTracker');
const logger = require('../utils/logger');

// ============ OPPORTUNITY CONTROLLERS ============

exports.getOpportunities = async (req, res, next) => {
  try {
    const opportunities = await Opportunity.find({ status: 'open' })
      .populate('company', 'name logo')
      .populate('event', 'title')
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      data: opportunities,
    });
  } catch (error) {
    logger.error(`Get opportunities error: ${error.message}`);
    next(error);
  }
};

exports.createOpportunity = async (req, res, next) => {
  try {
    const opportunity = await Opportunity.create({
      ...req.body,
      company: req.user.company,
    });

    res.status(201).json({
      success: true,
      data: opportunity,
    });
  } catch (error) {
    logger.error(`Create opportunity error: ${error.message}`);
    next(error);
  }
};

exports.getOpportunityById = async (req, res, next) => {
  try {
    const opportunity = await Opportunity.findById(req.params.id)
      .populate('company', 'name logo description')
      .populate('event', 'title');

    if (!opportunity) {
      return res.status(404).json({
        success: false,
        message: 'Opportunity not found',
      });
    }

    res.status(200).json({
      success: true,
      data: opportunity,
    });
  } catch (error) {
    logger.error(`Get opportunity by id error: ${error.message}`);
    next(error);
  }
};

exports.updateOpportunity = async (req, res, next) => {
  try {
    const opportunity = await Opportunity.findById(req.params.id);
    if (!opportunity) {
      return res.status(404).json({
        success: false,
        message: 'Opportunity not found',
      });
    }

    Object.assign(opportunity, req.body);
    await opportunity.save();

    res.status(200).json({
      success: true,
      data: opportunity,
    });
  } catch (error) {
    logger.error(`Update opportunity error: ${error.message}`);
    next(error);
  }
};

exports.expressInterest = async (req, res, next) => {
  try {
    const opportunity = await Opportunity.findById(req.params.id);
    if (!opportunity) {
      return res.status(404).json({
        success: false,
        message: 'Opportunity not found',
      });
    }

    opportunity.interestedCompanies.push({
      company: req.user.company,
      status: 'interested',
    });
    await opportunity.save();

    res.status(200).json({
      success: true,
      message: 'Interest expressed successfully',
    });
  } catch (error) {
    logger.error(`Express interest error: ${error.message}`);
    next(error);
  }
};

exports.deleteOpportunity = async (req, res, next) => {
  try {
    await Opportunity.findByIdAndDelete(req.params.id);
    res.status(200).json({
      success: true,
      message: 'Opportunity deleted successfully',
    });
  } catch (error) {
    logger.error(`Delete opportunity error: ${error.message}`);
    next(error);
  }
};

// ============ PARTNERSHIP CONTROLLERS ============

exports.createPartnership = async (req, res, next) => {
  try {
    const partnership = await Partnership.create(req.body);
    res.status(201).json({
      success: true,
      data: partnership,
    });
  } catch (error) {
    logger.error(`Create partnership error: ${error.message}`);
    next(error);
  }
};

exports.getPartnerships = async (req, res, next) => {
  try {
    const partnerships = await Partnership.find({
      $or: [
        { company1: req.user.company },
        { company2: req.user.company },
      ],
    })
      .populate('company1', 'name logo')
      .populate('company2', 'name logo');

    res.status(200).json({
      success: true,
      data: partnerships,
    });
  } catch (error) {
    logger.error(`Get partnerships error: ${error.message}`);
    next(error);
  }
};

exports.getPartnershipById = async (req, res, next) => {
  try {
    const partnership = await Partnership.findById(req.params.id)
      .populate('company1', 'name logo')
      .populate('company2', 'name logo');

    if (!partnership) {
      return res.status(404).json({
        success: false,
        message: 'Partnership not found',
      });
    }

    res.status(200).json({
      success: true,
      data: partnership,
    });
  } catch (error) {
    logger.error(`Get partnership by id error: ${error.message}`);
    next(error);
  }
};

exports.updatePartnership = async (req, res, next) => {
  try {
    const partnership = await Partnership.findById(req.params.id);
    if (!partnership) {
      return res.status(404).json({
        success: false,
        message: 'Partnership not found',
      });
    }

    Object.assign(partnership, req.body);
    await partnership.save();

    res.status(200).json({
      success: true,
      data: partnership,
    });
  } catch (error) {
    logger.error(`Update partnership error: ${error.message}`);
    next(error);
  }
};

exports.addMilestone = async (req, res, next) => {
  try {
    const partnership = await Partnership.findById(req.params.id);
    if (!partnership) {
      return res.status(404).json({
        success: false,
        message: 'Partnership not found',
      });
    }

    partnership.milestones.push(req.body);
    await partnership.save();

    res.status(200).json({
      success: true,
      data: partnership,
    });
  } catch (error) {
    logger.error(`Add milestone error: ${error.message}`);
    next(error);
  }
};

exports.deletePartnership = async (req, res, next) => {
  try {
    await Partnership.findByIdAndDelete(req.params.id);
    res.status(200).json({
      success: true,
      message: 'Partnership deleted successfully',
    });
  } catch (error) {
    logger.error(`Delete partnership error: ${error.message}`);
    next(error);
  }
};

// ============ COLLABORATION CONTROLLERS ============

exports.createCollaboration = async (req, res, next) => {
  try {
    const collaboration = await Collaboration.create(req.body);
    res.status(201).json({
      success: true,
      data: collaboration,
    });
  } catch (error) {
    logger.error(`Create collaboration error: ${error.message}`);
    next(error);
  }
};

exports.getCollaborations = async (req, res, next) => {
  try {
    const collaborations = await Collaboration.find({
      companies: req.user.company,
    })
      .populate('companies', 'name logo')
      .populate('leadCompany', 'name logo');

    res.status(200).json({
      success: true,
      data: collaborations,
    });
  } catch (error) {
    logger.error(`Get collaborations error: ${error.message}`);
    next(error);
  }
};

exports.getCollaborationById = async (req, res, next) => {
  try {
    const collaboration = await Collaboration.findById(req.params.id)
      .populate('companies', 'name logo')
      .populate('leadCompany', 'name logo');

    if (!collaboration) {
      return res.status(404).json({
        success: false,
        message: 'Collaboration not found',
      });
    }

    res.status(200).json({
      success: true,
      data: collaboration,
    });
  } catch (error) {
    logger.error(`Get collaboration by id error: ${error.message}`);
    next(error);
  }
};

exports.updateCollaboration = async (req, res, next) => {
  try {
    const collaboration = await Collaboration.findById(req.params.id);
    if (!collaboration) {
      return res.status(404).json({
        success: false,
        message: 'Collaboration not found',
      });
    }

    Object.assign(collaboration, req.body);
    await collaboration.save();

    res.status(200).json({
      success: true,
      data: collaboration,
    });
  } catch (error) {
    logger.error(`Update collaboration error: ${error.message}`);
    next(error);
  }
};

exports.addCommunication = async (req, res, next) => {
  try {
    const collaboration = await Collaboration.findById(req.params.id);
    if (!collaboration) {
      return res.status(404).json({
        success: false,
        message: 'Collaboration not found',
      });
    }

    collaboration.communications.push({
      user: req.user._id,
      message: req.body.message,
    });
    await collaboration.save();

    res.status(200).json({
      success: true,
      data: collaboration,
    });
  } catch (error) {
    logger.error(`Add communication error: ${error.message}`);
    next(error);
  }
};

exports.deleteCollaboration = async (req, res, next) => {
  try {
    await Collaboration.findByIdAndDelete(req.params.id);
    res.status(200).json({
      success: true,
      message: 'Collaboration deleted successfully',
    });
  } catch (error) {
    logger.error(`Delete collaboration error: ${error.message}`);
    next(error);
  }
};

// ============ KNOWLEDGE SHARE CONTROLLERS ============

exports.createKnowledgeShare = async (req, res, next) => {
  try {
    const knowledge = await KnowledgeShare.create({
      ...req.body,
      author: req.user._id,
      company: req.user.company,
    });

    res.status(201).json({
      success: true,
      data: knowledge,
    });
  } catch (error) {
    logger.error(`Create knowledge share error: ${error.message}`);
    next(error);
  }
};

exports.getKnowledgeShares = async (req, res, next) => {
  try {
    const knowledge = await KnowledgeShare.find({ isPublished: true })
      .populate('author', 'firstName lastName')
      .populate('company', 'name logo')
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      data: knowledge,
    });
  } catch (error) {
    logger.error(`Get knowledge shares error: ${error.message}`);
    next(error);
  }
};

exports.getKnowledgeShareById = async (req, res, next) => {
  try {
    const knowledge = await KnowledgeShare.findById(req.params.id)
      .populate('author', 'firstName lastName')
      .populate('company', 'name logo');

    if (!knowledge) {
      return res.status(404).json({
        success: false,
        message: 'Knowledge share not found',
      });
    }

    res.status(200).json({
      success: true,
      data: knowledge,
    });
  } catch (error) {
    logger.error(`Get knowledge share by id error: ${error.message}`);
    next(error);
  }
};

exports.likeKnowledgeShare = async (req, res, next) => {
  try {
    const knowledge = await KnowledgeShare.findById(req.params.id);
    if (!knowledge) {
      return res.status(404).json({
        success: false,
        message: 'Knowledge share not found',
      });
    }

    const index = knowledge.likes.indexOf(req.user._id);
    if (index === -1) {
      knowledge.likes.push(req.user._id);
    } else {
      knowledge.likes.splice(index, 1);
    }
    await knowledge.save();

    res.status(200).json({
      success: true,
      data: { likes: knowledge.likes.length },
    });
  } catch (error) {
    logger.error(`Like knowledge share error: ${error.message}`);
    next(error);
  }
};

exports.addComment = async (req, res, next) => {
  try {
    const knowledge = await KnowledgeShare.findById(req.params.id);
    if (!knowledge) {
      return res.status(404).json({
        success: false,
        message: 'Knowledge share not found',
      });
    }

    knowledge.comments.push({
      user: req.user._id,
      content: req.body.content,
    });
    await knowledge.save();

    res.status(200).json({
      success: true,
      data: knowledge,
    });
  } catch (error) {
    logger.error(`Add comment error: ${error.message}`);
    next(error);
  }
};

exports.updateKnowledgeShare = async (req, res, next) => {
  try {
    const knowledge = await KnowledgeShare.findById(req.params.id);
    if (!knowledge) {
      return res.status(404).json({
        success: false,
        message: 'Knowledge share not found',
      });
    }

    Object.assign(knowledge, req.body);
    await knowledge.save();

    res.status(200).json({
      success: true,
      data: knowledge,
    });
  } catch (error) {
    logger.error(`Update knowledge share error: ${error.message}`);
    next(error);
  }
};

exports.deleteKnowledgeShare = async (req, res, next) => {
  try {
    await KnowledgeShare.findByIdAndDelete(req.params.id);
    res.status(200).json({
      success: true,
      message: 'Knowledge share deleted successfully',
    });
  } catch (error) {
    logger.error(`Delete knowledge share error: ${error.message}`);
    next(error);
  }
};

// ============ GOAL TRACKER CONTROLLERS ============

exports.createGoal = async (req, res, next) => {
  try {
    const goal = await GoalTracker.create({
      ...req.body,
      user: req.user._id,
    });

    res.status(201).json({
      success: true,
      data: goal,
    });
  } catch (error) {
    logger.error(`Create goal error: ${error.message}`);
    next(error);
  }
};

exports.getGoals = async (req, res, next) => {
  try {
    const goals = await GoalTracker.find({ user: req.user._id })
      .sort({ priority: -1, createdAt: -1 });

    res.status(200).json({
      success: true,
      data: goals,
    });
  } catch (error) {
    logger.error(`Get goals error: ${error.message}`);
    next(error);
  }
};

exports.getGoalById = async (req, res, next) => {
  try {
    const goal = await GoalTracker.findOne({
      _id: req.params.id,
      user: req.user._id,
    });

    if (!goal) {
      return res.status(404).json({
        success: false,
        message: 'Goal not found',
      });
    }

    res.status(200).json({
      success: true,
      data: goal,
    });
  } catch (error) {
    logger.error(`Get goal by id error: ${error.message}`);
    next(error);
  }
};

exports.updateGoal = async (req, res, next) => {
  try {
    const goal = await GoalTracker.findOne({
      _id: req.params.id,
      user: req.user._id,
    });

    if (!goal) {
      return res.status(404).json({
        success: false,
        message: 'Goal not found',
      });
    }

    Object.assign(goal, req.body);
    await goal.save();

    res.status(200).json({
      success: true,
      data: goal,
    });
  } catch (error) {
    logger.error(`Update goal error: ${error.message}`);
    next(error);
  }
};

exports.addGoalMilestone = async (req, res, next) => {
  try {
    const goal = await GoalTracker.findOne({
      _id: req.params.id,
      user: req.user._id,
    });

    if (!goal) {
      return res.status(404).json({
        success: false,
        message: 'Goal not found',
      });
    }

    goal.milestones.push(req.body);
    await goal.save();

    res.status(200).json({
      success: true,
      data: goal,
    });
  } catch (error) {
    logger.error(`Add goal milestone error: ${error.message}`);
    next(error);
  }
};

exports.deleteGoal = async (req, res, next) => {
  try {
    await GoalTracker.findOneAndDelete({
      _id: req.params.id,
      user: req.user._id,
    });

    res.status(200).json({
      success: true,
      message: 'Goal deleted successfully',
    });
  } catch (error) {
    logger.error(`Delete goal error: ${error.message}`);
    next(error);
  }
};