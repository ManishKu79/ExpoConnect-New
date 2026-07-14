import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../shared/services/api_service.dart';

class EventRemoteDataSource {
  final Dio dio = ApiService.dio;

  // ============ PUBLIC ============
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

  // ============ REGISTRATION ============
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

  Future<Map<String, dynamic>> checkRegistrationStatus(String eventId) async {
    final response = await dio.get(
      '${ApiEndpoints.events}/$eventId/registration-status',
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getMyRegisteredEvents() async {
    final response = await dio.get(
      '${ApiEndpoints.events}/my-registered-events',
    );
    return response.data;
  }

  // ============ QR ============
  Future<Map<String, dynamic>> getEntryQR(String eventId) async {
    final response = await dio.get(
      '${ApiEndpoints.events}/$eventId/entry-qr',
    );
    return response.data;
  }

  Future<Map<String, dynamic>> verifyEntryQR(String qrData) async {
    final response = await dio.post(
      '${ApiEndpoints.events}/verify-qr',
      data: {'qrData': qrData},
    );
    return response.data;
  }

  // ============ ORGANIZER ============
  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> eventData) async {
    final response = await dio.post(
      ApiEndpoints.events,
      data: eventData,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> updateEvent(String eventId, Map<String, dynamic> eventData) async {
    final response = await dio.put(
      '${ApiEndpoints.events}/$eventId',
      data: eventData,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> deleteEvent(String eventId) async {
    final response = await dio.delete(
      '${ApiEndpoints.events}/$eventId',
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getMyEvents() async {
    final response = await dio.get(
      '${ApiEndpoints.events}/my-events',
    );
    return response.data;
  }
}