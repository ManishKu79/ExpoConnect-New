import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../events/presentation/providers/event_provider.dart';
import '../../../events/domain/entities/event.dart';
import '../../../leads/presentation/providers/lead_provider.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';

class ExhibitorHomeScreen extends ConsumerStatefulWidget {
  const ExhibitorHomeScreen({super.key});

  @override
  ConsumerState<ExhibitorHomeScreen> createState() => _ExhibitorHomeScreenState();
}

class _ExhibitorHomeScreenState extends ConsumerState<ExhibitorHomeScreen> {
  Map<String, dynamic> _leadStats = {};
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(eventListProvider.notifier).refresh();
      ref.read(unreadCountProvider.notifier).loadUnreadCount();
      _loadLeadStats();
    });
  }

  Future<void> _loadLeadStats() async {
    setState(() => _isLoadingStats = true);
    try {
      final repo = ref.read(leadRepositoryProvider);
      final stats = await repo.getLeadStats('');
      setState(() {
        _leadStats = stats;
        _isLoadingStats = false;
      });
    } catch (e) {
      print('❌ Load lead stats error: $e');
      setState(() => _isLoadingStats = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final eventsState = ref.watch(eventListProvider);
    final unreadCount = ref.watch(unreadCountProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter events where user is exhibitor
    final myEvents = eventsState.where((e) => e.organizerId == user?.id).toList();

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
                            'Welcome back, ${user?.firstName ?? 'Exhibitor'} 🚀',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage your leads and stall',
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
                                  user?.initials ?? 'E',
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
                        // Stats Row
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                icon: Icons.people,
                                label: 'Total Leads',
                                value: _isLoadingStats ? '...' : (_leadStats['total']?.toString() ?? '0'),
                                color: const Color(0xFF2563EB),
                                onTap: () => context.go('/leads'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.trending_up,
                                label: 'New Leads',
                                value: _isLoadingStats ? '...' : (_leadStats['new']?.toString() ?? '0'),
                                color: const Color(0xFF10B981),
                                onTap: () => context.go('/leads'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.check_circle,
                                label: 'Won',
                                value: _isLoadingStats ? '...' : (_leadStats['won']?.toString() ?? '0'),
                                color: const Color(0xFF7C3AED),
                                onTap: () => context.go('/leads'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                icon: Icons.event,
                                label: 'My Events',
                                value: myEvents.length.toString(),
                                color: const Color(0xFFF59E0B),
                                onTap: () => context.go('/my-events'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.qr_code_scanner,
                                label: 'Scan QR',
                                value: 'Scan',
                                color: const Color(0xFF06B6D4),
                                onTap: () => context.go('/qr-scanner'),
                              ),
                            ),
                          ],
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
                              label: 'Leads',
                              color: const Color(0xFF2563EB),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                              ),
                              onTap: () => context.go('/leads'),
                            ),
                            _ActionCard(
                              icon: Icons.qr_code_scanner,
                              label: 'Scan Visitor',
                              color: const Color(0xFF7C3AED),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)],
                              ),
                              onTap: () => context.go('/qr-scanner'),
                            ),
                            _ActionCard(
                              icon: Icons.event,
                              label: 'My Events',
                              color: const Color(0xFF06B6D4),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF06B6D4), Color(0xFF2563EB)],
                              ),
                              onTap: () => context.go('/my-events'),
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
                              icon: Icons.storefront,
                              label: 'My Stall',
                              color: const Color(0xFFF59E0B),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                              ),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Stall management coming soon!'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              },
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
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Recent Leads
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Leads',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go('/leads'),
                              child: const Text(
                                'View All',
                                style: TextStyle(
                                  color: Color(0xFF2563EB),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Lead List - Using FutureBuilder to fetch recent leads
                        FutureBuilder<Map<String, dynamic>>(
                          future: ref.read(leadRepositoryProvider).getLeads(
                            limit: 3,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.all(20),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }

                            if (snapshot.hasError) {
                              return Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.grey800 : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(Icons.error_outline, color: Colors.red),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Could not load leads',
                                      style: TextStyle(
                                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            final result = snapshot.data;
                            final leads = result?['leads'] as List? ?? [];

                            if (leads.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.grey800 : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.people_outline,
                                      size: 48,
                                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No leads yet',
                                      style: TextStyle(
                                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: () => context.go('/qr-scanner'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF2563EB),
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Scan Visitor QR'),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: leads.length > 3 ? 3 : leads.length,
                              itemBuilder: (context, index) {
                                final lead = leads[index];
                                return _LeadCard(
                                  lead: lead,
                                  isDark: isDark,
                                  onTap: () {
                                    context.go('/leads/${lead.id}');
                                  },
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
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
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
              ),
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

class _LeadCard extends StatelessWidget {
  final dynamic lead;
  final bool isDark;
  final VoidCallback onTap;

  const _LeadCard({
    required this.lead,
    required this.isDark,
    required this.onTap,
  });

  Color getStatusColor(String status) {
    switch (status) {
      case 'new':
        return Colors.blue;
      case 'contacted':
        return Colors.orange;
      case 'qualified':
        return Colors.purple;
      case 'won':
        return Colors.green;
      case 'lost':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getVisitorName() {
    final visitor = lead['visitor'];
    if (visitor == null) return 'Unknown';
    final firstName = visitor['firstName'] ?? '';
    final lastName = visitor['lastName'] ?? '';
    return '$firstName $lastName'.trim();
  }

  String getVisitorEmail() {
    final visitor = lead['visitor'];
    return visitor?['email'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final status = lead['status'] ?? 'new';
    final score = lead['score'] ?? 0;
    final event = lead['event'];
    final eventTitle = event?['title'] ?? 'Unknown Event';

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              child: Text(
                getVisitorName().isNotEmpty ? getVisitorName()[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getVisitorName(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    getVisitorEmail(),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                    ),
                  ),
                  Text(
                    eventTitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.grey[500] : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: getStatusColor(status),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$score%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: score > 70 ? Colors.green : score > 40 ? Colors.orange : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}