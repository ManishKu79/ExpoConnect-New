import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../domain/domain.dart';
import '../providers/event_provider.dart';

class EventDetailScreen extends ConsumerWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventDetailProvider(eventId));
    final registrationState = ref.watch(eventRegistrationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
      ),
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
                onPressed: () => ref.refresh(eventDetailProvider(eventId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (event) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event.banner != null && event.banner!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      event.banner!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 200,
                        color: isDark ? AppColors.grey800 : AppColors.grey200,
                        child: const Icon(Icons.broken_image, size: 60),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  event.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  event.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.calendar_today,
                  label: 'Date',
                  value: '${event.startDate.day}/${event.startDate.month}/${event.startDate.year}',
                  isDark: isDark,
                ),
                _InfoRow(
                  icon: Icons.access_time,
                  label: 'Time',
                  value: '${event.startDate.hour}:${event.startDate.minute.toString().padLeft(2, "0")} - ${event.endDate.hour}:${event.endDate.minute.toString().padLeft(2, "0")}',
                  isDark: isDark,
                ),
                if (event.location != null)
                  _InfoRow(
                    icon: Icons.location_on,
                    label: 'Location',
                    value: event.location!,
                    isDark: isDark,
                  ),
                if (event.organizerName != null)
                  _InfoRow(
                    icon: Icons.person,
                    label: 'Organizer',
                    value: event.organizerName!,
                    isDark: isDark,
                  ),
                if (event.ticketPrice != null)
                  _InfoRow(
                    icon: Icons.attach_money,
                    label: 'Ticket Price',
                    value: '\$${event.ticketPrice!.toStringAsFixed(2)}',
                    isDark: isDark,
                  ),
                if (event.registeredCount != null)
                  _InfoRow(
                    icon: Icons.people,
                    label: 'Attendees',
                    value: '${event.registeredCount} registered',
                    isDark: isDark,
                  ),
                const SizedBox(height: 24),
                CustomButton(
                  onPressed: registrationState
                      ? null
                      : () async {
                          try {
                            await ref.read(eventRegistrationProvider.notifier).register(event.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Registered successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              ref.refresh(eventDetailProvider(eventId));
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
                  text: 'Register for Event',
                  isLoading: registrationState,
                ),
                const SizedBox(height: 16),
              ],
            ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: isDark ? Colors.grey[400] : Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}