import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../providers/event_provider.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _venueController = TextEditingController();
  final _maxAttendeesController = TextEditingController();
  final _ticketPriceController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _registrationDeadline;
  bool _isPublic = true;
  bool _isLoading = false;
  List<String> _selectedCategories = [];

  final List<String> _availableCategories = [
    'Technology',
    'Business',
    'Art',
    'Music',
    'Sports',
    'Education',
    'Health',
    'Science',
    'Food',
    'Fashion',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _venueController.dispose();
    _maxAttendeesController.dispose();
    _ticketPriceController.dispose();
    super.dispose();
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start date')),
      );
      return;
    }

    if (_endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select end date')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final eventData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'startDate': _startDate!.toIso8601String(),
        'endDate': _endDate!.toIso8601String(),
        'location': {
          'venue': _venueController.text.trim(),
          'city': _locationController.text.trim(),
          'country': 'India',
        },
        'categories': _selectedCategories,
        'maxAttendees': int.tryParse(_maxAttendeesController.text) ?? 0,
        'registrationDeadline': _registrationDeadline?.toIso8601String(),
        'ticketPrice': double.tryParse(_ticketPriceController.text) ?? 0.0,
        'isPublic': _isPublic,
      };

      // Use the provider to create event
      final repo = ref.read(eventRepositoryProvider);
      await repo.createEvent(eventData);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event created successfully! 🎉'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        ref.refresh(eventListProvider);
        context.go('/');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating event: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        final dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        setState(() {
          if (isStart) {
            _startDate = dateTime;
          } else {
            _endDate = dateTime;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
        backgroundColor: isDark ? AppColors.grey900 : Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Event Title *',
                  hintText: 'Enter event title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.grey800 : AppColors.grey50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Enter event description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.grey800 : AppColors.grey50,
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Start Date
              InkWell(
                onTap: () => _selectDate(context, true),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.grey800 : AppColors.grey50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.grey700 : AppColors.grey200,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Color(0xFF2563EB)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _startDate != null
                              ? 'Start: ${_startDate!.day}/${_startDate!.month}/${_startDate!.year} ${_startDate!.hour}:${_startDate!.minute.toString().padLeft(2, '0')}'
                              : 'Select Start Date & Time *',
                          style: TextStyle(
                            color: _startDate != null
                                ? isDark ? Colors.white : Colors.black
                                : Colors.grey[500],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // End Date
              InkWell(
                onTap: () => _selectDate(context, false),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.grey800 : AppColors.grey50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.grey700 : AppColors.grey200,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Color(0xFF7C3AED)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _endDate != null
                              ? 'End: ${_endDate!.day}/${_endDate!.month}/${_endDate!.year} ${_endDate!.hour}:${_endDate!.minute.toString().padLeft(2, '0')}'
                              : 'Select End Date & Time *',
                          style: TextStyle(
                            color: _endDate != null
                                ? isDark ? Colors.white : Colors.black
                                : Colors.grey[500],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _venueController,
                decoration: InputDecoration(
                  labelText: 'Venue',
                  hintText: 'Enter venue name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.grey800 : AppColors.grey50,
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'City',
                  hintText: 'Enter city',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.grey800 : AppColors.grey50,
                ),
              ),
              const SizedBox(height: 16),

              // Categories
              Text(
                'Categories',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableCategories.map((category) {
                  final isSelected = _selectedCategories.contains(category);
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCategories.add(category);
                        } else {
                          _selectedCategories.remove(category);
                        }
                      });
                    },
                    backgroundColor: isDark ? AppColors.grey800 : AppColors.grey100,
                    selectedColor: const Color(0xFF2563EB).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF2563EB),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Max Attendees
              TextFormField(
                controller: _maxAttendeesController,
                decoration: InputDecoration(
                  labelText: 'Max Attendees',
                  hintText: 'Enter maximum attendees',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.grey800 : AppColors.grey50,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              // Ticket Price
              TextFormField(
                controller: _ticketPriceController,
                decoration: InputDecoration(
                  labelText: 'Ticket Price (USD)',
                  hintText: 'Enter ticket price',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.grey800 : AppColors.grey50,
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Public/Private
              SwitchListTile(
                title: const Text('Make Event Public'),
                subtitle: const Text('Public events are visible to everyone'),
                value: _isPublic,
                onChanged: (value) {
                  setState(() {
                    _isPublic = value;
                  });
                },
                activeColor: const Color(0xFF2563EB),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),

              // Create Button
              CustomButton(
                onPressed: _isLoading ? null : _createEvent,
                text: 'Create Event',
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}