import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../shared/services/api_service.dart';

class NotificationRemoteDataSource {
  final Dio dio = ApiService.dio;

  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    final response = await dio.get(
      ApiEndpoints.notifications,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (unreadOnly) 'unreadOnly': 'true',
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getUnreadCount() async {
    final response = await dio.get(
      '${ApiEndpoints.notifications}/unread-count',
    );
    return response.data;
  }

  Future<Map<String, dynamic>> markAsRead(String id) async {
    final response = await dio.put(
      '${ApiEndpoints.notifications}/$id/read',
    );
    return response.data;
  }

  Future<Map<String, dynamic>> markAllAsRead() async {
    final response = await dio.put(
      '${ApiEndpoints.notifications}/read-all',
    );
    return response.data;
  }

  Future<Map<String, dynamic>> deleteNotification(String id) async {
    final response = await dio.delete(
      '${ApiEndpoints.notifications}/$id',
    );
    return response.data;
  }
}