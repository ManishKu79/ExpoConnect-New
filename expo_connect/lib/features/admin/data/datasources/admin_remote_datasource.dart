import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../shared/services/api_service.dart';

class AdminRemoteDataSource {
  final Dio dio = ApiService.dio;

  // ============ SYSTEM STATS ============
  Future<Map<String, dynamic>> getSystemStats() async {
    final response = await dio.get(
      '${ApiEndpoints.admin}/stats',
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getRecentActivity() async {
    final response = await dio.get(
      '${ApiEndpoints.admin}/activity',
    );
    return response.data;
  }

  // ============ USER MANAGEMENT ============
  Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int limit = 20,
    String? role,
    String? search,
    String? status,
  }) async {
    final response = await dio.get(
      '${ApiEndpoints.admin}/users',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (role != null) 'role': role,
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null) 'status': status,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> updateUser(String id, Map<String, dynamic> data) async {
    final response = await dio.put(
      '${ApiEndpoints.admin}/users/$id',
      data: data,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> deleteUser(String id) async {
    final response = await dio.delete(
      '${ApiEndpoints.admin}/users/$id',
    );
    return response.data;
  }

  // ============ EVENT MANAGEMENT ============
  Future<Map<String, dynamic>> getEvents({
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
  }) async {
    final response = await dio.get(
      '${ApiEndpoints.admin}/events',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> updateEvent(String id, Map<String, dynamic> data) async {
    final response = await dio.put(
      '${ApiEndpoints.admin}/events/$id',
      data: data,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> deleteEvent(String id) async {
    final response = await dio.delete(
      '${ApiEndpoints.admin}/events/$id',
    );
    return response.data;
  }

  // ============ LEAD MANAGEMENT ============
  Future<Map<String, dynamic>> getLeads({
    int page = 1,
    int limit = 20,
    String? status,
    String? eventId,
  }) async {
    final response = await dio.get(
      '${ApiEndpoints.admin}/leads',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
        if (eventId != null) 'eventId': eventId,
      },
    );
    return response.data;
  }
}