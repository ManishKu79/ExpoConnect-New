import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/analytics_remote_datasource.dart';
import '../../data/repositories/analytics_repository_impl.dart';
import '../../domain/repositories/analytics_repository.dart';

final analyticsRemoteDataSourceProvider = Provider<AnalyticsRemoteDataSource>((ref) {
  return AnalyticsRemoteDataSource();
});

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepositoryImpl(ref.read(analyticsRemoteDataSourceProvider));
});

// ============ ORGANIZER STATS ============
final organizerStatsProvider = StateNotifierProvider<OrganizerStatsNotifier, AsyncValue<Map<String, dynamic>?>>((ref) {
  return OrganizerStatsNotifier(ref.read(analyticsRepositoryProvider));
});

class OrganizerStatsNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final AnalyticsRepository repository;

  OrganizerStatsNotifier(this.repository) : super(const AsyncValue.loading());

  Future<void> loadStats() async {
    state = const AsyncValue.loading();
    try {
      final stats = await repository.getOrganizerStats();
      state = AsyncValue.data(stats);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// ============ EVENT ANALYTICS ============
final eventAnalyticsProvider = StateNotifierProvider<EventAnalyticsNotifier, AsyncValue<Map<String, dynamic>?>>((ref) {
  return EventAnalyticsNotifier(ref.read(analyticsRepositoryProvider));
});

class EventAnalyticsNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final AnalyticsRepository repository;

  EventAnalyticsNotifier(this.repository) : super(const AsyncValue.loading());

  Future<void> loadEventAnalytics(String eventId) async {
    state = const AsyncValue.loading();
    try {
      final analytics = await repository.getEventAnalytics(eventId);
      state = AsyncValue.data(analytics);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}