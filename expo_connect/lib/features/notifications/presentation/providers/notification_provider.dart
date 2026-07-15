import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/notification_remote_datasource.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';

final notificationRemoteDataSourceProvider = Provider<NotificationRemoteDataSource>((ref) {
  return NotificationRemoteDataSource();
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(ref.read(notificationRemoteDataSourceProvider));
});

// ============ NOTIFICATION LIST ============
final notificationListProvider = StateNotifierProvider<NotificationListNotifier, AsyncValue<List<NotificationEntity>>>((ref) {
  return NotificationListNotifier(ref.read(notificationRepositoryProvider));
});

class NotificationListNotifier extends StateNotifier<AsyncValue<List<NotificationEntity>>> {
  final NotificationRepository repository;
  int _page = 1;
  bool _hasMore = true;
  bool _isLoading = false;

  NotificationListNotifier(this.repository) : super(const AsyncValue.loading());

  Future<void> loadNotifications({bool refresh = false}) async {
    if (_isLoading) return;
    if (refresh) {
      _page = 1;
      _hasMore = true;
      state = const AsyncValue.loading();
    }
    if (!_hasMore) return;

    _isLoading = true;
    try {
      final result = await repository.getNotifications(page: _page);
      final notifications = result['notifications'] ?? [];
      final total = result['total'] ?? 0;

      if (notifications.isEmpty || notifications.length < 20) {
        _hasMore = false;
      } else {
        _page++;
      }

      final currentList = state.when(
        data: (data) => data,
        error: (_, __) => [],
        loading: () => [],
      );

      final updatedList = refresh ? notifications : [...currentList, ...notifications];
      state = AsyncValue.data(updatedList);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } finally {
      _isLoading = false;
    }
  }

  void refresh() {
    loadNotifications(refresh: true);
  }
}

// ============ UNREAD COUNT ============
final unreadCountProvider = StateNotifierProvider<UnreadCountNotifier, int>((ref) {
  return UnreadCountNotifier(ref.read(notificationRepositoryProvider));
});

class UnreadCountNotifier extends StateNotifier<int> {
  final NotificationRepository repository;

  UnreadCountNotifier(this.repository) : super(0);

  Future<void> loadUnreadCount() async {
    try {
      final count = await repository.getUnreadCount();
      state = count;
    } catch (e) {
      print('❌ Load unread count error: $e');
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await repository.markAsRead(id);
      state = state - 1;
    } catch (e) {
      print('❌ Mark as read error: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await repository.markAllAsRead();
      state = 0;
    } catch (e) {
      print('❌ Mark all as read error: $e');
    }
  }

  void increment() {
    state = state + 1;
  }
}