import '../datasources/analytics_remote_datasource.dart';
import '../../domain/repositories/analytics_repository.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource remoteDataSource;

  AnalyticsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Map<String, dynamic>> getOrganizerStats() async {
    try {
      final response = await remoteDataSource.getOrganizerStats();
      return response['data'];
    } catch (e) {
      print('❌ Get organizer stats error: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getEventAnalytics(String eventId) async {
    try {
      final response = await remoteDataSource.getEventAnalytics(eventId);
      return response['data'];
    } catch (e) {
      print('❌ Get event analytics error: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getAllEventsAnalytics() async {
    try {
      final response = await remoteDataSource.getAllEventsAnalytics();
      return response['data'];
    } catch (e) {
      print('❌ Get all events analytics error: $e');
      rethrow;
    }
  }
}