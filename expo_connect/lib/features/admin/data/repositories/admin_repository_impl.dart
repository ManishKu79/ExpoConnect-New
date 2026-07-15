import '../datasources/admin_remote_datasource.dart';
import '../../domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl(this.remoteDataSource);

  @override
  Future<Map<String, dynamic>> getSystemStats() async {
    try {
      final response = await remoteDataSource.getSystemStats();
      print('📊 System stats response: $response');
      return response['data'] ?? {};
    } catch (e) {
      print('❌ Get system stats error: $e');
      return {};
    }
  }

  @override
  Future<List<dynamic>> getRecentActivity() async {
    try {
      final response = await remoteDataSource.getRecentActivity();
      print('📊 Recent activity response: $response');
      return response['data'] ?? [];
    } catch (e) {
      print('❌ Get recent activity error: $e');
      return [];
    }
  }

  @override
  Future<List<dynamic>> getUsers({
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
      
      print('📝 Users API response: $response');
      
      // Extract the data list from the response
      if (response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          final innerData = data['data'];
          if (innerData is List) {
            print('📝 Extracted ${innerData.length} users');
            return innerData;
          }
        } else if (data is List) {
          print('📝 Extracted ${data.length} users');
          return data;
        }
      }
      
      print('⚠️ No users found');
      return [];
    } catch (e) {
      print('❌ Get users error: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> updateUser(String id, Map<String, dynamic> data) async {
    try {
      final response = await remoteDataSource.updateUser(id, data);
      return response['data'] ?? {};
    } catch (e) {
      print('❌ Update user error: $e');
      return {};
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

  @override
  Future<List<dynamic>> getEvents({
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
      
      print('📝 Events API response: $response');
      
      if (response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          final innerData = data['data'];
          if (innerData is List) {
            print('📝 Extracted ${innerData.length} events');
            return innerData;
          }
        } else if (data is List) {
          print('📝 Extracted ${data.length} events');
          return data;
        }
      }
      
      print('⚠️ No events found');
      return [];
    } catch (e) {
      print('❌ Get events error: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> updateEvent(String id, Map<String, dynamic> data) async {
    try {
      final response = await remoteDataSource.updateEvent(id, data);
      return response['data'] ?? {};
    } catch (e) {
      print('❌ Update event error: $e');
      return {};
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

  @override
  Future<List<dynamic>> getLeads({
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
      
      print('📝 Leads API response: $response');
      
      if (response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          final innerData = data['data'];
          if (innerData is List) {
            print('📝 Extracted ${innerData.length} leads');
            return innerData;
          }
        } else if (data is List) {
          print('📝 Extracted ${data.length} leads');
          return data;
        }
      }
      
      print('⚠️ No leads found');
      return [];
    } catch (e) {
      print('❌ Get leads error: $e');
      return [];
    }
  }
}