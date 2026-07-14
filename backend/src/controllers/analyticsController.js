const Event = require('../models/Event');
const User = require('../models/User');
const Analytics = require('../models/Analytics');
const logger = require('../utils/logger');

// ============ GET EVENT ANALYTICS ============
exports.getEventAnalytics = async (req, res, next) => {
  try {
    const { eventId } = req.params;
    
    console.log('📊 Getting analytics for event:', eventId);

    const event = await Event.findById(eventId);
    if (!event) {
      return res.status(404).json({
        success: false,
        message: 'Event not found',
      });
    }

    // Check if user is organizer or admin
    if (event.organizer.toString() !== req.user._id.toString() && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'You do not have permission to view this event\'s analytics',
      });
    }

    // Get registered users details
    const registeredUsers = await User.find({
      _id: { $in: event.registeredUsers || [] }
    }).select('firstName lastName email profilePicture createdAt');

    // Calculate metrics
    const totalRegistrations = event.registeredUsers?.length || 0;
    const totalCapacity = event.maxAttendees || 0;
    const capacityPercentage = totalCapacity > 0 ? (totalRegistrations / totalCapacity) * 100 : 0;

    // Get recent registrations (last 7 days)
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    
    const recentRegistrations = registeredUsers.filter(user => 
      user.createdAt >= sevenDaysAgo
    );

    // Get registration trends (daily for last 7 days)
    const registrationTrend = [];
    for (let i = 6; i >= 0; i--) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      date.setHours(0, 0, 0, 0);
      
      const nextDate = new Date(date);
      nextDate.setDate(nextDate.getDate() + 1);
      
      const count = registeredUsers.filter(user => {
        const userDate = new Date(user.createdAt);
        return userDate >= date && userDate < nextDate;
      }).length;
      
      registrationTrend.push({
        date: date.toISOString().split('T')[0],
        count: count,
      });
    }

    const analytics = {
      event: {
        id: event._id.toString(),
        title: event.title,
        description: event.description,
        startDate: event.startDate,
        endDate: event.endDate,
        status: event.status,
      },
      registrations: {
        total: totalRegistrations,
        capacity: totalCapacity,
        capacityPercentage: Math.round(capacityPercentage),
        recent: recentRegistrations.length,
        trend: registrationTrend,
      },
      attendees: {
        total: totalRegistrations,
        list: registeredUsers.map(user => ({
          id: user._id.toString(),
          name: `${user.firstName} ${user.lastName}`,
          email: user.email,
          profilePicture: user.profilePicture,
          registeredAt: user.createdAt,
        })),
      },
      engagement: {
        registeredCount: totalRegistrations,
        // Placeholder for future engagement metrics
        checkIns: 0,
        checkInRate: 0,
      },
      generatedAt: new Date(),
    };

    res.status(200).json({
      success: true,
      data: analytics,
    });
  } catch (error) {
    console.error('❌ Get event analytics error:', error);
    next(error);
  }
};

// ============ GET ALL EVENTS ANALYTICS ============
exports.getAllEventsAnalytics = async (req, res, next) => {
  try {
    console.log('📊 Getting all events analytics for user:', req.user._id);

    const events = await Event.find({ organizer: req.user._id });

    const analytics = events.map(event => ({
      id: event._id.toString(),
      title: event.title,
      startDate: event.startDate,
      endDate: event.endDate,
      status: event.status,
      registrations: event.registeredUsers?.length || 0,
      capacity: event.maxAttendees || 0,
      capacityPercentage: event.maxAttendees > 0 
        ? Math.round(((event.registeredUsers?.length || 0) / event.maxAttendees) * 100) 
        : 0,
    }));

    const summary = {
      totalEvents: events.length,
      totalRegistrations: events.reduce((sum, e) => sum + (e.registeredUsers?.length || 0), 0),
      totalCapacity: events.reduce((sum, e) => sum + (e.maxAttendees || 0), 0),
      publishedEvents: events.filter(e => e.status === 'published').length,
      completedEvents: events.filter(e => e.status === 'completed').length,
      ongoingEvents: events.filter(e => e.status === 'ongoing').length,
    };

    res.status(200).json({
      success: true,
      data: {
        summary,
        events: analytics,
      },
    });
  } catch (error) {
    console.error('❌ Get all events analytics error:', error);
    next(error);
  }
};

// ============ GET ORGANIZER DASHBOARD STATS ============
exports.getOrganizerStats = async (req, res, next) => {
  try {
    console.log('📊 Getting organizer stats for user:', req.user._id);

    const events = await Event.find({ organizer: req.user._id });

    const totalEvents = events.length;
    const totalRegistrations = events.reduce((sum, e) => sum + (e.registeredUsers?.length || 0), 0);
    const totalCapacity = events.reduce((sum, e) => sum + (e.maxAttendees || 0), 0);
    
    const publishedEvents = events.filter(e => e.status === 'published').length;
    const completedEvents = events.filter(e => e.status === 'completed').length;
    const ongoingEvents = events.filter(e => e.status === 'ongoing').length;

    // Get upcoming events (next 30 days)
    const thirtyDaysFromNow = new Date();
    thirtyDaysFromNow.setDate(thirtyDaysFromNow.getDate() + 30);
    
    const upcomingEvents = events.filter(e => 
      e.startDate >= new Date() && 
      e.startDate <= thirtyDaysFromNow &&
      e.status !== 'completed' &&
      e.status !== 'cancelled'
    ).length;

    // Get most popular event
    const mostPopular = events.length > 0 
      ? events.reduce((max, e) => (e.registeredUsers?.length || 0) > (max.registeredUsers?.length || 0) ? e : max)
      : null;

    res.status(200).json({
      success: true,
      data: {
        totalEvents,
        totalRegistrations,
        totalCapacity,
        publishedEvents,
        completedEvents,
        ongoingEvents,
        upcomingEvents,
        mostPopular: mostPopular ? {
          id: mostPopular._id.toString(),
          title: mostPopular.title,
          registrations: mostPopular.registeredUsers?.length || 0,
        } : null,
        events: events.map(e => ({
          id: e._id.toString(),
          title: e.title,
          registrations: e.registeredUsers?.length || 0,
          capacity: e.maxAttendees || 0,
          status: e.status,
          startDate: e.startDate,
        })),
      },
    });
  } catch (error) {
    console.error('❌ Get organizer stats error:', error);
    next(error);
  }
};