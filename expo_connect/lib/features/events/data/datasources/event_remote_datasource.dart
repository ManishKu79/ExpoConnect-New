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
    print('📡 ===== GET EVENTS API CALL =====');
    print('📡 Status: $status, Search: $search, Page: $page');
    
    final response = await dio.get(
      ApiEndpoints.events,
      queryParameters: {
        if (status != null) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
        'page': page,
        'limit': limit,
      },
    );
    
    print('📡 Response status: ${response.statusCode}');
    return response.data;
  }

  Future<Map<String, dynamic>> getEventById(String id) async {
    print('📡 ===== GET EVENT BY ID API CALL =====');
    print('📡 Event ID: $id');
    
    final response = await dio.get('${ApiEndpoints.events}/$id');
    print('📡 Response status: ${response.statusCode}');
    return response.data;
  }

  // ============ REGISTRATION ============
  Future<Map<String, dynamic>> registerForEvent(String eventId) async {
    print('📡 ===== REGISTER FOR EVENT API CALL =====');
    print('📡 Event ID: $eventId');
    
    final response = await dio.post(
      '${ApiEndpoints.events}/$eventId/register',
    );
    
    print('📡 Response status: ${response.statusCode}');
    print('📡 Response data: ${response.data}');
    return response.data;
  }

  Future<Map<String, dynamic>> unregisterFromEvent(String eventId) async {
    print('📡 ===== UNREGISTER FROM EVENT API CALL =====');
    print('📡 Event ID: $eventId');
    
    final response = await dio.delete(
      '${ApiEndpoints.events}/$eventId/register',
    );
    
    print('📡 Response status: ${response.statusCode}');
    return response.data;
  }

  Future<Map<String, dynamic>> checkRegistrationStatus(String eventId) async {
    print('📡 ===== CHECK REGISTRATION STATUS API CALL =====');
    print('📡 Event ID: $eventId');
    
    final response = await dio.get(
      '${ApiEndpoints.events}/$eventId/registration-status',
    );
    
    print('📡 Response status: ${response.statusCode}');
    print('📡 Response data: ${response.data}');
    return response.data;
  }

  Future<Map<String, dynamic>> getMyRegisteredEvents() async {
    print('📡 ===== GET MY REGISTERED EVENTS API CALL =====');
    
    final response = await dio.get(
      '${ApiEndpoints.events}/my-registered-events',
    );
    
    print('📡 Response status: ${response.statusCode}');
    print('📡 Response data: ${response.data}');
    return response.data;
  }

  // ============ QR ============
  Future<Map<String, dynamic>> getEntryQR(String eventId) async {
    print('📡 ===== GET ENTRY QR API CALL =====');
    print('📡 Event ID: $eventId');
    
    try {
      final response = await dio.get(
        '${ApiEndpoints.events}/$eventId/entry-qr',
      );
      
      print('📡 Response status: ${response.statusCode}');
      print('📡 Response data: ${response.data}');
      return response.data;
    } catch (e) {
      print('❌ Entry QR API error: $e');
      if (e is DioException) {
        print('❌ Response: ${e.response?.data}');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyEntryQR(String qrData) async {
    print('📡 ===== VERIFY ENTRY QR API CALL =====');
    
    final response = await dio.post(
      '${ApiEndpoints.events}/verify-qr',
      data: {'qrData': qrData},
    );
    
    print('📡 Response status: ${response.statusCode}');
    return response.data;
  }

  // ============ ORGANIZER ============
  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> eventData) async {
    print('📡 ===== CREATE EVENT API CALL =====');
    print('📡 Event Data: $eventData');
    
    final response = await dio.post(
      ApiEndpoints.events,
      data: eventData,
    );
    
    print('📡 Response status: ${response.statusCode}');
    return response.data;
  }

  Future<Map<String, dynamic>> updateEvent(String eventId, Map<String, dynamic> eventData) async {
    print('📡 ===== UPDATE EVENT API CALL =====');
    print('📡 Event ID: $eventId');
    
    final response = await dio.put(
      '${ApiEndpoints.events}/$eventId',
      data: eventData,
    );
    
    print('📡 Response status: ${response.statusCode}');
    return response.data;
  }

  Future<Map<String, dynamic>> deleteEvent(String eventId) async {
    print('📡 ===== DELETE EVENT API CALL =====');
    print('📡 Event ID: $eventId');
    
    final response = await dio.delete(
      '${ApiEndpoints.events}/$eventId',
    );
    
    print('📡 Response status: ${response.statusCode}');
    return response.data;
  }

  Future<Map<String, dynamic>> getMyEvents() async {
    print('📡 ===== GET MY EVENTS API CALL =====');
    
    final response = await dio.get(
      '${ApiEndpoints.events}/my-events',
    );
    
    print('📡 Response status: ${response.statusCode}');
    return response.data;
  }
}