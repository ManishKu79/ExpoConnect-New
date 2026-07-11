const Analytics = require('../models/Analytics');
const Event = require('../models/Event');
const User = require('../models/User');
const Lead = require('../models/Lead');
const Meeting = require('../models/Meeting');
const logger = require('../utils/logger');

class AnalyticsService {
  async trackMetric(eventId, metric, value) {
    try {
      const analytics = new Analytics({
        event: eventId,
        metric,
        value,
        timestamp: new Date(),
      });
      await analytics.save();
      return analytics;
    } catch (error) {
      logger.error(`Track metric error: ${error.message}`);
      throw error;
    }
  }

  async getEventMetrics(eventId, startDate, endDate) {
    const query = {
      event: eventId,
    };

    if (startDate || endDate) {
      query.timestamp = {};
      if (startDate) query.timestamp.$gte = new Date(startDate);
      if (endDate) query.timestamp.$lte = new Date(endDate);
    }

    const metrics = await Analytics.find(query).sort({ timestamp: 1 });
    return this.aggregateMetrics(metrics);
  }

  aggregateMetrics(metrics) {
    const aggregated = {};
    metrics.forEach(metric => {
      if (!aggregated[metric.metric]) {
        aggregated[metric.metric] = {
          total: 0,
          count: 0,
          min: Infinity,
          max: -Infinity,
          data: [],
        };
      }

      const agg = aggregated[metric.metric];
      agg.total += metric.value;
      agg.count++;
      agg.min = Math.min(agg.min, metric.value);
      agg.max = Math.max(agg.max, metric.value);
      agg.data.push({
        timestamp: metric.timestamp,
        value: metric.value,
      });
    });

    Object.keys(aggregated).forEach(key => {
      const agg = aggregated[key];
      agg.average = agg.total / agg.count;
    });

    return aggregated;
  }

  async calculateEngagementScore(eventId) {
    const totalAttendees = await User.countDocuments({ role: 'visitor' });
    const totalExhibitors = await User.countDocuments({ role: 'exhibitor' });
    const totalLeads = await Lead.countDocuments({ event: eventId });
    const totalMeetings = await Meeting.countDocuments({ event: eventId });

    const metrics = {
      attendees: totalAttendees,
      exhibitors: totalExhibitors,
      leads: totalLeads,
      meetings: totalMeetings,
    };

    // Calculate engagement score (0-100)
    const maxExpected = {
      attendees: 1000,
      exhibitors: 100,
      leads: 500,
      meetings: 200,
    };

    let score = 0;
    let weightSum = 0;

    Object.keys(metrics).forEach(key => {
      const value = metrics[key];
      const max = maxExpected[key] || 100;
      const normalized = Math.min(value / max, 1);
      const weight = 1;
      score += normalized * weight;
      weightSum += weight;
    });

    const finalScore = (score / weightSum) * 100;
    return Math.round(finalScore);
  }

  async generateEventReport(eventId) {
    const event = await Event.findById(eventId);
    if (!event) {
      throw new Error('Event not found');
    }

    const totalAttendees = await User.countDocuments({ role: 'visitor' });
    const totalExhibitors = await User.countDocuments({ role: 'exhibitor' });
    const totalLeads = await Lead.countDocuments({ event: eventId });
    const totalMeetings = await Meeting.countDocuments({ event: eventId });

    // Calculate meeting conversion rate
    const meetingsCompleted = await Meeting.countDocuments({
      event: eventId,
      status: 'completed',
    });
    const conversionRate = totalMeetings > 0 
      ? (meetingsCompleted / totalMeetings) * 100 
      : 0;

    // Calculate lead quality distribution
    const leadQuality = await Lead.aggregate([
      { $match: { event: eventId } },
      { $group: {
        _id: '$status',
        count: { $sum: 1 },
      }},
    ]);

    const report = {
      event: {
        id: event._id,
        title: event.title,
        startDate: event.startDate,
        endDate: event.endDate,
      },
      attendance: {
        totalAttendees,
        totalExhibitors,
        ratio: totalAttendees / (totalExhibitors || 1),
      },
      networking: {
        totalLeads,
        totalMeetings,
        meetingsCompleted,
        conversionRate: Math.round(conversionRate * 100) / 100,
      },
      leadQuality: leadQuality.reduce((acc, curr) => {
        acc[curr._id] = curr.count;
        return acc;
      }, {}),
      engagementScore: await this.calculateEngagementScore(eventId),
      generatedAt: new Date(),
    };

    return report;
  }

  async getTopPerformingCompanies(eventId) {
    const companies = await Lead.aggregate([
      { $match: { event: eventId } },
      { $group: {
        _id: '$exhibitor',
        leadCount: { $sum: 1 },
        avgScore: { $avg: '$score' },
        highInterestLeads: {
          $sum: { $cond: [{ $gt: ['$interestLevel', 7] }, 1, 0] },
        },
      }},
      { $lookup: {
        from: 'companies',
        localField: '_id',
        foreignField: '_id',
        as: 'company',
      }},
      { $unwind: '$company' },
      { $sort: { leadCount: -1, avgScore: -1 } },
      { $limit: 10 },
    ]);

    return companies;
  }
}

module.exports = new AnalyticsService();