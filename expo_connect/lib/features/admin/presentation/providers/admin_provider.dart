import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/admin_remote_datasource.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../domain/repositories/admin_repository.dart';

final adminRemoteDataSourceProvider = Provider<AdminRemoteDataSource>((ref) {
  return AdminRemoteDataSource();
});

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepositoryImpl(ref.read(adminRemoteDataSourceProvider));
});

// ============ ADMIN STATS ============
final adminStatsProvider = StateNotifierProvider<AdminStatsNotifier, AsyncValue<Map<String, dynamic>?>>((ref) {
  return AdminStatsNotifier(ref.read(adminRepositoryProvider));
});

class AdminStatsNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final AdminRepository repository;

  AdminStatsNotifier(this.repository) : super(const AsyncValue.loading());

  Future<void> loadStats() async {
    state = const AsyncValue.loading();
    try {
      final stats = await repository.getSystemStats();
      state = AsyncValue.data(stats);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// ============ RECENT ACTIVITY ============
final recentActivityProvider = StateNotifierProvider<RecentActivityNotifier, AsyncValue<List<dynamic>?>>((ref) {
  return RecentActivityNotifier(ref.read(adminRepositoryProvider));
});

class RecentActivityNotifier extends StateNotifier<AsyncValue<List<dynamic>?>> {
  final AdminRepository repository;

  RecentActivityNotifier(this.repository) : super(const AsyncValue.loading());

  Future<void> loadActivity() async {
    state = const AsyncValue.loading();
    try {
      final activity = await repository.getRecentActivity();
      state = AsyncValue.data(activity);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}