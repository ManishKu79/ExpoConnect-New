import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime createdAt;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });
}

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  // Sample notifications - Replace with actual API data
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _notifications = [
        NotificationItem(
          id: '1',
          title: 'New Event: Tech Expo 2024',
          message: 'A new technology expo has been announced. Register now!',
          type: 'event',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: false,
        ),
        NotificationItem(
          id: '2',
          title: 'Meeting Reminder',
          message: 'You have a meeting with John Doe at 3:00 PM',
          type: 'meeting',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          isRead: true,
        ),
        NotificationItem(
          id: '3',
          title: 'New Lead',
          message: 'A new lead has been added to your company profile',
          type: 'lead',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          isRead: true,
        ),
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: isDark ? AppColors.grey900 : Colors.white,
        elevation: 0,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () {
                setState(() {
                  _notifications = _notifications.map((n) {
                    return NotificationItem(
                      id: n.id,
                      title: n.title,
                      message: n.message,
                      type: n.type,
                      createdAt: n.createdAt,
                      isRead: true,
                    );
                  }).toList();
                });
              },
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const EmptyStateWidget(
                  title: 'No Notifications',
                  message: 'You have no notifications at the moment.',
                  icon: Icons.notifications_off,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return _NotificationCard(
                      notification: notification,
                      onTap: () {
                        setState(() {
                          _notifications[index] = NotificationItem(
                            id: notification.id,
                            title: notification.title,
                            message: notification.message,
                            type: notification.type,
                            createdAt: notification.createdAt,
                            isRead: true,
                          );
                        });
                      },
                    );
                  },
                ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color getTypeColor() {
      switch (notification.type) {
        case 'event':
          return const Color(0xFF2563EB);
        case 'meeting':
          return const Color(0xFF7C3AED);
        case 'lead':
          return const Color(0xFF10B981);
        default:
          return Colors.grey;
      }
    }

    IconData getTypeIcon() {
      switch (notification.type) {
        case 'event':
          return Icons.event;
        case 'meeting':
          return Icons.meeting_room;
        case 'lead':
          return Icons.people;
        default:
          return Icons.notifications;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification.isRead
            ? (isDark ? AppColors.grey800 : Colors.white)
            : (isDark ? AppColors.grey800.withOpacity(0.8) : const Color(0xFFF0F7FF)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!notification.isRead)
            BoxShadow(
              color: getTypeColor().withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: getTypeColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                getTypeIcon(),
                size: 24,
                color: getTypeColor(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: getTypeColor(),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getTimeAgo(notification.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[500] : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (diff.inDays >= 1) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}