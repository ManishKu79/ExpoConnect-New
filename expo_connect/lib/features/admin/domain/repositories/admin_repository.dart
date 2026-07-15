abstract class AdminRepository {
  // System Stats
  Future<Map<String, dynamic>> getSystemStats();
  Future<List<dynamic>> getRecentActivity();
  
  // User Management
  Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int limit = 20,
    String? role,
    String? search,
    String? status,
  });
  Future<Map<String, dynamic>> updateUser(String id, Map<String, dynamic> data);
  Future<void> deleteUser(String id);
  
  // Event Management
  Future<Map<String, dynamic>> getEvents({
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
  });
  Future<Map<String, dynamic>> updateEvent(String id, Map<String, dynamic> data);
  Future<void> deleteEvent(String id);
  
  // Lead Management
  Future<Map<String, dynamic>> getLeads({
    int page = 1,
    int limit = 20,
    String? status,
    String? eventId,
  });
}