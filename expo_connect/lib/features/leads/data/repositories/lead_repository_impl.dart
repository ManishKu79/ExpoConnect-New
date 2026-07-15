import '../datasources/lead_remote_datasource.dart';
import '../../domain/entities/lead.dart';
import '../../domain/repositories/lead_repository.dart';

class LeadRepositoryImpl implements LeadRepository {
  final LeadRemoteDataSource remoteDataSource;

  LeadRepositoryImpl(this.remoteDataSource);

  @override
  Future<Map<String, dynamic>> getLeads({
    String? eventId,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await remoteDataSource.getLeads(
        eventId: eventId,
        status: status,
        page: page,
        limit: limit,
      );
      final data = response['data'];
      final leads = (data['leads'] as List? ?? [])
          .map((json) => Lead.fromJson(json))
          .toList();
      return {
        'leads': leads,
        'total': data['pagination']?['total'] ?? 0,
        'stats': data['stats'] ?? {},
      };
    } catch (e) {
      print('❌ Get leads error: $e');
      rethrow;
    }
  }

  @override
  Future<Lead> getLeadById(String id) async {
    try {
      final response = await remoteDataSource.getLeadById(id);
      return Lead.fromJson(response['data']);
    } catch (e) {
      print('❌ Get lead by id error: $e');
      rethrow;
    }
  }

  @override
  Future<Lead> createLead({
    required String visitorId,
    required String eventId,
    int interestLevel = 5,
    String notes = '',
    String source = 'manual',
  }) async {
    try {
      final response = await remoteDataSource.createLead(
        visitorId: visitorId,
        eventId: eventId,
        interestLevel: interestLevel,
        notes: notes,
        source: source,
      );
      return Lead.fromJson(response['data']);
    } catch (e) {
      print('❌ Create lead error: $e');
      rethrow;
    }
  }

  @override
  Future<Lead> updateLead({
    required String id,
    int? interestLevel,
    String? status,
    String? notes,
    DateTime? followUpDate,
  }) async {
    try {
      final response = await remoteDataSource.updateLead(
        id: id,
        interestLevel: interestLevel,
        status: status,
        notes: notes,
        followUpDate: followUpDate?.toIso8601String(),
      );
      return Lead.fromJson(response['data']);
    } catch (e) {
      print('❌ Update lead error: $e');
      rethrow;
    }
  }

  @override
  Future<void> addInteraction({
    required String leadId,
    required String type,
    required String description,
  }) async {
    try {
      await remoteDataSource.addInteraction(
        leadId: leadId,
        type: type,
        description: description,
      );
    } catch (e) {
      print('❌ Add interaction error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteLead(String id) async {
    try {
      await remoteDataSource.deleteLead(id);
    } catch (e) {
      print('❌ Delete lead error: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getLeadStats(String eventId) async {
    try {
      final response = await remoteDataSource.getLeadStats(eventId);
      return response['data'];
    } catch (e) {
      print('❌ Get lead stats error: $e');
      return {};
    }
  }
}