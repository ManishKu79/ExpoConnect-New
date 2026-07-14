import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../providers/event_provider.dart';
import '../../domain/entities/event.dart';

class MyRegisteredEventsScreen extends ConsumerStatefulWidget {
  const MyRegisteredEventsScreen({super.key});

  @override
  ConsumerState<MyRegisteredEventsScreen> createState() => _MyRegisteredEventsScreenState();
}

class _MyRegisteredEventsScreenState extends ConsumerState<MyRegisteredEventsScreen> {
  @override
  void initState() {
    super.initState();
    print('🟢 ===== MY REGISTERED EVENTS SCREEN INIT =====');
    _loadEvents();
  }

  void _loadEvents() {
    print('🔄 Loading registered events...');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(myRegisteredEventsProvider.notifier).loadRegisteredEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventsState = ref.watch(myRegisteredEventsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    print('📊 Events State: ${eventsState.runtimeType}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
        backgroundColor: isDark ? AppColors.grey900 : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEvents,
          ),
        ],
      ),
      body: eventsState.when(
        loading: () {
          print('⏳ Loading events...');
          return const LoadingWidget();
        },
        error: (err, stack) {
          print('❌ Error loading events: $err');
          return Center(
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
                  onPressed: _loadEvents,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
        data: (events) {
          print('📝 Found ${events.length} registered events');
          events.forEach((event) {
            print('📝 Event: Title="${event.title}", ID="${event.id}"');
          });
          
          if (events.isEmpty) {
            print('📭 No registered events');
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const EmptyStateWidget(
                  title: 'No Registered Events',
                  message: 'You haven\'t registered for any events yet.\nBrowse events and register now!',
                  icon: Icons.event_busy,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/events'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text('Browse Events'),
                ),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return _RegisteredEventCard(
                event: event,
                onTap: () {
                  print('🔍 ===== EVENT CARD TAPPED =====');
                  print('📝 Event ID: "${event.id}"');
                  print('📝 Event Title: "${event.title}"');
                  
                  if (event.id.isNotEmpty && event.id != 'undefined' && event.id != 'null') {
                    print('✅ Navigating to event-entry/${event.id}');
                    context.go('/event-entry/${event.id}');
                  } else {
                    print('❌ Invalid event ID - cannot navigate');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error: Event ID not found'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _RegisteredEventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const _RegisteredEventCard({
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.banner != null && event.banner!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: event.banner!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 150,
                    color: isDark ? AppColors.grey700 : AppColors.grey200,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 150,
                    color: isDark ? AppColors.grey700 : AppColors.grey200,
                    child: const Icon(Icons.broken_image, size: 50),
                  ),
                ),
              )
            else
              Container(
                height: 100,
                width: double.infinity,
                color: isDark ? AppColors.grey700 : AppColors.grey200,
                child: const Icon(Icons.event, size: 50),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'REGISTERED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${event.startDate.day}/${event.startDate.month}/${event.startDate.year}',
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.location_on, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        event.location ?? 'Online',
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.qr_code,
                              size: 12,
                              color: Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'View QR',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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