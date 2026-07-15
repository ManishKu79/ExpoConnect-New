import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../shared/services/api_service.dart';

class LeadRemoteDataSource {
  final Dio dio = ApiService.dio;

  Future<Map<String, dynamic>> getLeads({
    String? eventId,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await dio.get(
      ApiEndpoints.leads,
      queryParameters: {
        if (eventId != null) 'eventId': eventId,
        if (status != null) 'status': status,
        'page': page,
        'limit': limit,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getLeadById(String id) async {
    final response = await dio.get('${ApiEndpoints.leads}/$id');
    return response.data;
  }

  Future<Map<String, dynamic>> createLead({
    required String visitorId,
    required String eventId,
    int interestLevel = 5,
    String notes = '',
    String source = 'manual',
  }) async {
    final response = await dio.post(
      ApiEndpoints.leads,
      data: {
        'visitorId': visitorId,
        'eventId': eventId,
        'interestLevel': interestLevel,
        'notes': notes,
        'source': source,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> updateLead({
    required String id,
    int? interestLevel,
    String? status,
    String? notes,
    String? followUpDate,
  }) async {
    final data = <String, dynamic>{};
    if (interestLevel != null) data['interestLevel'] = interestLevel;
    if (status != null) data['status'] = status;
    if (notes != null) data['notes'] = notes;
    if (followUpDate != null) data['followUpDate'] = followUpDate;

    final response = await dio.put(
      '${ApiEndpoints.leads}/$id',
      data: data,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> addInteraction({
    required String leadId,
    required String type,
    required String description,
  }) async {
    final response = await dio.post(
      '${ApiEndpoints.leads}/$leadId/interaction',
      data: {
        'type': type,
        'description': description,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> deleteLead(String id) async {
    final response = await dio.delete('${ApiEndpoints.leads}/$id');
    return response.data;
  }

  Future<Map<String, dynamic>> getLeadStats(String eventId) async {
    final response = await dio.get(
      '${ApiEndpoints.leads}/stats/$eventId',
    );
    return response.data;
  }
}