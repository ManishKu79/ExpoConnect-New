import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../providers/admin_provider.dart';

class AdminLeadsScreen extends ConsumerStatefulWidget {
  const AdminLeadsScreen({super.key});

  @override
  ConsumerState<AdminLeadsScreen> createState() => _AdminLeadsScreenState();
}

class _AdminLeadsScreenState extends ConsumerState<AdminLeadsScreen> {
  String? _selectedStatus;
  int _page = 1;
  bool _isLoading = false;
  List<dynamic> _leads = [];
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadLeads();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadLeads({bool refresh = false}) async {
    if (_isLoading || (!_hasMore && !refresh)) return;
    setState(() => _isLoading = true);
    if (refresh) {
      _page = 1;
      _hasMore = true;
      _leads = [];
    }
    try {
      final repo = ref.read(adminRepositoryProvider);
      final result = await repo.getLeads(
        page: _page,
        limit: 20,
        status: _selectedStatus,
      );
      final leads = result['data'] ?? [];
      if (leads.length < 20) _hasMore = false;
      setState(() {
        _leads = refresh ? leads : [..._leads, ...leads];
        _page++;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Load leads error: $e');
      setState(() => _isLoading = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadLeads();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Leads'),
        backgroundColor: isDark ? AppColors.grey900 : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadLeads(refresh: true),
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: _selectedStatus == null,
                    onTap: () {
                      setState(() => _selectedStatus = null);
                      _loadLeads(refresh: true);
                    },
                    isDark: isDark,
                  ),
                  _FilterChip(
                    label: 'New',
                    selected: _selectedStatus == 'new',
                    onTap: () {
                      setState(() => _selectedStatus = 'new');
                      _loadLeads(refresh: true);
                    },
                    isDark: isDark,
                    color: Colors.blue,
                  ),
                  _FilterChip(
                    label: 'Contacted',
                    selected: _selectedStatus == 'contacted',
                    onTap: () {
                      setState(() => _selectedStatus = 'contacted');
                      _loadLeads(refresh: true);
                    },
                    isDark: isDark,
                    color: Colors.orange,
                  ),
                  _FilterChip(
                    label: 'Qualified',
                    selected: _selectedStatus == 'qualified',
                    onTap: () {
                      setState(() => _selectedStatus = 'qualified');
                      _loadLeads(refresh: true);
                    },
                    isDark: isDark,
                    color: Colors.purple,
                  ),
                  _FilterChip(
                    label: 'Won',
                    selected: _selectedStatus == 'won',
                    onTap: () {
                      setState(() => _selectedStatus = 'won');
                      _loadLeads(refresh: true);
                    },
                    isDark: isDark,
                    color: Colors.green,
                  ),
                  _FilterChip(
                    label: 'Lost',
                    selected: _selectedStatus == 'lost',
                    onTap: () {
                      setState(() => _selectedStatus = 'lost');
                      _loadLeads(refresh: true);
                    },
                    isDark: isDark,
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _leads.isEmpty && !_isLoading
                ? const EmptyStateWidget(
                    title: 'No Leads Found',
                    message: 'No leads match your filter criteria',
                    icon: Icons.people_outline,
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _leads.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _leads.length) {
                        return _isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            : const SizedBox.shrink();
                      }
                      final lead = _leads[index];
                      return _LeadCard(lead: lead, isDark: isDark);
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

class _LeadCard extends StatelessWidget {
  final dynamic lead;
  final bool isDark;

  const _LeadCard({
    required this.lead,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final visitor = lead['visitor'] ?? {};
    final event = lead['event'] ?? {};
    final status = lead['status'] ?? 'new';
    final score = lead['score'] ?? 0;
    final visitorName = '${visitor['firstName'] ?? ''} ${visitor['lastName'] ?? ''}'.trim();

    Color getStatusColor() {
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
          CircleAvatar(
            radius: 20,
            backgroundColor: getStatusColor().withOpacity(0.1),
            child: Text(
              visitorName.isNotEmpty ? visitorName[0].toUpperCase() : 'U',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: getStatusColor(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visitorName.isNotEmpty ? visitorName : 'Unknown Visitor',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  visitor['email'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[500],
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
                      event['title'] ?? 'Unknown Event',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                      ),
                    ),
                    const Spacer(),
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
        ],
      ),
    );
  }
}