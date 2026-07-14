const Event = require('../models/Event');
const logger = require('../utils/logger');

// ============ CREATE EVENT ============
exports.createEvent = async (req, res, next) => {
  try {
    const {
      title,
      description,
      banner,
      startDate,
      endDate,
      location,
      categories,
      maxAttendees,
      registrationDeadline,
      ticketPrice,
      isPublic,
    } = req.body;

    console.log('📝 Creating event:', title);

    if (!title || !description) {
      return res.status(400).json({
        success: false,
        message: 'Title and description are required',
      });
    }

    if (!startDate || !endDate) {
      return res.status(400).json({
        success: false,
        message: 'Start date and end date are required',
      });
    }

    const event = await Event.create({
      title,
      description,
      banner: banner || '',
      startDate: new Date(startDate),
      endDate: new Date(endDate),
      location: location || {},
      categories: categories || [],
      maxAttendees: maxAttendees || 0,
      registrationDeadline: registrationDeadline ? new Date(registrationDeadline) : null,
      ticketPrice: ticketPrice || 0,
      isPublic: isPublic !== undefined ? isPublic : true,
      organizer: req.user._id,
      status: 'published',
    });

    console.log('✅ Event created:', event._id);

    res.status(201).json({
      success: true,
      message: 'Event created successfully',
      data: event,
    });
  } catch (error) {
    console.error('❌ Create event error:', error);
    next(error);
  }
};

// ============ GET ALL EVENTS ============
exports.getAllEvents = async (req, res, next) => {
  try {
    const { status, search, page = 1, limit = 10 } = req.query;

    const query = {};
    if (status) query.status = status;
    if (search) {
      query.$or = [
        { title: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
      ];
    }

    const events = await Event.find(query)
      .skip((page - 1) * limit)
      .limit(parseInt(limit))
      .populate('organizer', 'firstName lastName email')
      .sort({ startDate: 1 });

    const total = await Event.countDocuments(query);

    res.status(200).json({
      success: true,
      data: events,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    console.error('❌ Get events error:', error);
    next(error);
  }
};

// ============ GET EVENT BY ID ============
exports.getEventById = async (req, res, next) => {
  try {
    const event = await Event.findById(req.params.id)
      .populate('organizer', 'firstName lastName email');

    if (!event) {
      return res.status(404).json({
        success: false,
        message: 'Event not found',
      });
    }

    res.status(200).json({
      success: true,
      data: event,
    });
  } catch (error) {
    console.error('❌ Get event by id error:', error);
    next(error);
  }
};

// ============ UPDATE EVENT ============
exports.updateEvent = async (req, res, next) => {
  try {
    const event = await Event.findById(req.params.id);
    if (!event) {
      return res.status(404).json({
        success: false,
        message: 'Event not found',
      });
    }

    if (event.organizer.toString() !== req.user._id.toString() && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'You do not have permission to update this event',
      });
    }

    const updates = req.body;
    const allowedUpdates = [
      'title', 'description', 'banner', 'startDate', 'endDate',
      'location', 'categories', 'maxAttendees', 'registrationDeadline',
      'ticketPrice', 'isPublic', 'status'
    ];

    allowedUpdates.forEach(key => {
      if (updates[key] !== undefined) {
        if (key === 'startDate' || key === 'endDate' || key === 'registrationDeadline') {
          event[key] = new Date(updates[key]);
        } else {
          event[key] = updates[key];
        }
      }
    });

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
    const event = await Event.findById(req.params.id);
    if (!event) {
      return res.status(404).json({
        success: false,
        message: 'Event not found',
      });
    }

    if (event.organizer.toString() !== req.user._id.toString() && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'You do not have permission to delete this event',
      });
    }

    await event.remove();

    res.status(200).json({
      success: true,
      message: 'Event deleted successfully',
    });
  } catch (error) {
    console.error('❌ Delete event error:', error);
    next(error);
  }
};

// ============ GET MY EVENTS ============
exports.getMyEvents = async (req, res, next) => {
  try {
    const events = await Event.find({ organizer: req.user._id })
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      data: events,
    });
  } catch (error) {
    console.error('❌ Get my events error:', error);
    next(error);
  }
};

// ============ REGISTER FOR EVENT ============
exports.registerForEvent = async (req, res, next) => {
  try {
    const event = await Event.findById(req.params.id);
    if (!event) {
      return res.status(404).json({
        success: false,
        message: 'Event not found',
      });
    }

    event.registeredCount = (event.registeredCount || 0) + 1;
    await event.save();

    res.status(200).json({
      success: true,
      message: 'Registered for event successfully',
    });
  } catch (error) {
    console.error('❌ Register for event error:', error);
    next(error);
  }
};

// ============ UNREGISTER FROM EVENT ============
exports.unregisterFromEvent = async (req, res, next) => {
  try {
    const event = await Event.findById(req.params.id);
    if (!event) {
      return res.status(404).json({
        success: false,
        message: 'Event not found',
      });
    }

    event.registeredCount = Math.max(0, (event.registeredCount || 0) - 1);
    await event.save();

    res.status(200).json({
      success: true,
      message: 'Unregistered from event successfully',
    });
  } catch (error) {
    console.error('❌ Unregister from event error:', error);
    next(error);
  }
};