import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../shared/services/api_service.dart';

class EventRemoteDataSource {
  final Dio dio = ApiService.dio;

  Future<Map<String, dynamic>> getEvents({
    String? status,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await dio.get(
      ApiEndpoints.events,
      queryParameters: {
        if (status != null) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
        'page': page,
        'limit': limit,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getEventById(String id) async {
    final response = await dio.get('${ApiEndpoints.events}/$id');
    return response.data;
  }

  Future<Map<String, dynamic>> registerForEvent(String eventId) async {
    final response = await dio.post(
      '${ApiEndpoints.events}/$eventId/register',
    );
    return response.data;
  }

  Future<Map<String, dynamic>> unregisterFromEvent(String eventId) async {
    final response = await dio.delete(
      '${ApiEndpoints.events}/$eventId/register',
    );
    return response.data;
  }
}