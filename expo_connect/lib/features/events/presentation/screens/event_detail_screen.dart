import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../providers/event_provider.dart';
import '../../domain/entities/event.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  bool _isRegistered = false;

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventDetailProvider(widget.eventId));
    final registrationState = ref.watch(eventRegistrationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: eventAsync.when(
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
                onPressed: () => ref.refresh(eventDetailProvider(widget.eventId)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (event) {
          return CustomScrollView(
            slivers: [
              // App Bar with Image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                stretch: true,
                backgroundColor: isDark ? AppColors.grey900 : Colors.white,
                leading: IconButton(
                  onPressed: () => context.go('/events'),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: event.banner != null && event.banner!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: event.banner!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: isDark ? AppColors.grey800 : AppColors.grey200,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark 
                                    ? [AppColors.grey800, AppColors.grey700]
                                    : [Colors.grey[300]!, Colors.grey[200]!],
                              ),
                            ),
                            child: const Icon(
                              Icons.broken_image,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark 
                                  ? [AppColors.grey800, AppColors.grey700]
                                  : [Colors.grey[300]!, Colors.grey[200]!],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.event,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                ),
              ),

              // Event Details
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.grey900 : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: event.status == 'published' || event.status == 'ongoing'
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  event.status == 'published' || event.status == 'ongoing'
                                      ? Icons.check_circle
                                      : Icons.pending,
                                  size: 14,
                                  color: event.status == 'published' || event.status == 'ongoing'
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  event.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: event.status == 'published' || event.status == 'ongoing'
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          if (event.isPublic)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'PUBLIC',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        event.title,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Description
                      Text(
                        event.description,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: isDark ? Colors.grey[400] : const Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Info Cards
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.grey800 : AppColors.grey50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _InfoRow(
                              icon: Icons.calendar_today,
                              label: 'Date',
                              value: '${event.startDate.day}/${event.startDate.month}/${event.startDate.year}',
                              isDark: isDark,
                            ),
                            const SizedBox(height: 8),
                            _InfoRow(
                              icon: Icons.access_time,
                              label: 'Time',
                              value: '${event.startDate.hour}:${event.startDate.minute.toString().padLeft(2, '0')} - ${event.endDate.hour}:${event.endDate.minute.toString().padLeft(2, '0')}',
                              isDark: isDark,
                            ),
                            if (event.location != null && event.location!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              _InfoRow(
                                icon: Icons.location_on,
                                label: 'Location',
                                value: event.location!,
                                isDark: isDark,
                              ),
                            ],
                            if (event.organizerName != null && event.organizerName!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              _InfoRow(
                                icon: Icons.person,
                                label: 'Organizer',
                                value: event.organizerName!,
                                isDark: isDark,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Stats Row
                      Row(
                        children: [
                          Expanded(
                            child: _StatItem(
                              icon: Icons.people,
                              label: 'Attendees',
                              value: event.registeredCount?.toString() ?? '0',
                              isDark: isDark,
                            ),
                          ),
                          Expanded(
                            child: _StatItem(
                              icon: Icons.attach_money,
                              label: 'Price',
                              value: event.ticketPrice != null 
                                  ? '\$${event.ticketPrice!.toStringAsFixed(0)}'
                                  : 'Free',
                              isDark: isDark,
                            ),
                          ),
                          Expanded(
                            child: _StatItem(
                              icon: Icons.category,
                              label: 'Categories',
                              value: event.categories.isNotEmpty 
                                  ? event.categories.length.toString() 
                                  : '0',
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Categories
                      if (event.categories.isNotEmpty) ...[
                        const Text(
                          'Categories',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: event.categories.map((category) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Register Button
                      CustomButton(
                        onPressed: registrationState
                            ? null
                            : () async {
                                try {
                                  await ref.read(eventRegistrationProvider.notifier).register(event.id);
                                  setState(() {
                                    _isRegistered = true;
                                  });
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Successfully registered for event! 🎉'),
                                        backgroundColor: Color(0xFF10B981),
                                      ),
                                    );
                                    ref.refresh(eventDetailProvider(widget.eventId));
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                        text: _isRegistered ? '✅ Already Registered' : 'Register for Event',
                        isLoading: registrationState,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : AppColors.primary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isDark ? Colors.grey[400] : AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isDark ? Colors.grey[300] : const Color(0xFF334155),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : const Color(0xFF475569),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.grey700 : AppColors.grey200,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: isDark ? Colors.grey[400] : AppColors.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
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
    );
  }
}