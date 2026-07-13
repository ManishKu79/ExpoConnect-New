import '../entities/event.dart';

abstract class EventRepository {
  Future<List<Event>> getEvents({
    String? status,
    String? search,
    int page = 1,
    int limit = 10,
  });
  Future<Event> getEventById(String id);
  Future<void> registerForEvent(String eventId);
  Future<void> unregisterFromEvent(String eventId);
}
