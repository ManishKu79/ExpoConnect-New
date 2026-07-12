import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final authNotifier = ref.read(authStateProvider.notifier);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    backgroundImage: user?.profilePicture != null
                        ? NetworkImage(user!.profilePicture!)
                        : null,
                    child: user?.profilePicture == null
                        ? Text(
                            user?.initials ?? '',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.fullName ?? 'User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user?.role.toUpperCase() ?? 'VISITOR',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Account settings
            _ProfileSection(
              title: 'Account Settings',
              children: [
                _ProfileTile(
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  onTap: () {},
                ),
                _ProfileTile(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  onTap: () {},
                ),
                _ProfileTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 16),

            // App settings
            _ProfileSection(
              title: 'App Settings',
              children: [
                _ProfileTile(
                  icon: Icons.color_lens_outlined,
                  title: 'Theme',
                  trailing: const Text('System'),
                  onTap: () {},
                ),
                _ProfileTile(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  trailing: const Text('English'),
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Support
            _ProfileSection(
              title: 'Support',
              children: [
                _ProfileTile(
                  icon: Icons.help_outline,
                  title: 'Help Center',
                  onTap: () {},
                ),
                _ProfileTile(
                  icon: Icons.feedback_outlined,
                  title: 'Send Feedback',
                  onTap: () {},
                ),
                _ProfileTile(
                  icon: Icons.info_outline,
                  title: 'About',
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Logout button
            OutlinedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          authNotifier.logout();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Logout'),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ProfileSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.grey600,
                ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}