import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../admin/presentation/providers/admin_provider.dart';

class AdminHomeScreen extends ConsumerStatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  ConsumerState<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends ConsumerState<AdminHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminStatsProvider.notifier).loadStats();
      ref.read(recentActivityProvider.notifier).loadActivity();
      ref.read(unreadCountProvider.notifier).loadUnreadCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final statsState = ref.watch(adminStatsProvider);
    final activityState = ref.watch(recentActivityProvider);
    final unreadCount = ref.watch(unreadCountProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // ============ TOP HEADER ============
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${user?.firstName ?? 'Admin'} 👑',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('EEEE, MMM d, yyyy').format(DateTime.now()),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Notification
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                              onPressed: () => context.go('/notifications'),
                            ),
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              right: 4,
                              top: 4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                child: Text(
                                  unreadCount > 9 ? '9+' : '$unreadCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      // Profile
                      GestureDetector(
                        onTap: () => context.go('/profile'),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: Text(
                            user?.initials ?? 'A',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Stats Cards
                  statsState.when(
                    loading: () => const SizedBox(
                      height: 80,
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                    error: (err, stack) => const SizedBox(
                      height: 80,
                      child: Center(
                        child: Text('Error loading stats', style: TextStyle(color: Colors.white70)),
                      ),
                    ),
                    data: (stats) {
                      if (stats == null) {
                        return const SizedBox(
                          height: 80,
                          child: Center(
                            child: Text('No data', style: TextStyle(color: Colors.white70)),
                          ),
                        );
                      }
                      return Row(
                        children: [
                          _DashboardStat(
                            value: stats['totalUsers']?.toString() ?? '0',
                            label: 'Users',
                            icon: Icons.people,
                            color: Colors.white,
                          ),
                          _DashboardStat(
                            value: stats['totalEvents']?.toString() ?? '0',
                            label: 'Events',
                            icon: Icons.event,
                            color: Colors.white,
                          ),
                          _DashboardStat(
                            value: stats['totalLeads']?.toString() ?? '0',
                            label: 'Leads',
                            icon: Icons.trending_up,
                            color: Colors.white,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ============ MAIN CONTENT ============
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Actions
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _QuickAction(
                          icon: Icons.people,
                          label: 'Users',
                          color: Colors.blue,
                          onTap: () => context.go('/admin/users'),
                        ),
                        _QuickAction(
                          icon: Icons.event,
                          label: 'Events',
                          color: Colors.purple,
                          onTap: () => context.go('/admin/events'),
                        ),
                        _QuickAction(
                          icon: Icons.analytics,
                          label: 'Analytics',
                          color: Colors.green,
                          onTap: () => context.go('/analytics'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _QuickAction(
                          icon: Icons.qr_code_scanner,
                          label: 'Scan QR',
                          color: Colors.orange,
                          onTap: () => context.go('/qr-scanner'),
                        ),
                        _QuickAction(
                          icon: Icons.notifications,
                          label: 'Alerts',
                          color: Colors.red,
                          onTap: () => context.go('/notifications'),
                        ),
                        _QuickAction(
                          icon: Icons.settings,
                          label: 'Settings',
                          color: Colors.grey,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Settings coming soon!'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Recent Activity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Activity',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ref.read(recentActivityProvider.notifier).loadActivity();
                          },
                          child: const Text('Refresh'),
                        ),
                      ],
                    ),
                    activityState.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (err, stack) => Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text('Could not load activity'),
                        ),
                      ),
                      data: (activities) {
                        if (activities == null || activities.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[800] : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text('No recent activity'),
                            ),
                          );
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: activities.length > 5 ? 5 : activities.length,
                          itemBuilder: (context, index) {
                            final activity = activities[index];
                            return _ActivityItem(activity: activity, isDark: isDark);
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ STAT CARD ============
class _DashboardStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _DashboardStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: Colors.white),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ QUICK ACTION ============
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ ACTIVITY ITEM ============
class _ActivityItem extends StatelessWidget {
  final dynamic activity;
  final bool isDark;

  const _ActivityItem({
    required this.activity,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final type = activity['type'] ?? '';
    final timestamp = activity['timestamp'];
    String timeAgo = 'Just now';
    if (timestamp != null) {
      final diff = DateTime.now().difference(DateTime.parse(timestamp));
      if (diff.inDays > 7) {
        timeAgo = DateFormat('MMM d').format(DateTime.parse(timestamp));
      } else if (diff.inDays >= 1) {
        timeAgo = '${diff.inDays}d ago';
      } else if (diff.inHours >= 1) {
        timeAgo = '${diff.inHours}h ago';
      } else if (diff.inMinutes >= 1) {
        timeAgo = '${diff.inMinutes}m ago';
      }
    }

    String title = '';
    String subtitle = '';
    IconData icon = Icons.person_add;
    Color iconColor = Colors.blue;

    if (type == 'user_registered') {
      title = '${activity['user'] ?? 'User'} registered';
      subtitle = 'New ${activity['role'] ?? 'user'} joined';
      icon = Icons.person_add;
      iconColor = Colors.blue;
    } else if (type == 'event_created') {
      title = '${activity['title'] ?? 'Event'} created';
      subtitle = 'By ${activity['organizer'] ?? 'organizer'}';
      icon = Icons.event;
      iconColor = Colors.purple;
    } else if (type == 'lead_created') {
      title = 'Lead from ${activity['visitor'] ?? 'visitor'}';
      subtitle = 'For ${activity['event'] ?? 'event'}';
      icon = Icons.people;
      iconColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            timeAgo,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}