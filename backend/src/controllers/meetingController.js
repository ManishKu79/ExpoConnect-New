const Meeting = require('../models/Meeting');
const MeetingHistory = require('../models/MeetingHistory');
const User = require('../models/User');
const Event = require('../models/Event');
const { getSocketService } = require('../sockets');
const logger = require('../utils/logger');
const emailService = require('../services/emailService');

exports.createMeeting = async (req, res, next) => {
  try {
    const { recipientId, eventId, proposedTime, duration, agenda, location } = req.body;

    const meeting = await Meeting.create({
      event: eventId,
      requester: req.user._id,
      recipient: recipientId,
      proposedTime,
      duration,
      agenda,
      location,
    });

    // Create meeting history
    await MeetingHistory.create({
      user: req.user._id,
      meeting: meeting._id,
      action: 'created',
    });

    // Send notification
    const socketService = getSocketService();
    await socketService.saveAndSendNotification(recipientId, {
      type: 'meeting_request',
      title: 'New Meeting Request',
      message: `${req.user.firstName} ${req.user.lastName} has requested a meeting with you`,
      link: `/meetings/${meeting._id}`,
    });

    // Send email notification
    const recipient = await User.findById(recipientId);
    if (recipient) {
      await emailService.sendEmail({
        to: recipient.email,
        subject: 'New Meeting Request - ExpoConnect',
        html: `
          <h2>New Meeting Request</h2>
          <p>${req.user.firstName} ${req.user.lastName} has requested a meeting.</p>
          <p>Date: ${new Date(proposedTime).toLocaleString()}</p>
          ${agenda ? `<p>Agenda: ${agenda}</p>` : ''}
        `,
      });
    }

    res.status(201).json({
      success: true,
      message: 'Meeting request sent successfully',
      data: meeting,
    });
  } catch (error) {
    logger.error(`Create meeting error: ${error.message}`);
    next(error);
  }
};

exports.getMeetings = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    const query = {
      $or: [
        { requester: req.user._id },
        { recipient: req.user._id },
      ],
    };
    if (req.query.status) query.status = req.query.status;
    if (req.query.eventId) query.event = req.query.eventId;

    const meetings = await Meeting.find(query)
      .skip(skip)
      .limit(limit)
      .populate('requester', 'firstName lastName email profilePicture')
      .populate('recipient', 'firstName lastName email profilePicture')
      .populate('event', 'title')
      .sort({ proposedTime: 1 });

    const total = await Meeting.countDocuments(query);

    res.status(200).json({
      success: true,
      data: meetings,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    logger.error(`Get meetings error: ${error.message}`);
    next(error);
  }
};

exports.updateMeetingStatus = async (req, res, next) => {
  try {
    const { status } = req.body;
    const meeting = await Meeting.findById(req.params.id);

    if (!meeting) {
      return res.status(404).json({
        success: false,
        message: 'Meeting not found',
      });
    }

    // Check if user is the recipient
    if (meeting.recipient.toString() !== req.user._id.toString() && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'You do not have permission to update this meeting',
      });
    }

    meeting.status = status;
    await meeting.save();

    // Create meeting history
    await MeetingHistory.create({
      user: req.user._id,
      meeting: meeting._id,
      action: status,
    });

    // Send notification to requester
    const socketService = getSocketService();
    await socketService.saveAndSendNotification(meeting.requester, {
      type: 'meeting_update',
      title: `Meeting ${status}`,
      message: `Your meeting request has been ${status}`,
      link: `/meetings/${meeting._id}`,
    });

    res.status(200).json({
      success: true,
      message: `Meeting ${status} successfully`,
      data: meeting,
    });
  } catch (error) {
    logger.error(`Update meeting status error: ${error.message}`);
    next(error);
  }
};

exports.completeMeeting = async (req, res, next) => {
  try {
    const { feedback, rating } = req.body;
    const meeting = await Meeting.findById(req.params.id);

    if (!meeting) {
      return res.status(404).json({
        success: false,
        message: 'Meeting not found',
      });
    }

    meeting.status = 'completed';
    meeting.feedback = { rating, comment: feedback };
    await meeting.save();

    // Create meeting history
    await MeetingHistory.create({
      user: req.user._id,
      meeting: meeting._id,
      action: 'completed',
    });

    res.status(200).json({
      success: true,
      message: 'Meeting completed successfully',
      data: meeting,
    });
  } catch (error) {
    logger.error(`Complete meeting error: ${error.message}`);
    next(error);
  }
};