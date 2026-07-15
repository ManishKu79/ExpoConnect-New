import '../datasources/admin_remote_datasource.dart';
import '../../domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl(this.remoteDataSource);

  // ============ SYSTEM STATS ============
  @override
  Future<Map<String, dynamic>> getSystemStats() async {
    try {
      final response = await remoteDataSource.getSystemStats();
      return response['data'];
    } catch (e) {
      print('❌ Get system stats error: $e');
      rethrow;
    }
  }

  @override
  Future<List<dynamic>> getRecentActivity() async {
    try {
      final response = await remoteDataSource.getRecentActivity();
      return response['data'] ?? [];
    } catch (e) {
      print('❌ Get recent activity error: $e');
      return [];
    }
  }

  // ============ USER MANAGEMENT ============
  @override
  Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int limit = 20,
    String? role,
    String? search,
    String? status,
  }) async {
    try {
      final response = await remoteDataSource.getUsers(
        page: page,
        limit: limit,
        role: role,
        search: search,
        status: status,
      );
      return response['data'];
    } catch (e) {
      print('❌ Get users error: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateUser(String id, Map<String, dynamic> data) async {
    try {
      final response = await remoteDataSource.updateUser(id, data);
      return response['data'];
    } catch (e) {
      print('❌ Update user error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    try {
      await remoteDataSource.deleteUser(id);
    } catch (e) {
      print('❌ Delete user error: $e');
      rethrow;
    }
  }

  // ============ EVENT MANAGEMENT ============
  @override
  Future<Map<String, dynamic>> getEvents({
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
  }) async {
    try {
      final response = await remoteDataSource.getEvents(
        page: page,
        limit: limit,
        status: status,
        search: search,
      );
      return response['data'];
    } catch (e) {
      print('❌ Get events error: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateEvent(String id, Map<String, dynamic> data) async {
    try {
      final response = await remoteDataSource.updateEvent(id, data);
      return response['data'];
    } catch (e) {
      print('❌ Update event error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteEvent(String id) async {
    try {
      await remoteDataSource.deleteEvent(id);
    } catch (e) {
      print('❌ Delete event error: $e');
      rethrow;
    }
  }

  // ============ LEAD MANAGEMENT ============
  @override
  Future<Map<String, dynamic>> getLeads({
    int page = 1,
    int limit = 20,
    String? status,
    String? eventId,
  }) async {
    try {
      final response = await remoteDataSource.getLeads(
        page: page,
        limit: limit,
        status: status,
        eventId: eventId,
      );
      return response['data'];
    } catch (e) {
      print('❌ Get leads error: $e');
      rethrow;
    }
  }
}