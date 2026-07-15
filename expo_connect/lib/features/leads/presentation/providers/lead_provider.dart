import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/lead_remote_datasource.dart';
import '../../data/repositories/lead_repository_impl.dart';
import '../../domain/entities/lead.dart';
import '../../domain/repositories/lead_repository.dart';

final leadRemoteDataSourceProvider = Provider<LeadRemoteDataSource>((ref) {
  return LeadRemoteDataSource();
});

final leadRepositoryProvider = Provider<LeadRepository>((ref) {
  return LeadRepositoryImpl(ref.read(leadRemoteDataSourceProvider));
});

// ============ LEAD LIST ============
final leadListProvider = StateNotifierProvider<LeadListNotifier, AsyncValue<List<Lead>>>((ref) {
  return LeadListNotifier(ref.read(leadRepositoryProvider));
});

class LeadListNotifier extends StateNotifier<AsyncValue<List<Lead>>> {
  final LeadRepository repository;
  int _page = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  String? _currentEventId;
  String? _currentStatus;

  LeadListNotifier(this.repository) : super(const AsyncValue.loading());

  Future<void> loadLeads({
    String? eventId,
    String? status,
    bool refresh = false,
  }) async {
    if (_isLoading) return;
    if (refresh) {
      _page = 1;
      _hasMore = true;
      state = const AsyncValue.loading();
    }
    if (!_hasMore) return;

    _isLoading = true;
    _currentEventId = eventId;
    _currentStatus = status;

    try {
      final result = await repository.getLeads(
        eventId: eventId,
        status: status,
        page: _page,
        limit: 20,
      );

      final leads = result['leads'] ?? [];
      final total = result['total'] ?? 0;

      if (leads.isEmpty || leads.length < 20) {
        _hasMore = false;
      } else {
        _page++;
      }

      final currentList = state.when(
        data: (data) => data,
        error: (_, __) => [],
        loading: () => [],
      );

      final updatedList = refresh ? leads : [...currentList, ...leads];
      state = AsyncValue.data(updatedList);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } finally {
      _isLoading = false;
    }
  }

  void refresh({String? eventId, String? status}) {
    loadLeads(eventId: eventId, status: status, refresh: true);
  }

  void clearState() {
    state = const AsyncValue.loading();
    _page = 1;
    _hasMore = true;
    _isLoading = false;
  }
}

// ============ LEAD STATS ============
final leadStatsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, eventId) async {
  final repo = ref.read(leadRepositoryProvider);
  try {
    final stats = await repo.getLeadStats(eventId);
    return stats;
  } catch (e) {
    print('❌ Lead stats error: $e');
    return {};
  }
});

// ============ LEAD DETAIL ============
final leadDetailProvider = FutureProvider.family<Lead, String>((ref, id) async {
  final repo = ref.read(leadRepositoryProvider);
  return repo.getLeadById(id);
});