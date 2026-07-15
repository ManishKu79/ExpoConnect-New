const User = require('../models/User');
const Event = require('../models/Event');
const Company = require('../models/Company');
const Lead = require('../models/Lead');
const Notification = require('../models/Notification');
const logger = require('../utils/logger');

// ============ GET SYSTEM STATS ============
exports.getSystemStats = async (req, res, next) => {
  try {
    console.log('📊 Getting system stats for admin');

    const totalUsers = await User.countDocuments();
    const totalEvents = await Event.countDocuments();
    const totalCompanies = await Company.countDocuments();
    const totalLeads = await Lead.countDocuments();
    const totalNotifications = await Notification.countDocuments();

    // Role distribution
    const roleDistribution = await User.aggregate([
      { $group: { _id: '$role', count: { $sum: 1 } } }
    ]);

    // Event status distribution
    const eventStatus = await Event.aggregate([
      { $group: { _id: '$status', count: { $sum: 1 } } }
    ]);

    // Recent registrations (last 7 days)
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

    const recentUsers = await User.countDocuments({
      createdAt: { $gte: sevenDaysAgo }
    });

    const recentEvents = await Event.countDocuments({
      createdAt: { $gte: sevenDaysAgo }
    });

    res.status(200).json({
      success: true,
      data: {
        totalUsers,
        totalEvents,
        totalCompanies,
        totalLeads,
        totalNotifications,
        recentUsers,
        recentEvents,
        roleDistribution,
        eventStatus,
        generatedAt: new Date(),
      },
    });
  } catch (error) {
    console.error('❌ Get system stats error:', error);
    next(error);
  }
};

// ============ GET ALL USERS ============
exports.getAllUsers = async (req, res, next) => {
  try {
    const { page = 1, limit = 20, role, search, status } = req.query;

    const query = {};
    if (role) query.role = role;
    if (status) query.isActive = status === 'active';
    if (search) {
      query.$or = [
        { firstName: { $regex: search, $options: 'i' } },
        { lastName: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } },
      ];
    }

    const users = await User.find(query)
      .skip((parseInt(page) - 1) * parseInt(limit))
      .limit(parseInt(limit))
      .sort({ createdAt: -1 })
      .populate('company', 'name logo');

    const total = await User.countDocuments(query);

    res.status(200).json({
      success: true,
      data: users,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / parseInt(limit)),
      },
    });
  } catch (error) {
    console.error('❌ Get all users error:', error);
    next(error);
  }
};

// ============ GET ALL EVENTS ============
exports.getAllEvents = async (req, res, next) => {
  try {
    const { page = 1, limit = 20, status, search } = req.query;

    const query = {};
    if (status) query.status = status;
    if (search) {
      query.$or = [
        { title: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
      ];
    }

    const events = await Event.find(query)
      .skip((parseInt(page) - 1) * parseInt(limit))
      .limit(parseInt(limit))
      .sort({ createdAt: -1 })
      .populate('organizer', 'firstName lastName email');

    const total = await Event.countDocuments(query);

    res.status(200).json({
      success: true,
      data: events,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / parseInt(limit)),
      },
    });
  } catch (error) {
    console.error('❌ Get all events error:', error);
    next(error);
  }
};

// ============ GET ALL LEADS ============
exports.getAllLeads = async (req, res, next) => {
  try {
    const { page = 1, limit = 20, status, eventId } = req.query;

    const query = {};
    if (status) query.status = status;
    if (eventId) query.event = eventId;

    const leads = await Lead.find(query)
      .skip((parseInt(page) - 1) * parseInt(limit))
      .limit(parseInt(limit))
      .sort({ createdAt: -1 })
      .populate('visitor', 'firstName lastName email')
      .populate('event', 'title')
      .populate('exhibitor', 'name');

    const total = await Lead.countDocuments(query);

    res.status(200).json({
      success: true,
      data: leads,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / parseInt(limit)),
      },
    });
  } catch (error) {
    console.error('❌ Get all leads error:', error);
    next(error);
  }
};

// ============ UPDATE USER ============
exports.updateUser = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { role, isActive, firstName, lastName, phone } = req.body;

    const user = await User.findById(id);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    if (role) user.role = role;
    if (isActive !== undefined) user.isActive = isActive;
    if (firstName) user.firstName = firstName;
    if (lastName) user.lastName = lastName;
    if (phone) user.phone = phone;

    await user.save();

    res.status(200).json({
      success: true,
      message: 'User updated successfully',
      data: user,
    });
  } catch (error) {
    console.error('❌ Update user error:', error);
    next(error);
  }
};

// ============ DELETE USER ============
exports.deleteUser = async (req, res, next) => {
  try {
    const { id } = req.params;

    const user = await User.findById(id);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    await user.deleteOne();

    res.status(200).json({
      success: true,
      message: 'User deleted successfully',
    });
  } catch (error) {
    console.error('❌ Delete user error:', error);
    next(error);
  }
};

// ============ UPDATE EVENT ============
exports.updateEvent = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { status, isPublic, maxAttendees } = req.body;

    const event = await Event.findById(id);
    if (!event) {
      return res.status(404).json({
        success: false,
        message: 'Event not found',
      });
    }

    if (status) event.status = status;
    if (isPublic !== undefined) event.isPublic = isPublic;
    if (maxAttendees) event.maxAttendees = maxAttendees;

    await event.save();

    res.status(200).json({
      success: true,
      message: 'Event updated successfully',
      data: event,
    });
  } catch (error) {
    console.error('❌ Update event error:', error);
    next(error);
  }
};

// ============ DELETE EVENT ============
exports.deleteEvent = async (req, res, next) => {
  try {
    const { id } = req.params;

    const event = await Event.findById(id);
    if (!event) {
      return res.status(404).json({
        success: false,
        message: 'Event not found',
      });
    }

    await event.deleteOne();

    res.status(200).json({
      success: true,
      message: 'Event deleted successfully',
    });
  } catch (error) {
    console.error('❌ Delete event error:', error);
    next(error);
  }
};

// ============ GET RECENT ACTIVITY ============
exports.getRecentActivity = async (req, res, next) => {
  try {
    const limit = parseInt(req.query.limit) || 10;

    // Get recent user registrations
    const recentUsers = await User.find()
      .sort({ createdAt: -1 })
      .limit(limit)
      .select('firstName lastName email role createdAt');

    // Get recent events
    const recentEvents = await Event.find()
      .sort({ createdAt: -1 })
      .limit(limit)
      .select('title status createdAt organizer')
      .populate('organizer', 'firstName lastName');

    // Get recent leads
    const recentLeads = await Lead.find()
      .sort({ createdAt: -1 })
      .limit(limit)
      .select('visitor event status createdAt')
      .populate('visitor', 'firstName lastName email')
      .populate('event', 'title');

    // Combine and sort all activities
    const activities = [];

    recentUsers.forEach(user => {
      activities.push({
        type: 'user_registered',
        user: `${user.firstName} ${user.lastName}`,
        email: user.email,
        role: user.role,
        timestamp: user.createdAt,
        icon: 'person_add',
        color: '#2563EB',
      });
    });

    recentEvents.forEach(event => {
      activities.push({
        type: 'event_created',
        title: event.title,
        organizer: event.organizer ? `${event.organizer.firstName} ${event.organizer.lastName}` : 'Unknown',
        status: event.status,
        timestamp: event.createdAt,
        icon: 'event',
        color: '#7C3AED',
      });
    });

    recentLeads.forEach(lead => {
      const visitor = lead.visitor || {};
      activities.push({
        type: 'lead_created',
        visitor: `${visitor.firstName || ''} ${visitor.lastName || ''}`.trim() || 'Unknown',
        event: lead.event?.title || 'Unknown Event',
        status: lead.status,
        timestamp: lead.createdAt,
        icon: 'people',
        color: '#10B981',
      });
    });

    // Sort by timestamp descending
    activities.sort((a, b) => b.timestamp - a.timestamp);

    res.status(200).json({
      success: true,
      data: activities.slice(0, limit),
    });
  } catch (error) {
    console.error('❌ Get recent activity error:', error);
    next(error);
  }
};