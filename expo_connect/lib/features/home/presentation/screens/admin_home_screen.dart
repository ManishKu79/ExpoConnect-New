import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2563EB),
              Color(0xFF7C3AED),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Row(
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
                            'Manage your platform',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Notification Icon with Badge
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            context.go('/notifications');
                          },
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
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
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                    // Profile Icon
                    GestureDetector(
                      onTap: () => context.go('/profile'),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage: user?.profilePicture != null
                              ? NetworkImage(user!.profilePicture!)
                              : null,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: user?.profilePicture == null
                              ? Text(
                                  user?.initials ?? 'A',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Main Content
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.grey900 : const Color(0xFFF1F5F9),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats Grid
                        statsState.when(
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (err, stack) => Center(
                            child: Text(
                              'Error loading stats',
                              style: TextStyle(color: isDark ? Colors.white : Colors.black),
                            ),
                          ),
                          data: (stats) {
                            if (stats == null) return const SizedBox.shrink();
                            return GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.9,
                              children: [
                                _StatsCard(
                                  title: 'Users',
                                  value: stats['totalUsers']?.toString() ?? '0',
                                  icon: Icons.people,
                                  color: const Color(0xFF2563EB),
                                  isDark: isDark,
                                  onTap: () => context.go('/admin/users'),
                                ),
                                _StatsCard(
                                  title: 'Events',
                                  value: stats['totalEvents']?.toString() ?? '0',
                                  icon: Icons.event,
                                  color: const Color(0xFF7C3AED),
                                  isDark: isDark,
                                  onTap: () => context.go('/admin/events'),
                                ),
                                _StatsCard(
                                  title: 'Leads',
                                  value: stats['totalLeads']?.toString() ?? '0',
                                  icon: Icons.people_outline,
                                  color: const Color(0xFF10B981),
                                  isDark: isDark,
                                  onTap: () => context.go('/admin/leads'),
                                ),
                                _StatsCard(
                                  title: 'Companies',
                                  value: stats['totalCompanies']?.toString() ?? '0',
                                  icon: Icons.business,
                                  color: const Color(0xFFF59E0B),
                                  isDark: isDark,
                                  onTap: () {},
                                ),
                                _StatsCard(
                                  title: 'Recent Users',
                                  value: stats['recentUsers']?.toString() ?? '0',
                                  icon: Icons.person_add,
                                  color: const Color(0xFF06B6D4),
                                  isDark: isDark,
                                  onTap: () => context.go('/admin/users'),
                                ),
                                _StatsCard(
                                  title: 'Recent Events',
                                  value: stats['recentEvents']?.toString() ?? '0',
                                  icon: Icons.event_note,
                                  color: const Color(0xFF8B5CF6),
                                  isDark: isDark,
                                  onTap: () => context.go('/admin/events'),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        // Quick Actions
                        Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.9,
                          children: [
                            _ActionCard(
                              icon: Icons.people,
                              label: 'Users',
                              color: const Color(0xFF2563EB),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                              ),
                              onTap: () => context.go('/admin/users'),
                            ),
                            _ActionCard(
                              icon: Icons.event,
                              label: 'Events',
                              color: const Color(0xFF7C3AED),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)],
                              ),
                              onTap: () => context.go('/admin/events'),
                            ),
                            _ActionCard(
                              icon: Icons.analytics,
                              label: 'Analytics',
                              color: const Color(0xFF10B981),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
                              ),
                              onTap: () => context.go('/analytics'),
                            ),
                            _ActionCard(
                              icon: Icons.qr_code_scanner,
                              label: 'Scan QR',
                              color: const Color(0xFFF59E0B),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                              ),
                              onTap: () => context.go('/qr-scanner'),
                            ),
                            _ActionCard(
                              icon: Icons.notifications,
                              label: 'Alerts',
                              color: unreadCount > 0 ? Colors.red : const Color(0xFF6366F1),
                              gradient: unreadCount > 0 
                                  ? const LinearGradient(
                                      colors: [Colors.red, Colors.orange],
                                    )
                                  : const LinearGradient(
                                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                    ),
                              onTap: () => context.go('/notifications'),
                            ),
                            _ActionCard(
                              icon: Icons.settings,
                              label: 'Settings',
                              color: const Color(0xFF64748B),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF64748B), Color(0xFF475569)],
                              ),
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
                            Text(
                              'Recent Activity',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                ref.read(recentActivityProvider.notifier).loadActivity();
                              },
                              child: const Text(
                                'Refresh',
                                style: TextStyle(
                                  color: Color(0xFF2563EB),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        activityState.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (err, stack) => Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.grey800 : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Error loading activity',
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ),
                          data: (activities) {
                            if (activities == null || activities.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.grey800 : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.hourglass_empty,
                                      size: 48,
                                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No recent activity',
                                      style: TextStyle(
                                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: activities.length > 5 ? 5 : activities.length,
                              itemBuilder: (context, index) {
                                final activity = activities[index];
                                return _ActivityCard(
                                  activity: activity,
                                  isDark: isDark,
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _StatsCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.grey800 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final dynamic activity;
  final bool isDark;

  const _ActivityCard({
    required this.activity,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = activity['color'] ?? '#64748B';
    final icon = activity['icon'] ?? 'info';

    IconData getIcon() {
      switch (icon) {
        case 'person_add':
          return Icons.person_add;
        case 'event':
          return Icons.event;
        case 'people':
          return Icons.people;
        default:
          return Icons.info_outline;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(int.parse('0xFF${color.substring(1)}')).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              getIcon(),
              size: 18,
              color: Color(int.parse('0xFF${color.substring(1)}')),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['type'] == 'user_registered'
                      ? '👤 ${activity['user']} registered'
                      : activity['type'] == 'event_created'
                          ? '📅 ${activity['title']} created'
                          : '💼 ${activity['visitor']} lead captured',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                if (activity['type'] == 'user_registered')
                  Text(
                    'Role: ${activity['role']}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                    ),
                  ),
                if (activity['type'] == 'event_created')
                  Text(
                    'Organizer: ${activity['organizer']}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                    ),
                  ),
                if (activity['type'] == 'lead_created')
                  Text(
                    'Event: ${activity['event']}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                    ),
                  ),
              ],
            ),
          ),
          Text(
            _getTimeAgo(activity['timestamp']),
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
          ),
        ],
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