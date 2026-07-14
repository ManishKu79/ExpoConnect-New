import '../entities/event.dart';

abstract class EventRepository {
  // Public
  Future<List<Event>> getEvents({
    String? status,
    String? search,
    int page = 1,
    int limit = 10,
  });
  Future<Event> getEventById(String id);
  
  // Registration
  Future<void> registerForEvent(String eventId);
  Future<void> unregisterFromEvent(String eventId);
  Future<Map<String, dynamic>> checkRegistrationStatus(String eventId);
  Future<List<Event>> getMyRegisteredEvents();
  
  // QR
  Future<Map<String, dynamic>> getEntryQR(String eventId);
  Future<Map<String, dynamic>> verifyEntryQR(String qrData);
  
  // Organizer
  Future<Event> createEvent(Map<String, dynamic> eventData);
  Future<Event> updateEvent(String eventId, Map<String, dynamic> eventData);
  Future<void> deleteEvent(String eventId);
  Future<List<Event>> getMyEvents();
}