const Event = require('../models/Event');
const User = require('../models/User');
const QRCode = require('qrcode');
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
      title: title.trim(),
      description: description.trim(),
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
      registeredUsers: [],
      registeredCount: 0,
    });

    console.log('✅ Event created:', event._id);

    // Return event with id as string
    const eventData = {
      id: event._id.toString(),
      title: event.title,
      description: event.description,
      banner: event.banner,
      startDate: event.startDate,
      endDate: event.endDate,
      location: event.location,
      categories: event.categories,
      maxAttendees: event.maxAttendees,
      ticketPrice: event.ticketPrice,
      isPublic: event.isPublic,
      status: event.status,
      organizer: event.organizer,
      registeredCount: event.registeredCount,
      registeredUsers: event.registeredUsers,
      createdAt: event.createdAt,
    };

    res.status(201).json({
      success: true,
      message: 'Event created successfully',
      data: eventData,
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
    if (search && search.trim()) {
      query.$or = [
        { title: { $regex: search.trim(), $options: 'i' } },
        { description: { $regex: search.trim(), $options: 'i' } },
      ];
    }

    const events = await Event.find(query)
      .skip((parseInt(page) - 1) * parseInt(limit))
      .limit(parseInt(limit))
      .populate('organizer', 'firstName lastName email')
      .sort({ startDate: 1 });

    const total = await Event.countDocuments(query);

    // Convert events to include id as string
    const eventsWithId = events.map(event => ({
      id: event._id.toString(),
      title: event.title,
      description: event.description,
      banner: event.banner,
      startDate: event.startDate,
      endDate: event.endDate,
      location: event.location,
      categories: event.categories,
      maxAttendees: event.maxAttendees,
      ticketPrice: event.ticketPrice,
      isPublic: event.isPublic,
      status: event.status,
      organizer: event.organizer,
      registeredCount: event.registeredCount,
      registeredUsers: event.registeredUsers,
      createdAt: event.createdAt,
    }));

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

    const eventData = {
      id: event._id.toString(),
      title: event.title,
      description: event.description,
      banner: event.banner,
      startDate: event.startDate,
      endDate: event.endDate,
      location: event.location,
      categories: event.categories,
      maxAttendees: event.maxAttendees,
      ticketPrice: event.ticketPrice,
      isPublic: event.isPublic,
      status: event.status,
      organizer: event.organizer,
      registeredCount: event.registeredCount,
      registeredUsers: event.registeredUsers,
      createdAt: event.createdAt,
    };

    res.status(200).json({
      success: true,
      data: eventData,
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

    const eventData = {
      id: event._id.toString(),
      title: event.title,
      description: event.description,
      banner: event.banner,
      startDate: event.startDate,
      endDate: event.endDate,
      location: event.location,
      categories: event.categories,
      maxAttendees: event.maxAttendees,
      ticketPrice: event.ticketPrice,
      isPublic: event.isPublic,
      status: event.status,
      organizer: event.organizer,
      registeredCount: event.registeredCount,
      registeredUsers: event.registeredUsers,
      createdAt: event.createdAt,
    };

    res.status(200).json({
      success: true,
      message: 'Event updated successfully',
      data: eventData,
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

// ============ GET MY EVENTS (Organizer) ============
exports.getMyEvents = async (req, res, next) => {
  try {
    const events = await Event.find({ organizer: req.user._id })
      .sort({ createdAt: -1 });

    const eventsWithId = events.map(event => ({
      id: event._id.toString(),
      title: event.title,
      description: event.description,
      banner: event.banner,
      startDate: event.startDate,
      endDate: event.endDate,
      location: event.location,
      categories: event.categories,
      maxAttendees: event.maxAttendees,
      ticketPrice: event.ticketPrice,
      isPublic: event.isPublic,
      status: event.status,
      organizer: event.organizer,
      registeredCount: event.registeredCount,
      registeredUsers: event.registeredUsers,
      createdAt: event.createdAt,
    }));

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
    console.log('🔵 ===== REGISTER FOR EVENT STARTED =====');
    
    const eventId = req.params.id;
    const userId = req.user._id;
    const userIdString = userId.toString();

    console.log('📝 Event ID:', eventId);
    console.log('📝 User ID:', userIdString);

    const event = await Event.findById(eventId);
    if (!event) {
      console.log('❌ Event not found');
      return res.status(404).json({
        success: false,
        message: 'Event not found',
      });
    }

    console.log('📝 Event found:', event.title);

    if (event.registeredUsers && event.registeredUsers.some(id => id.toString() === userIdString)) {
      console.log('⚠️ User already registered');
      return res.status(400).json({
        success: false,
        message: 'You are already registered for this event',
      });
    }

    if (!event.registeredUsers) {
      event.registeredUsers = [];
    }

    event.registeredUsers.push(userId);
    event.registeredCount = (event.registeredCount || 0) + 1;
    await event.save();

    console.log('✅ User registered successfully!');
    console.log('📝 Total registered count:', event.registeredCount);

    res.status(200).json({
      success: true,
      message: 'Registered for event successfully',
      data: {
        eventId: event._id.toString(),
        eventTitle: event.title,
        registered: true,
        registeredCount: event.registeredCount,
      },
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

    const userId = req.user._id.toString();

    if (!event.registeredUsers || !event.registeredUsers.some(id => id.toString() === userId)) {
      return res.status(400).json({
        success: false,
        message: 'You are not registered for this event',
      });
    }

    event.registeredUsers = event.registeredUsers.filter(id => id.toString() !== userId);
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

// ============ CHECK REGISTRATION STATUS ============
exports.checkRegistrationStatus = async (req, res, next) => {
  try {
    const { eventId } = req.params;
    const userId = req.user._id.toString();

    console.log('🔍 ===== CHECKING REGISTRATION STATUS =====');
    console.log('📝 User ID:', userId);
    console.log('📝 Event ID:', eventId);

    const event = await Event.findById(eventId);
    if (!event) {
      console.log('❌ Event not found');
      return res.status(404).json({
        success: false,
        message: 'Event not found',
      });
    }

    console.log('📝 Event found:', event.title);

    const isRegistered = event.registeredUsers && event.registeredUsers.some(id => id.toString() === userId);

    console.log('📝 Is registered:', isRegistered);

    res.status(200).json({
      success: true,
      data: {
        isRegistered: isRegistered,
        eventId: event._id.toString(),
        eventTitle: event.title,
        registeredCount: event.registeredCount,
      },
    });
  } catch (error) {
    console.error('❌ Check registration error:', error);
    next(error);
  }
};

// ============ GENERATE ENTRY QR CODE ============
exports.generateEntryQR = async (req, res, next) => {
  try {
    const { eventId } = req.params;
    const userId = req.user._id;
    const userIdString = userId.toString();

    console.log('🔍 ===== GENERATING QR CODE =====');
    console.log('📝 User ID:', userIdString);
    console.log('📝 Event ID:', eventId);

    if (!eventId) {
      console.log('❌ Event ID is undefined or null');
      return res.status(400).json({
        success: false,
        message: 'Event ID is required',
      });
    }

    const event = await Event.findById(eventId);
    if (!event) {
      console.log('❌ Event not found for ID:', eventId);
      return res.status(404).json({
        success: false,
        message: 'Event not found. Please make sure the event exists.',
      });
    }

    console.log('📝 Event found:', event.title);
    console.log('📝 Registered users:', event.registeredUsers);

    const isRegistered = event.registeredUsers && event.registeredUsers.some(id => id.toString() === userIdString);
    
    if (!isRegistered) {
      console.log('❌ User not registered for this event');
      return res.status(403).json({
        success: false,
        message: 'You are not registered for this event. Please register first.',
      });
    }

    console.log('✅ User is registered, generating QR...');

    const qrData = JSON.stringify({
      type: 'event_entry',
      eventId: event._id.toString(),
      userId: userIdString,
      eventTitle: event.title,
      userName: `${req.user.firstName} ${req.user.lastName}`,
      timestamp: Date.now(),
    });

    const qrCode = await QRCode.toDataURL(qrData, {
      errorCorrectionLevel: 'H',
      width: 400,
      margin: 4,
      color: {
        dark: '#2563EB',
        light: '#FFFFFF',
      },
    });

    console.log('✅ QR code generated successfully');

    res.status(200).json({
      success: true,
      message: 'QR code generated successfully',
      data: {
        qrCode: qrCode,
        eventId: event._id.toString(),
        eventTitle: event.title,
        userName: `${req.user.firstName} ${req.user.lastName}`,
        registeredCount: event.registeredCount,
      },
    });
  } catch (error) {
    console.error('❌ Generate QR error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to generate QR code',
      error: error.message,
    });
  }
};

// ============ VERIFY QR CODE FOR ENTRY ============
exports.verifyEntryQR = async (req, res, next) => {
  try {
    const { qrData } = req.body;

    if (!qrData) {
      return res.status(400).json({
        success: false,
        message: 'QR data is required',
      });
    }

    let data;
    try {
      data = JSON.parse(qrData);
    } catch (e) {
      return res.status(400).json({
        success: false,
        message: 'Invalid QR code format',
      });
    }

    if (data.type !== 'event_entry') {
      return res.status(400).json({
        success: false,
        message: 'Invalid QR code type',
      });
    }

    const event = await Event.findById(data.eventId);
    if (!event) {
      return res.status(404).json({
        success: false,
        message: 'Event not found',
      });
    }

    const user = await User.findById(data.userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    if (!event.registeredUsers || !event.registeredUsers.some(id => id.toString() === data.userId)) {
      return res.status(403).json({
        success: false,
        message: 'User is not registered for this event',
      });
    }

    const qrTime = data.timestamp;
    const currentTime = Date.now();
    const hoursDiff = (currentTime - qrTime) / (1000 * 60 * 60);
    if (hoursDiff > 24) {
      return res.status(400).json({
        success: false,
        message: 'QR code has expired. Please generate a new one.',
      });
    }

    res.status(200).json({
      success: true,
      message: 'QR code verified successfully',
      data: {
        event: {
          id: event._id.toString(),
          title: event.title,
        },
        user: {
          id: user._id.toString(),
          name: `${user.firstName} ${user.lastName}`,
          email: user.email,
        },
        verified: true,
        timestamp: new Date(),
      },
    });
  } catch (error) {
    console.error('❌ Verify QR error:', error);
    res.status(400).json({
      success: false,
      message: 'Invalid QR code data',
    });
  }
};

// ============ GET MY REGISTERED EVENTS ============
exports.getMyRegisteredEvents = async (req, res, next) => {
  try {
    const userId = req.user._id.toString();
    
    console.log('🔍 ===== GETTING MY REGISTERED EVENTS =====');
    console.log('📝 User ID:', userId);

    const events = await Event.find({
      registeredUsers: { $in: [userId] }
    }).populate('organizer', 'firstName lastName email');

    console.log('📝 Found', events.length, 'registered events');

    const eventsWithId = events.map(event => ({
      id: event._id.toString(),
      title: event.title,
      description: event.description,
      banner: event.banner,
      startDate: event.startDate,
      endDate: event.endDate,
      location: event.location,
      categories: event.categories,
      maxAttendees: event.maxAttendees,
      ticketPrice: event.ticketPrice,
      isPublic: event.isPublic,
      status: event.status,
      organizer: event.organizer,
      registeredCount: event.registeredCount,
      registeredUsers: event.registeredUsers,
      createdAt: event.createdAt,
    }));

    res.status(200).json({
      success: true,
      data: eventsWithId,
    });
  } catch (error) {
    console.error('❌ Get registered events error:', error);
    next(error);
  }
};