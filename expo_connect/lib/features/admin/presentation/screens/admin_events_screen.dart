import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../providers/admin_provider.dart';

class AdminEventsScreen extends ConsumerStatefulWidget {
  const AdminEventsScreen({super.key});

  @override
  ConsumerState<AdminEventsScreen> createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends ConsumerState<AdminEventsScreen> {
  String? _selectedStatus;
  String _searchQuery = '';
  int _page = 1;
  bool _isLoading = false;
  List<dynamic> _events = [];
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadEvents({bool refresh = false}) async {
    if (_isLoading || (!_hasMore && !refresh)) return;
    setState(() => _isLoading = true);
    if (refresh) {
      _page = 1;
      _hasMore = true;
      _events = [];
    }
    try {
      final repo = ref.read(adminRepositoryProvider);
      final result = await repo.getEvents(
        page: _page,
        limit: 20,
        status: _selectedStatus,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      final events = result['data'] ?? [];
      if (events.length < 20) _hasMore = false;
      setState(() {
        _events = refresh ? events : [..._events, ...events];
        _page++;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Load events error: $e');
      setState(() => _isLoading = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Events'),
        backgroundColor: isDark ? AppColors.grey900 : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadEvents(refresh: true),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search events...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: isDark ? AppColors.grey800 : AppColors.grey50,
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() => _searchQuery = '');
                              _loadEvents(refresh: true);
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                    _loadEvents(refresh: true);
                  },
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected: _selectedStatus == null,
                        onTap: () {
                          setState(() => _selectedStatus = null);
                          _loadEvents(refresh: true);
                        },
                        isDark: isDark,
                      ),
                      _FilterChip(
                        label: 'Published',
                        selected: _selectedStatus == 'published',
                        onTap: () {
                          setState(() => _selectedStatus = 'published');
                          _loadEvents(refresh: true);
                        },
                        isDark: isDark,
                        color: Colors.green,
                      ),
                      _FilterChip(
                        label: 'Ongoing',
                        selected: _selectedStatus == 'ongoing',
                        onTap: () {
                          setState(() => _selectedStatus = 'ongoing');
                          _loadEvents(refresh: true);
                        },
                        isDark: isDark,
                        color: Colors.blue,
                      ),
                      _FilterChip(
                        label: 'Completed',
                        selected: _selectedStatus == 'completed',
                        onTap: () {
                          setState(() => _selectedStatus = 'completed');
                          _loadEvents(refresh: true);
                        },
                        isDark: isDark,
                        color: Colors.grey,
                      ),
                      _FilterChip(
                        label: 'Cancelled',
                        selected: _selectedStatus == 'cancelled',
                        onTap: () {
                          setState(() => _selectedStatus = 'cancelled');
                          _loadEvents(refresh: true);
                        },
                        isDark: isDark,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _events.isEmpty && !_isLoading
                ? const EmptyStateWidget(
                    title: 'No Events Found',
                    message: 'No events match your search criteria',
                    icon: Icons.event_busy,
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _events.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _events.length) {
                        return _isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            : const SizedBox.shrink();
                      }
                      final event = _events[index];
                      return _EventCard(event: event, isDark: isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.isDark,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        backgroundColor: isDark ? AppColors.grey800 : Colors.white,
        selectedColor: (color ?? AppColors.primary).withOpacity(0.2),
        labelStyle: TextStyle(
          color: selected
              ? (color ?? AppColors.primary)
              : (isDark ? Colors.white : Colors.black),
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
        checkmarkColor: color ?? AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: selected
                ? (color ?? AppColors.primary)
                : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
          ),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final dynamic event;
  final bool isDark;

  const _EventCard({
    required this.event,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final title = event['title'] ?? 'Untitled Event';
    final status = event['status'] ?? 'draft';
    final organizer = event['organizer'];
    final organizerName = organizer != null 
        ? '${organizer['firstName'] ?? ''} ${organizer['lastName'] ?? ''}'.trim()
        : 'Unknown';

    Color getStatusColor() {
      switch (status) {
        case 'published':
          return Colors.green;
        case 'ongoing':
          return Colors.blue;
        case 'completed':
          return Colors.grey;
        case 'cancelled':
          return Colors.red;
        default:
          return Colors.orange;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.event, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'By: $organizerName',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: getStatusColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: getStatusColor(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      event['createdAt'] != null
                          ? DateTime.parse(event['createdAt']).toString().split(' ')[0]
                          : '',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[500] : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: AppColors.primary,
            onPressed: () {
              // Show edit dialog
            },
          ),
        ],
      ),
    );
  }
}