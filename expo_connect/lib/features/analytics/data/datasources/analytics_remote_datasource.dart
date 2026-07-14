import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../shared/services/api_service.dart';

class AnalyticsRemoteDataSource {
  final Dio dio = ApiService.dio;

  Future<Map<String, dynamic>> getOrganizerStats() async {
    final response = await dio.get(
      '${ApiEndpoints.analytics}/organizer/stats',
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getEventAnalytics(String eventId) async {
    final response = await dio.get(
      '${ApiEndpoints.analytics}/event/$eventId',
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getAllEventsAnalytics() async {
    final response = await dio.get(
      '${ApiEndpoints.analytics}/events/all',
    );
    return response.data;
  }
}