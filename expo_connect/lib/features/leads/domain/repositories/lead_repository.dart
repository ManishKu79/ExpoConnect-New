import '../entities/lead.dart';

abstract class LeadRepository {
  Future<Map<String, dynamic>> getLeads({
    String? eventId,
    String? status,
    int page = 1,
    int limit = 20,
  });
  Future<Lead> getLeadById(String id);
  Future<Lead> createLead({
    required String visitorId,
    required String eventId,
    int interestLevel,
    String notes,
    String source,
  });
  Future<Lead> updateLead({
    required String id,
    int? interestLevel,
    String? status,
    String? notes,
    DateTime? followUpDate,
  });
  Future<void> addInteraction({
    required String leadId,
    required String type,
    required String description,
  });
  Future<void> deleteLead(String id);
  Future<Map<String, dynamic>> getLeadStats(String eventId);
}