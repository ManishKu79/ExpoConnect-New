const axios = require('axios');
const logger = require('../utils/logger');
const User = require('../models/User');
const Company = require('../models/Company');
const Lead = require('../models/Lead');
const Event = require('../models/Event');

class AIService {
  constructor() {
    this.baseURL = process.env.AI_SERVICE_URL || 'http://localhost:8000';
  }

  async getRecommendations(userId, limit = 10) {
    try {
      const response = await axios.post(`${this.baseURL}/recommendations`, {
        userId,
        limit,
      });
      return response.data;
    } catch (error) {
      logger.error(`AI recommendation error: ${error.message}`);
      // Fallback to simple recommendations
      return this.getFallbackRecommendations(userId, limit);
    }
  }

  async getFallbackRecommendations(userId, limit) {
    const user = await User.findById(userId).populate('company');
    const companies = await Company.find({
      _id: { $ne: user.company?._id },
      industry: user.company?.industry,
      isVerified: true,
    })
      .limit(limit)
      .sort({ reputationScore: -1 });

    return companies.map(company => ({
      company,
      score: company.reputationScore || 50,
      reason: 'Based on industry similarity',
    }));
  }

  async scoreLead(leadId) {
    try {
      const lead = await Lead.findById(leadId)
        .populate('exhibitor')
        .populate('visitor');

      const response = await axios.post(`${this.baseURL}/lead-score`, {
        lead: {
          id: lead._id,
          interestLevel: lead.interestLevel,
          interactions: lead.interactions,
          visitor: {
            interests: lead.visitor.interests,
            company: lead.visitor.company,
          },
          exhibitor: {
            industry: lead.exhibitor.industry,
            products: lead.exhibitor.products,
          },
        },
      });

      lead.score = response.data.score;
      await lead.save();

      return response.data;
    } catch (error) {
      logger.error(`Lead scoring error: ${error.message}`);
      // Simple fallback scoring
      const lead = await Lead.findById(leadId);
      const baseScore = lead.interestLevel * 10;
      const interactionScore = Math.min(lead.interactions.length * 5, 30);
      lead.score = Math.min(baseScore + interactionScore, 100);
      await lead.save();
      return { score: lead.score };
    }
  }

  async analyzeSentiment(text) {
    try {
      const response = await axios.post(`${this.baseURL}/sentiment`, { text });
      return response.data;
    } catch (error) {
      logger.error(`Sentiment analysis error: ${error.message}`);
      return {
        sentiment: 'neutral',
        confidence: 0.5,
        score: 0,
      };
    }
  }

  async summarizeText(text, maxLength = 200) {
    try {
      const response = await axios.post(`${this.baseURL}/summarize`, {
        text,
        maxLength,
      });
      return response.data;
    } catch (error) {
      logger.error(`Text summarization error: ${error.message}`);
      return {
        summary: text.substring(0, maxLength) + '...',
      };
    }
  }

  async extractBusinessInfo(text) {
    try {
      const response = await axios.post(`${this.baseURL}/extract-business`, { text });
      return response.data;
    } catch (error) {
      logger.error(`Business info extraction error: ${error.message}`);
      return {
        company: null,
        industry: null,
        contact: null,
      };
    }
  }

  async matchOpportunities(companyId) {
    try {
      const response = await axios.post(`${this.baseURL}/match-opportunities`, {
        companyId,
      });
      return response.data;
    } catch (error) {
      logger.error(`Opportunity matching error: ${error.message}`);
      return { matches: [] };
    }
  }

  async generateFollowUpSuggestions(leadId) {
    try {
      const response = await axios.post(`${this.baseURL}/follow-up`, {
        leadId,
      });
      return response.data;
    } catch (error) {
      logger.error(`Follow-up suggestion error: ${error.message}`);
      return {
        suggestions: ['Schedule a follow-up meeting', 'Send a personalized email'],
      };
    }
  }

  async predictVisitorBehavior(eventId, userId) {
    try {
      const response = await axios.post(`${this.baseURL}/visitor-behavior`, {
        eventId,
        userId,
      });
      return response.data;
    } catch (error) {
      logger.error(`Visitor behavior prediction error: ${error.message}`);
      return {
        interests: [],
        recommendedStalls: [],
        engagementScore: 50,
      };
    }
  }

  async generateBusinessInsights(companyId) {
    try {
      const response = await axios.post(`${this.baseURL}/business-insights`, {
        companyId,
      });
      return response.data;
    } catch (error) {
      logger.error(`Business insights generation error: ${error.message}`);
      return {
        strengths: [],
        weaknesses: [],
        opportunities: [],
        threats: [],
        recommendations: [],
      };
    }
  }

  async transcribeAudio(audioUrl) {
    try {
      const response = await axios.post(`${this.baseURL}/transcribe`, {
        audioUrl,
      });
      return response.data;
    } catch (error) {
      logger.error(`Audio transcription error: ${error.message}`);
      return { transcript: '', confidence: 0 };
    }
  }

  async extractBusinessCard(imageUrl) {
    try {
      const response = await axios.post(`${this.baseURL}/ocr-business-card`, {
        imageUrl,
      });
      return response.data;
    } catch (error) {
      logger.error(`Business card OCR error: ${error.message}`);
      return {
        name: '',
        company: '',
        email: '',
        phone: '',
        position: '',
      };
    }
  }
}

module.exports = new AIService();