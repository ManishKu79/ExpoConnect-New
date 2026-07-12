import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../auth/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ExpoConnect'),
        actions: [
          IconButton(
            onPressed: () {
              context.go('/profile');
            },
            icon: CircleAvatar(
              backgroundImage: authState.user?.profilePicture != null
                  ? NetworkImage(authState.user!.profilePicture!)
                  : null,
              child: authState.user?.profilePicture == null
                  ? Text(authState.user?.initials ?? '')
                  : null,
            ),
          ),
        ],
      ),
      body: authState.isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome message
                  Text(
                    'Welcome back, ${authState.user?.firstName ?? 'User'}!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Discover events and connect with businesses',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.grey600,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Quick actions grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _QuickActionCard(
                        icon: Icons.event,
                        label: 'Events',
                        onTap: () {
                          // Navigate to events
                        },
                      ),
                      _QuickActionCard(
                        icon: Icons.connect_without_contact,
                        label: 'Network',
                        onTap: () {
                          // Navigate to networking
                        },
                      ),
                      _QuickActionCard(
                        icon: Icons.people,
                        label: 'Leads',
                        onTap: () {
                          // Navigate to leads
                        },
                      ),
                      _QuickActionCard(
                        icon: Icons.calendar_today,
                        label: 'Meetings',
                        onTap: () {
                          // Navigate to meetings
                        },
                      ),
                      _QuickActionCard(
                        icon: Icons.analytics,
                        label: 'Analytics',
                        onTap: () {
                          // Navigate to analytics
                        },
                      ),
                      _QuickActionCard(
                        icon: Icons.qr_code_scanner,
                        label: 'Scan QR',
                        onTap: () {
                          // Navigate to QR scanner
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Upcoming events
                  Text(
                    'Upcoming Events',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.event,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tech Expo 2024',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                'March 15-17, 2024 • 50 Exhibitors',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.arrow_forward_ios),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}