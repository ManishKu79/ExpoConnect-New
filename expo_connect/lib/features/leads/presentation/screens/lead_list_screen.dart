import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../providers/lead_provider.dart';
import '../../domain/entities/lead.dart';

class LeadListScreen extends ConsumerStatefulWidget {
  const LeadListScreen({super.key});

  @override
  ConsumerState<LeadListScreen> createState() => _LeadListScreenState();
}

class _LeadListScreenState extends ConsumerState<LeadListScreen> {
  String? _selectedStatus;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadLeads();
    _scrollController.addListener(_onScroll);
  }

  void _loadLeads() {
    ref.read(leadListProvider.notifier).loadLeads(status: _selectedStatus);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(leadListProvider.notifier).loadLeads(status: _selectedStatus);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leadsState = ref.watch(leadListProvider);
    final stats = ref.watch(leadStatsProvider(''));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leads'),
        backgroundColor: isDark ? AppColors.grey900 : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(leadListProvider.notifier).refresh(status: _selectedStatus);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _StatusChip(
                    label: 'All',
                    isSelected: _selectedStatus == null,
                    onTap: () {
                      setState(() {
                        _selectedStatus = null;
                      });
                      ref.read(leadListProvider.notifier).refresh(status: null);
                    },
                    isDark: isDark,
                  ),
                  _StatusChip(
                    label: 'New',
                    isSelected: _selectedStatus == 'new',
                    onTap: () {
                      setState(() {
                        _selectedStatus = 'new';
                      });
                      ref.read(leadListProvider.notifier).refresh(status: 'new');
                    },
                    isDark: isDark,
                    color: Colors.blue,
                  ),
                  _StatusChip(
                    label: 'Contacted',
                    isSelected: _selectedStatus == 'contacted',
                    onTap: () {
                      setState(() {
                        _selectedStatus = 'contacted';
                      });
                      ref.read(leadListProvider.notifier).refresh(status: 'contacted');
                    },
                    isDark: isDark,
                    color: Colors.orange,
                  ),
                  _StatusChip(
                    label: 'Qualified',
                    isSelected: _selectedStatus == 'qualified',
                    onTap: () {
                      setState(() {
                        _selectedStatus = 'qualified';
                      });
                      ref.read(leadListProvider.notifier).refresh(status: 'qualified');
                    },
                    isDark: isDark,
                    color: Colors.purple,
                  ),
                  _StatusChip(
                    label: 'Won',
                    isSelected: _selectedStatus == 'won',
                    onTap: () {
                      setState(() {
                        _selectedStatus = 'won';
                      });
                      ref.read(leadListProvider.notifier).refresh(status: 'won');
                    },
                    isDark: isDark,
                    color: Colors.green,
                  ),
                  _StatusChip(
                    label: 'Lost',
                    isSelected: _selectedStatus == 'lost',
                    onTap: () {
                      setState(() {
                        _selectedStatus = 'lost';
                      });
                      ref.read(leadListProvider.notifier).refresh(status: 'lost');
                    },
                    isDark: isDark,
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ),
          // Stats
          if (stats.asData?.value != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _StatChip(
                    label: 'Total',
                    value: stats.asData!.value['total']?.toString() ?? '0',
                    color: Colors.grey,
                    isDark: isDark,
                  ),
                  _StatChip(
                    label: 'New',
                    value: stats.asData!.value['new']?.toString() ?? '0',
                    color: Colors.blue,
                    isDark: isDark,
                  ),
                  _StatChip(
                    label: 'Won',
                    value: stats.asData!.value['won']?.toString() ?? '0',
                    color: Colors.green,
                    isDark: isDark,
                  ),
                  _StatChip(
                    label: 'Lost',
                    value: stats.asData!.value['lost']?.toString() ?? '0',
                    color: Colors.red,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          Expanded(
            child: leadsState.when(
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
                        ref.read(leadListProvider.notifier).refresh(status: _selectedStatus);
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
              data: (leads) {
                if (leads.isEmpty) {
                  return const EmptyStateWidget(
                    title: 'No Leads',
                    message: 'No leads found. Start scanning QR codes to capture leads.',
                    icon: Icons.people_outline,
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: leads.length + 1,
                  itemBuilder: (context, index) {
                    if (index == leads.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
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
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  final Color? color;

  const _StatusChip({
    required this.label,
    required this.isSelected,
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
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: isDark ? AppColors.grey800 : Colors.white,
        selectedColor: (color ?? const Color(0xFF2563EB)).withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected
              ? (color ?? const Color(0xFF2563EB))
              : (isDark ? Colors.white : Colors.black),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        checkmarkColor: color ?? const Color(0xFF2563EB),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected
                ? (color ?? const Color(0xFF2563EB))
                : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeadCard extends StatelessWidget {
  final Lead lead;
  final bool isDark;
  final VoidCallback onTap;

  const _LeadCard({
    required this.lead,
    required this.isDark,
    required this.onTap,
  });

  Color getStatusColor() {
    switch (lead.status) {
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

  String getStatusLabel() {
    switch (lead.status) {
      case 'new':
        return 'New';
      case 'contacted':
        return 'Contacted';
      case 'qualified':
        return 'Qualified';
      case 'won':
        return 'Won';
      case 'lost':
        return 'Lost';
      default:
        return lead.status;
    }
  }

  @override
  Widget build(BuildContext context) {
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
        border: Border.all(
          color: getStatusColor().withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: lead.visitorProfilePicture != null
                      ? NetworkImage(lead.visitorProfilePicture!)
                      : null,
                  child: lead.visitorProfilePicture == null
                      ? Text(
                          lead.visitorName.isNotEmpty ? lead.visitorName[0].toUpperCase() : 'U',
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
                        lead.visitorName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        lead.visitorEmail,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[400] : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                // Score
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: lead.score > 70
                        ? Colors.green.withOpacity(0.1)
                        : lead.score > 40
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${lead.score}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: lead.score > 70
                          ? Colors.green
                          : lead.score > 40
                              ? Colors.orange
                              : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    getStatusLabel(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: getStatusColor(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  lead.eventTitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                  ),
                ),
                const Spacer(),
                Text(
                  lead.createdAt.toString().split(' ')[0],
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                ),
              ],
            ),
            if (lead.notes.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                lead.notes,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}