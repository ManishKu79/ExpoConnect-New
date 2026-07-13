import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/event_remote_datasource.dart';
import '../data/repositories/event_repository_impl.dart';
import '../domain/entities/event.dart';
import '../domain/repositories/event_repository.dart';

final eventRemoteDataSourceProvider = Provider<EventRemoteDataSource>((ref) {
  return EventRemoteDataSource();
});

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepositoryImpl(ref.read(eventRemoteDataSourceProvider));
});

final eventListProvider = StateNotifierProvider<EventListNotifier, List<Event>>((ref) {
  return EventListNotifier(ref.read(eventRepositoryProvider));
});

class EventListNotifier extends StateNotifier<List<Event>> {
  final EventRepository repository;
  int _page = 1;
  bool _hasMore = true;
  bool _isLoading = false;

  EventListNotifier(this.repository) : super([]);

  Future<void> loadEvents({String? status, String? search}) async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;
    try {
      final events = await repository.getEvents(
        status: status,
        search: search,
        page: _page,
        limit: 10,
      );
      if (events.isEmpty) {
        _hasMore = false;
      } else {
        _page++;
        state = [...state, ...events];
      }
    } catch (e) {
      // handle error
    } finally {
      _isLoading = false;
    }
  }

  void reset() {
    state = [];
    _page = 1;
    _hasMore = true;
    _isLoading = false;
  }
}

final eventDetailProvider = FutureProvider.family<Event, String>((ref, id) async {
  final repo = ref.read(eventRepositoryProvider);
  return repo.getEventById(id);
});

final eventRegistrationProvider = StateNotifierProvider<EventRegistrationNotifier, bool>((ref) {
  return EventRegistrationNotifier(ref.read(eventRepositoryProvider));
});

class EventRegistrationNotifier extends StateNotifier<bool> {
  final EventRepository repository;
  EventRegistrationNotifier(this.repository) : super(false);

  Future<void> register(String eventId) async {
    state = true;
    try {
      await repository.registerForEvent(eventId);
    } finally {
      state = false;
    }
  }

  Future<void> unregister(String eventId) async {
    state = true;
    try {
      await repository.unregisterFromEvent(eventId);
    } finally {
      state = false;
    }
  }
}