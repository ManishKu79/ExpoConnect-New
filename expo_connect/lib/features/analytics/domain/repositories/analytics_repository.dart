abstract class AnalyticsRepository {
  Future<Map<String, dynamic>> getOrganizerStats();
  Future<Map<String, dynamic>> getEventAnalytics(String eventId);
  Future<Map<String, dynamic>> getAllEventsAnalytics();
}