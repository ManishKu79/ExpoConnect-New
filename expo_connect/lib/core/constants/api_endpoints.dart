import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:5000/api';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String verifyEmail = '/auth/verify-email';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Users
  static const String users = '/users';
  static const String changePassword = '/users/change-password';
  static const String profilePicture = '/users/profile-picture';

  // Companies
  static const String companies = '/companies';
  static const String companyLogo = '/companies/logo';

  // Events
  static const String events = '/events';
  static const String eventBanner = '/events/banner';

  // Stalls
  static const String stalls = '/stalls';
  static const String assignStall = '/stalls/assign';

  // Leads
  static const String leads = '/leads';
  static const String leadScore = '/leads/score';
  static const String leadRecommendations = '/leads/recommendations';

  // Meetings
  static const String meetings = '/meetings';
  static const String meetingStatus = '/meetings/status';
  static const String meetingComplete = '/meetings/complete';

  // Notifications
  static const String notifications = '/notifications';
  static const String notificationRead = '/notifications/read';
  static const String notificationReadAll = '/notifications/read-all';

  // Analytics
  static const String analytics = '/analytics';
  static const String engagementScore = '/analytics/engagement';
  static const String report = '/analytics/report';

  // AI
  static const String recommendations = '/ai/recommendations';
  static const String sentiment = '/ai/sentiment';
  static const String summarize = '/ai/summarize';
  static const String businessCard = '/ai/business-card';
  static const String transcribe = '/ai/transcribe';

  // Marketplace
  static const String opportunities = '/marketplace/opportunities';
  static const String partnerships = '/marketplace/partnerships';
  static const String collaborations = '/marketplace/collaborations';
  static const String knowledge = '/marketplace/knowledge';
  static const String goals = '/marketplace/goals';
}