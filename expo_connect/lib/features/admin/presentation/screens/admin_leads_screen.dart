import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
  bool _isLoading = true;
  List<dynamic> _leads = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLeads();
  }

  Future<void> _loadLeads() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = ref.read(adminRepositoryProvider);
      final leads = await repo.getLeads(
        status: _selectedStatus,
      );
      print('📝 Leads loaded: ${leads.length}');
      setState(() {
        _leads = leads;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Load leads error: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Leads'),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLeads,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? Colors.grey[900] : Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _StatusChip(
                    label: 'All',
                    selected: _selectedStatus == null,
                    onTap: () {
                      setState(() => _selectedStatus = null);
                      _loadLeads();
                    },
                    isDark: isDark,
                  ),
                  _StatusChip(
                    label: 'New',
                    selected: _selectedStatus == 'new',
                    onTap: () {
                      setState(() => _selectedStatus = 'new');
                      _loadLeads();
                    },
                    isDark: isDark,
                    color: Colors.blue,
                  ),
                  _StatusChip(
                    label: 'Contacted',
                    selected: _selectedStatus == 'contacted',
                    onTap: () {
                      setState(() => _selectedStatus = 'contacted');
                      _loadLeads();
                    },
                    isDark: isDark,
                    color: Colors.orange,
                  ),
                  _StatusChip(
                    label: 'Qualified',
                    selected: _selectedStatus == 'qualified',
                    onTap: () {
                      setState(() => _selectedStatus = 'qualified');
                      _loadLeads();
                    },
                    isDark: isDark,
                    color: Colors.purple,
                  ),
                  _StatusChip(
                    label: 'Won',
                    selected: _selectedStatus == 'won',
                    onTap: () {
                      setState(() => _selectedStatus = 'won');
                      _loadLeads();
                    },
                    isDark: isDark,
                    color: Colors.green,
                  ),
                  _StatusChip(
                    label: 'Lost',
                    selected: _selectedStatus == 'lost',
                    onTap: () {
                      setState(() => _selectedStatus = 'lost');
                      _loadLeads();
                    },
                    isDark: isDark,
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ),
          // Lead List
          Expanded(
            child: _isLoading
                ? const LoadingWidget()
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 60, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              'Error: $_error',
                              style: TextStyle(color: isDark ? Colors.white : Colors.black),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadLeads,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _leads.isEmpty
                        ? const EmptyStateWidget(
                            title: 'No Leads Found',
                            message: 'No leads match your filter criteria',
                            icon: Icons.people_outline,
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _leads.length,
                            itemBuilder: (context, index) {
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

class _StatusChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;
  final Color? color;

  const _StatusChip({
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
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? (color ?? AppColors.primary)
                : (isDark ? Colors.grey[800] : Colors.grey[200]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[700]),
            ),
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
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: getStatusColor().withOpacity(0.1),
            child: Text(
              visitorName.isNotEmpty ? visitorName[0].toUpperCase() : 'U',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: getStatusColor(),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visitorName.isNotEmpty ? visitorName : 'Unknown Visitor',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  visitor['email'] ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
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
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: score > 70
                            ? Colors.green.withOpacity(0.1)
                            : score > 40
                                ? Colors.orange.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$score%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: score > 70
                              ? Colors.green
                              : score > 40
                                  ? Colors.orange
                                  : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, size: 20),
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}