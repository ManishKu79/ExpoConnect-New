import '../datasources/notification_remote_datasource.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl(this.remoteDataSource);

  @override
  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    try {
      final response = await remoteDataSource.getNotifications(
        page: page,
        limit: limit,
        unreadOnly: unreadOnly,
      );
      final data = response['data'];
      final notifications = (data['notifications'] as List? ?? [])
          .map((json) => NotificationEntity.fromJson(json))
          .toList();
      return {
        'notifications': notifications,
        'total': data['pagination']?['total'] ?? 0,
        'unreadCount': data['unreadCount'] ?? 0,
      };
    } catch (e) {
      print('❌ Get notifications error: $e');
      rethrow;
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await remoteDataSource.getUnreadCount();
      return response['data']?['unreadCount'] ?? 0;
    } catch (e) {
      print('❌ Get unread count error: $e');
      return 0;
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await remoteDataSource.markAsRead(id);
    } catch (e) {
      print('❌ Mark as read error: $e');
      rethrow;
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await remoteDataSource.markAllAsRead();
    } catch (e) {
      print('❌ Mark all as read error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    try {
      await remoteDataSource.deleteNotification(id);
    } catch (e) {
      print('❌ Delete notification error: $e');
      rethrow;
    }
  }
}