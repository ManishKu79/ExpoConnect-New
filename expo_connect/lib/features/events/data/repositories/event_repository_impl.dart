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
    print('🔍 ===== REPOSITORY: GET EVENTS =====');
    
    try {
      final response = await remoteDataSource.getEvents(
        status: status,
        search: search,
        page: page,
        limit: limit,
      );
      
      final data = response['data'] as List? ?? [];
      print('📝 Found ${data.length} events');
      
      final events = data.map((json) => Event.fromJson(json)).toList();
      print('✅ Repository: ${events.length} events loaded');
      return events;
    } catch (e) {
      print('❌ Get events error: $e');
      return [];
    }
  }

  @override
  Future<Event> getEventById(String id) async {
    print('🔍 ===== REPOSITORY: GET EVENT BY ID =====');
    print('📝 Event ID: $id');
    
    try {
      final response = await remoteDataSource.getEventById(id);
      print('📝 Response received');
      return Event.fromJson(response['data']);
    } catch (e) {
      print('❌ Get event by id error: $e');
      rethrow;
    }
  }

  @override
  Future<void> registerForEvent(String eventId) async {
    print('🔍 ===== REPOSITORY: REGISTER FOR EVENT =====');
    print('📝 Event ID: $eventId');
    
    try {
      await remoteDataSource.registerForEvent(eventId);
      print('✅ Repository: User registered for event');
    } catch (e) {
      print('❌ Register for event error: $e');
      rethrow;
    }
  }

  @override
  Future<void> unregisterFromEvent(String eventId) async {
    print('🔍 ===== REPOSITORY: UNREGISTER FROM EVENT =====');
    print('📝 Event ID: $eventId');
    
    try {
      await remoteDataSource.unregisterFromEvent(eventId);
      print('✅ Repository: User unregistered from event');
    } catch (e) {
      print('❌ Unregister from event error: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> checkRegistrationStatus(String eventId) async {
    print('🔍 ===== REPOSITORY: CHECK REGISTRATION STATUS =====');
    print('📝 Event ID: $eventId');
    
    try {
      final response = await remoteDataSource.checkRegistrationStatus(eventId);
      print('✅ Repository: Registration status checked');
      return response['data'];
    } catch (e) {
      print('❌ Check registration status error: $e');
      return {'isRegistered': false};
    }
  }

  @override
  Future<List<Event>> getMyRegisteredEvents() async {
    print('🔍 ===== REPOSITORY: GET MY REGISTERED EVENTS =====');
    
    try {
      final response = await remoteDataSource.getMyRegisteredEvents();
      final data = response['data'] as List? ?? [];
      
      print('📝 Found ${data.length} registered events');
      data.forEach((event) {
        print('📝 Event: ${event['title']}, ID: ${event['id'] ?? event['_id']}');
      });
      
      final events = data.map((json) => Event.fromJson(json)).toList();
      print('✅ Repository: ${events.length} registered events loaded');
      return events;
    } catch (e) {
      print('❌ Get registered events error: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> getEntryQR(String eventId) async {
    print('🔍 ===== REPOSITORY: GET ENTRY QR =====');
    print('📝 Event ID: $eventId');
    
    try {
      final response = await remoteDataSource.getEntryQR(eventId);
      print('📝 Repository: Raw response: $response');
      
      // Check if response is successful
      if (response['success'] == false) {
        print('❌ Repository: API returned error: ${response['message']}');
        throw Exception(response['message'] ?? 'Failed to generate QR code');
      }
      
      final data = response['data'];
      if (data == null) {
        print('❌ Repository: No data in response');
        throw Exception('No data received from server');
      }
      
      final result = {
        'qrCode': data['qrCode'] ?? '',
        'eventTitle': data['eventTitle'] ?? 'Event',
      };
      
      print('✅ Repository: QR data extracted successfully');
      return result;
    } catch (e) {
      print('❌ Get entry QR error: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> verifyEntryQR(String qrData) async {
    print('🔍 ===== REPOSITORY: VERIFY ENTRY QR =====');
    
    try {
      final response = await remoteDataSource.verifyEntryQR(qrData);
      return response['data'];
    } catch (e) {
      print('❌ Verify entry QR error: $e');
      rethrow;
    }
  }

  @override
  Future<Event> createEvent(Map<String, dynamic> eventData) async {
    print('🔍 ===== REPOSITORY: CREATE EVENT =====');
    print('📝 Event Data: $eventData');
    
    try {
      final response = await remoteDataSource.createEvent(eventData);
      print('✅ Repository: Event created');
      return Event.fromJson(response['data']);
    } catch (e) {
      print('❌ Create event error: $e');
      rethrow;
    }
  }

  @override
  Future<Event> updateEvent(String eventId, Map<String, dynamic> eventData) async {
    print('🔍 ===== REPOSITORY: UPDATE EVENT =====');
    print('📝 Event ID: $eventId');
    
    try {
      final response = await remoteDataSource.updateEvent(eventId, eventData);
      print('✅ Repository: Event updated');
      return Event.fromJson(response['data']);
    } catch (e) {
      print('❌ Update event error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    print('🔍 ===== REPOSITORY: DELETE EVENT =====');
    print('📝 Event ID: $eventId');
    
    try {
      await remoteDataSource.deleteEvent(eventId);
      print('✅ Repository: Event deleted');
    } catch (e) {
      print('❌ Delete event error: $e');
      rethrow;
    }
  }

  @override
  Future<List<Event>> getMyEvents() async {
    print('🔍 ===== REPOSITORY: GET MY EVENTS =====');
    
    try {
      final response = await remoteDataSource.getMyEvents();
      final data = response['data'] as List? ?? [];
      print('📝 Found ${data.length} events');
      return data.map((json) => Event.fromJson(json)).toList();
    } catch (e) {
      print('❌ Get my events error: $e');
      return [];
    }
  }
}