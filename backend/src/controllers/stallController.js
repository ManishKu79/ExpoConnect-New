const Stall = require('../models/Stall');
const Hall = require('../models/Hall');
const Event = require('../models/Event');
const logger = require('../utils/logger');

exports.createStall = async (req, res, next) => {
  try {
    const { eventId, hallId, number, size, price, features } = req.body;

    // Verify event exists and user has permission
    const event = await Event.findById(eventId);
    if (!event) {
      return res.status(404).json({
        success: false,
        message: 'Event not found',
      });
    }

    if (
      event.organizer.toString() !== req.user._id.toString() &&
      req.user.role !== 'admin'
    ) {
      return res.status(403).json({
        success: false,
        message: 'You do not have permission to create stalls for this event',
      });
    }

    // Verify hall exists
    const hall = await Hall.findById(hallId);
    if (!hall) {
      return res.status(404).json({
        success: false,
        message: 'Hall not found',
      });
    }

    // Check if stall number already exists in the same hall
    const existingStall = await Stall.findOne({ event: eventId, hall: hallId, number });
    if (existingStall) {
      return res.status(400).json({
        success: false,
        message: 'Stall number already exists in this hall',
      });
    }

    const stall = await Stall.create({
      event: eventId,
      hall: hallId,
      number,
      size,
      price,
      features,
    });

    res.status(201).json({
      success: true,
      message: 'Stall created successfully',
      data: stall,
    });
  } catch (error) {
    logger.error(`Create stall error: ${error.message}`);
    next(error);
  }
};

exports.getStallsByEvent = async (req, res, next) => {
  try {
    const { eventId } = req.params;
    const { hallId, isAvailable } = req.query;

    const query = { event: eventId };
    if (hallId) query.hall = hallId;
    if (isAvailable !== undefined) query.isAvailable = isAvailable === 'true';

    const stalls = await Stall.find(query)
      .populate('hall', 'name')
      .populate('company', 'name logo')
      .sort({ hall: 1, number: 1 });

    res.status(200).json({
      success: true,
      data: stalls,
    });
  } catch (error) {
    logger.error(`Get stalls by event error: ${error.message}`);
    next(error);
  }
};

exports.getStallById = async (req, res, next) => {
  try {
    const stall = await Stall.findById(req.params.id)
      .populate('hall')
      .populate('company', 'name logo description')
      .populate('event', 'title');

    if (!stall) {
      return res.status(404).json({
        success: false,
        message: 'Stall not found',
      });
    }

    res.status(200).json({
      success: true,
      data: stall,
    });
  } catch (error) {
    logger.error(`Get stall by id error: ${error.message}`);
    next(error);
  }
};

exports.updateStall = async (req, res, next) => {
  try {
    const stall = await Stall.findById(req.params.id);
    if (!stall) {
      return res.status(404).json({
        success: false,
        message: 'Stall not found',
      });
    }

    const event = await Event.findById(stall.event);
    if (
      event.organizer.toString() !== req.user._id.toString() &&
      req.user.role !== 'admin'
    ) {
      return res.status(403).json({
        success: false,
        message: 'You do not have permission to update this stall',
      });
    }

    const updates = req.body;
    Object.keys(updates).forEach(key => {
      stall[key] = updates[key];
    });

    await stall.save();

    res.status(200).json({
      success: true,
      message: 'Stall updated successfully',
      data: stall,
    });
  } catch (error) {
    logger.error(`Update stall error: ${error.message}`);
    next(error);
  }
};

exports.assignStall = async (req, res, next) => {
  try {
    const { companyId } = req.body;
    const stall = await Stall.findById(req.params.id);

    if (!stall) {
      return res.status(404).json({
        success: false,
        message: 'Stall not found',
      });
    }

    if (stall.isBooked) {
      return res.status(400).json({
        success: false,
        message: 'Stall is already booked',
      });
    }

    const event = await Event.findById(stall.event);
    if (
      event.organizer.toString() !== req.user._id.toString() &&
      req.user.role !== 'admin'
    ) {
      return res.status(403).json({
        success: false,
        message: 'You do not have permission to assign this stall',
      });
    }

    stall.company = companyId;
    stall.isBooked = true;
    stall.isAvailable = false;
    await stall.save();

    res.status(200).json({
      success: true,
      message: 'Stall assigned successfully',
      data: stall,
    });
  } catch (error) {
    logger.error(`Assign stall error: ${error.message}`);
    next(error);
  }
};

exports.deleteStall = async (req, res, next) => {
  try {
    const stall = await Stall.findById(req.params.id);
    if (!stall) {
      return res.status(404).json({
        success: false,
        message: 'Stall not found',
      });
    }

    const event = await Event.findById(stall.event);
    if (
      event.organizer.toString() !== req.user._id.toString() &&
      req.user.role !== 'admin'
    ) {
      return res.status(403).json({
        success: false,
        message: 'You do not have permission to delete this stall',
      });
    }

    await stall.remove();

    res.status(200).json({
      success: true,
      message: 'Stall deleted successfully',
    });
  } catch (error) {
    logger.error(`Delete stall error: ${error.message}`);
    next(error);
  }
};