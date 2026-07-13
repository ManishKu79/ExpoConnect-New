import '../datasources/event_remote_datasource.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource remoteDataSource;

  EventRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Event>> getEvents({
    String? status,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await remoteDataSource.getEvents(
        status: status,
        search: search,
        page: page,
        limit: limit,
      );
      final data = response['data'] as List? ?? [];
      return data.map((json) => Event.fromJson(json)).toList();
    } catch (e) {
      print('❌ Get events error: $e');
      return [];
    }
  }

  @override
  Future<Event> getEventById(String id) async {
    try {
      final response = await remoteDataSource.getEventById(id);
      return Event.fromJson(response['data']);
    } catch (e) {
      print('❌ Get event by id error: $e');
      rethrow;
    }
  }

  @override
  Future<void> registerForEvent(String eventId) async {
    try {
      await remoteDataSource.registerForEvent(eventId);
    } catch (e) {
      print('❌ Register for event error: $e');
      rethrow;
    }
  }

  @override
  Future<void> unregisterFromEvent(String eventId) async {
    try {
      await remoteDataSource.unregisterFromEvent(eventId);
    } catch (e) {
      print('❌ Unregister from event error: $e');
      rethrow;
    }
  }
}
