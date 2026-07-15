import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../providers/admin_provider.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  String? _selectedRole;
  String _searchQuery = '';
  int _page = 1;
  bool _isLoading = false;
  List<dynamic> _users = [];
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadUsers({bool refresh = false}) async {
    if (_isLoading || (!_hasMore && !refresh)) return;
    setState(() => _isLoading = true);
    if (refresh) {
      _page = 1;
      _hasMore = true;
      _users = [];
    }
    try {
      final repo = ref.read(adminRepositoryProvider);
      final result = await repo.getUsers(
        page: _page,
        limit: 20,
        role: _selectedRole,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      final users = result['data'] ?? [];
      if (users.length < 20) _hasMore = false;
      setState(() {
        _users = refresh ? users : [..._users, ...users];
        _page++;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Load users error: $e');
      setState(() => _isLoading = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        backgroundColor: isDark ? AppColors.grey900 : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadUsers(refresh: true),
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
                    hintText: 'Search users...',
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
                              _loadUsers(refresh: true);
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                    _loadUsers(refresh: true);
                  },
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected: _selectedRole == null,
                        onTap: () {
                          setState(() => _selectedRole = null);
                          _loadUsers(refresh: true);
                        },
                        isDark: isDark,
                      ),
                      _FilterChip(
                        label: 'Visitor',
                        selected: _selectedRole == 'visitor',
                        onTap: () {
                          setState(() => _selectedRole = 'visitor');
                          _loadUsers(refresh: true);
                        },
                        isDark: isDark,
                        color: Colors.blue,
                      ),
                      _FilterChip(
                        label: 'Exhibitor',
                        selected: _selectedRole == 'exhibitor',
                        onTap: () {
                          setState(() => _selectedRole = 'exhibitor');
                          _loadUsers(refresh: true);
                        },
                        isDark: isDark,
                        color: Colors.purple,
                      ),
                      _FilterChip(
                        label: 'Organizer',
                        selected: _selectedRole == 'organizer',
                        onTap: () {
                          setState(() => _selectedRole = 'organizer');
                          _loadUsers(refresh: true);
                        },
                        isDark: isDark,
                        color: Colors.orange,
                      ),
                      _FilterChip(
                        label: 'Admin',
                        selected: _selectedRole == 'admin',
                        onTap: () {
                          setState(() => _selectedRole = 'admin');
                          _loadUsers(refresh: true);
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
            child: _users.isEmpty && !_isLoading
                ? const EmptyStateWidget(
                    title: 'No Users Found',
                    message: 'No users match your search criteria',
                    icon: Icons.people_outline,
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _users.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _users.length) {
                        return _isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            : const SizedBox.shrink();
                      }
                      final user = _users[index];
                      return _UserCard(user: user, isDark: isDark);
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

class _UserCard extends StatelessWidget {
  final dynamic user;
  final bool isDark;

  const _UserCard({
    required this.user,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final firstName = user['firstName'] ?? '';
    final lastName = user['lastName'] ?? '';
    final name = '$firstName $lastName'.trim();
    final email = user['email'] ?? '';
    final role = user['role'] ?? 'visitor';
    final isActive = user['isActive'] ?? true;

    Color getRoleColor() {
      switch (role) {
        case 'admin':
          return Colors.red;
        case 'organizer':
          return Colors.orange;
        case 'exhibitor':
          return Colors.purple;
        case 'visitor':
          return Colors.blue;
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
            radius: 24,
            backgroundColor: getRoleColor().withOpacity(0.1),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: getRoleColor(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isNotEmpty ? name : 'Unknown User',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: getRoleColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        role.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: getRoleColor(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isActive ? 'ACTIVE' : 'INACTIVE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.green : Colors.red,
                        ),
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