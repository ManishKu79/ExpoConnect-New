const Event = require('../models/Event');
const Hall = require('../models/Hall');
const Stall = require('../models/Stall');
const uploadService = require('../services/uploadService');
const logger = require('../utils/logger');

exports.createEvent = async (req, res, next) => {
  try {
    const {
      title,
      description,
      startDate,
      endDate,
      location,
      categories,
      maxAttendees,
      registrationDeadline,
      ticketPrice,
      isPublic,
    } = req.body;

    const event = await Event.create({
      title,
      description,
      organizer: req.user._id,
      startDate,
      endDate,
      location,
      categories,
      maxAttendees,
      registrationDeadline,
      ticketPrice,
      isPublic,
    });

    res.status(201).json({
      success: true,
      message: 'Event created successfully',
      data: event,
    });
  } catch (error) {
    logger.error(`Create event error: ${error.message}`);
    next(error);
  }
};

exports.getAllEvents = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    const query = {};
    if (req.query.status) query.status = req.query.status;
    if (req.query.isPublic !== undefined) query.isPublic = req.query.isPublic === 'true';
    if (req.query.organizer) query.organizer = req.query.organizer;
    if (req.query.search) {
      query.$or = [
        { title: { $regex: req.query.search, $options: 'i' } },
        { description: { $regex: req.query.search, $options: 'i' } },
      ];
    }

    const events = await Event.find(query)
      .skip(skip)
      .limit(limit)
      .populate('organizer', 'firstName lastName email')
      .sort({ startDate: 1 });

    const total = await Event.countDocuments(query);

    res.status(200).json({
      success: true,
      data: events,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    logger.error(`Get all events error: ${error.message}`);
    next(error);
  }
};

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
    logger.error(`Get event by id error: ${error.message}`);
    next(error);
  }
};

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
    if (
      event.organizer.toString() !== req.user._id.toString() &&
      req.user.role !== 'admin'
    ) {
      return res.status(403).json({
        success: false,
        message: 'You do not have permission to update this event',
      });
    }

    const updates = req.body;
    Object.keys(updates).forEach(key => {
      event[key] = updates[key];
    });

    await event.save();

    res.status(200).json({
      success: true,
      message: 'Event updated successfully',
      data: event,
    });
  } catch (error) {
    logger.error(`Update event error: ${error.message}`);
    next(error);
  }
};

exports.uploadBanner = async (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Banner file is required',
      });
    }

    const event = await Event.findById(req.params.id);
    if (!event) {
      return res.status(404).json({
        success: false,
        message: 'Event not found',
      });
    }

    // Check permission
    if (
      event.organizer.toString() !== req.user._id.toString() &&
      req.user.role !== 'admin'
    ) {
      return res.status(403).json({
        success: false,
        message: 'You do not have permission to update this event',
      });
    }

    // Delete old banner if exists
    if (event.banner) {
      try {
        const publicId = event.banner.split('/').pop().split('.')[0];
        await uploadService.deleteFromCloudinary(`expoconnect/events/${publicId}`);
      } catch (error) {
        logger.warn(`Failed to delete old banner: ${error.message}`);
      }
    }

    const uploadResult = await uploadService.uploadToCloudinary(req.file.buffer, {
      folder: 'expoconnect/events',
      transformation: [
        { width: 1200, height: 600, crop: 'limit' },
      ],
    });

    event.banner = uploadResult.url;
    await event.save();

    res.status(200).json({
      success: true,
      message: 'Event banner updated successfully',
      data: { banner: event.banner },
    });
  } catch (error) {
    logger.error(`Upload banner error: ${error.message}`);
    next(error);
  }
};

exports.deleteEvent = async (req, res, next) => {
  try {
    const event = await Event.findById(req.params.id);
    if (!event) {
      return res.status(404).json({
        success: false,
        message: 'Event not found',
      });
    }

    // Check permission
    if (
      event.organizer.toString() !== req.user._id.toString() &&
      req.user.role !== 'admin'
    ) {
      return res.status(403).json({
        success: false,
        message: 'You do not have permission to delete this event',
      });
    }

    // Delete associated halls and stalls
    await Hall.deleteMany({ event: event._id });
    await Stall.deleteMany({ event: event._id });

    await event.remove();

    res.status(200).json({
      success: true,
      message: 'Event deleted successfully',
    });
  } catch (error) {
    logger.error(`Delete event error: ${error.message}`);
    next(error);
  }
};