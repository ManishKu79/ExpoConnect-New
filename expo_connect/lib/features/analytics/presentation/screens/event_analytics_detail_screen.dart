import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../providers/analytics_provider.dart';

class EventAnalyticsDetailScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventAnalyticsDetailScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventAnalyticsDetailScreen> createState() => _EventAnalyticsDetailScreenState();
}

class _EventAnalyticsDetailScreenState extends ConsumerState<EventAnalyticsDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(eventAnalyticsProvider.notifier).loadEventAnalytics(widget.eventId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final analyticsState = ref.watch(eventAnalyticsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Analytics'),
        backgroundColor: isDark ? AppColors.grey900 : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(eventAnalyticsProvider.notifier).loadEventAnalytics(widget.eventId);
            },
          ),
        ],
      ),
      body: analyticsState.when(
        loading: () => const LoadingWidget(),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error: $err',
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(eventAnalyticsProvider.notifier).loadEventAnalytics(widget.eventId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (analytics) {
          if (analytics == null) {
            return const EmptyStateWidget(
              title: 'No Data Available',
              message: 'No analytics data for this event',
              icon: Icons.analytics,
            );
          }

          final registrations = analytics['registrations'] ?? {};
          final event = analytics['event'] ?? {};
          final attendees = analytics['attendees'] ?? {};
          final attendeeList = attendees['list'] ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['title'] ?? 'Event',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event['description'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event['startDate'] != null
                                ? DateTime.parse(event['startDate']).toString().split(' ')[0]
                                : 'TBD',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.event,
                            size: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            (event['status'] ?? 'draft').toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Registration Stats
                Text(
                  'Registration Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total Registrations',
                        value: (registrations['total'] ?? 0).toString(),
                        icon: Icons.people,
                        color: const Color(0xFF2563EB),
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Capacity',
                        value: (registrations['capacity'] ?? 0).toString(),
                        icon: Icons.settings,
                        color: const Color(0xFF7C3AED),
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Fill Rate',
                        value: '${registrations['capacityPercentage'] ?? 0}%',
                        icon: Icons.trending_up,
                        color: const Color(0xFF10B981),
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Recent',
                        value: (registrations['recent'] ?? 0).toString(),
                        icon: Icons.timer,
                        color: const Color(0xFFF59E0B),
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Registration Trend
                if (registrations['trend'] != null && registrations['trend'].isNotEmpty) ...[
                  Text(
                    'Registration Trend (Last 7 Days)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.grey800 : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: registrations['trend'].map<Widget>((day) {
                        return Column(
                          children: [
                            Text(
                              day['count'].toString(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              day['date'].toString().substring(5),
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? Colors.grey[400] : Colors.grey[500],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // Attendees List
                if (attendeeList.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Registered Attendees (${attendeeList.length})',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Show all attendees
                        },
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: attendeeList.length > 5 ? 5 : attendeeList.length,
                    itemBuilder: (context, index) {
                      final attendee = attendeeList[index];
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
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              backgroundImage: attendee['profilePicture'] != null
                                  ? NetworkImage(attendee['profilePicture'])
                                  : null,
                              child: attendee['profilePicture'] == null
                                  ? Text(
                                      (attendee['name'] ?? 'U')[0].toUpperCase(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    attendee['name'] ?? 'Unknown',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    attendee['email'] ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (attendee['registeredAt'] != null)
                              Text(
                                DateTime.parse(attendee['registeredAt']).toString().split(' ')[0],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark ? Colors.grey[400] : Colors.grey[500],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.grey[400] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}