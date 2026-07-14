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
    console.log('📝 Request body:', JSON.stringify(req.body, null, 2));

    // Validate required fields
    if (!title) {
      return res.status(400).json({
        success: false,
        message: 'Title is required',
      });
    }

    if (!description) {
      return res.status(400).json({
        success: false,
        message: 'Description is required',
      });
    }

    if (!startDate) {
      return res.status(400).json({
        success: false,
        message: 'Start date is required',
      });
    }

    if (!endDate) {
      return res.status(400).json({
        success: false,
        message: 'End date is required',
      });
    }

    // Build location object
    const locationObj = {};
    if (location) {
      if (location.venue) locationObj.venue = location.venue;
      if (location.address) locationObj.address = location.address;
      if (location.city) locationObj.city = location.city;
      if (location.country) locationObj.country = location.country;
      if (location.coordinates) {
        locationObj.coordinates = {
          lat: location.coordinates.lat || 0,
          lng: location.coordinates.lng || 0,
        };
      }
    }

    // Create event
    const eventData = {
      title: title.trim(),
      description: description.trim(),
      banner: banner || '',
      startDate: new Date(startDate),
      endDate: new Date(endDate),
      location: locationObj,
      categories: categories || [],
      maxAttendees: maxAttendees || 0,
      registrationDeadline: registrationDeadline ? new Date(registrationDeadline) : null,
      ticketPrice: ticketPrice || 0,
      isPublic: isPublic !== undefined ? isPublic : true,
      organizer: req.user._id,
      status: 'published',
    };

    console.log('📝 Event data:', JSON.stringify(eventData, null, 2));

    const event = await Event.create(eventData);

    console.log('✅ Event created:', event.id, event.title);

    res.status(201).json({
      success: true,
      message: 'Event created successfully',
      data: event,
    });
  } catch (error) {
    console.error('❌ Create event error:', error);
    console.error('❌ Error stack:', error.stack);
    
    // Handle validation errors
    if (error.name === 'ValidationError') {
      const errors = Object.values(error.errors).map(err => ({
        field: err.path,
        message: err.message
      }));
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors,
      });
    }
    
    next(error);
  }
};

// ============ GET ALL EVENTS ============
exports.getAllEvents = async (req, res, next) => {
  try {
    const { status, search, page = 1, limit = 10 } = req.query;

    const query = {};
    if (status) query.status = status;
    if (search && search.trim()) {
      query.$or = [
        { title: { $regex: search.trim(), $options: 'i' } },
        { description: { $regex: search.trim(), $options: 'i' } },
      ];
    }
    // Only show public events to non-organizers
    if (!req.user || req.user.role !== 'organizer') {
      query.isPublic = true;
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);

    const events = await Event.find(query)
      .skip(skip)
      .limit(parseInt(limit))
      .populate('organizer', 'firstName lastName email')
      .sort({ startDate: 1 });

    const total = await Event.countDocuments(query);

    // Convert to plain objects with id
    const eventsWithId = events.map(event => event.toJSON());

    res.status(200).json({
      success: true,
      data: eventsWithId,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / parseInt(limit)),
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
      data: event.toJSON(),
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

    // Check if user is organizer or admin
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
        } else if (key === 'location' && typeof updates[key] === 'object') {
          const loc = updates[key];
          if (loc.venue) event.location.venue = loc.venue;
          if (loc.address) event.location.address = loc.address;
          if (loc.city) event.location.city = loc.city;
          if (loc.country) event.location.country = loc.country;
        } else {
          event[key] = updates[key];
        }
      }
    });

    await event.save();

    res.status(200).json({
      success: true,
      message: 'Event updated successfully',
      data: event.toJSON(),
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

// ============ GET MY EVENTS ============
exports.getMyEvents = async (req, res, next) => {
  try {
    const events = await Event.find({ organizer: req.user._id })
      .sort({ createdAt: -1 });

    const eventsWithId = events.map(event => event.toJSON());

    res.status(200).json({
      success: true,
      data: eventsWithId,
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