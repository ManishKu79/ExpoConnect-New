import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../providers/event_provider.dart';
import '../../domain/entities/event.dart';
import '../../../../shared/services/storage_service.dart';
import '../../../../core/constants/api_endpoints.dart';

class EditEventScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EditEventScreen({super.key, required this.eventId});

  @override
  ConsumerState<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends ConsumerState<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _venueController = TextEditingController();
  final _maxAttendeesController = TextEditingController();
  final _ticketPriceController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isPublic = true;
  bool _isLoading = false;
  bool _isUploadingImage = false;
  List<String> _selectedCategories = [];
  XFile? _newBannerImage;
  String? _currentBannerUrl;
  String? _uploadedImageUrl;
  Uint8List? _imageBytes;
  String? _imageFileName;
  Event? _event;

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

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    try {
      final repo = ref.read(eventRepositoryProvider);
      final event = await repo.getEventById(widget.eventId);
      setState(() {
        _event = event;
        _titleController.text = event.title;
        _descriptionController.text = event.description;
        _venueController.text = event.location ?? '';
        _startDate = event.startDate;
        _endDate = event.endDate;
        _selectedCategories = event.categories;
        _isPublic = event.isPublic;
        _currentBannerUrl = event.banner;
        _maxAttendeesController.text = event.maxAttendees?.toString() ?? '';
        _ticketPriceController.text = event.ticketPrice?.toString() ?? '';
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading event: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 600,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _newBannerImage = image;
          _imageFileName = image.name;
        });
        
        final bytes = await image.readAsBytes();
        setState(() {
          _imageBytes = bytes;
        });
        
        await _uploadBannerImage();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadBannerImage() async {
    if (_newBannerImage == null || _imageBytes == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final token = await StorageService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final formData = FormData.fromMap({
        'banner': MultipartFile.fromBytes(
          _imageBytes!,
          filename: _imageFileName ?? 'event_banner.jpg',
          contentType: DioMediaType.parse('image/jpeg'),
        ),
      });

      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';
      dio.options.headers['Content-Type'] = 'multipart/form-data';

      final response = await dio.post(
        '${ApiEndpoints.baseUrl}/upload/banner',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          setState(() {
            _uploadedImageUrl = data['data']['url'];
            _currentBannerUrl = data['data']['url'];
          });
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image uploaded successfully!'),
                backgroundColor: Color(0xFF10B981),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('❌ Image upload error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  Future<void> _updateEvent() async {
    if (!_formKey.currentState!.validate()) return;

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
        'ticketPrice': double.tryParse(_ticketPriceController.text) ?? 0.0,
        'isPublic': _isPublic,
        'banner': _currentBannerUrl ?? '',
      };

      final repo = ref.read(eventRepositoryProvider);
      await repo.updateEvent(widget.eventId, eventData);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event updated successfully! 🎉'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        ref.refresh(eventListProvider);
        ref.refresh(eventDetailProvider(widget.eventId));
        context.go('/events/${widget.eventId}');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating event: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteEvent() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        final repo = ref.read(eventRepositoryProvider);
        await repo.deleteEvent(widget.eventId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event deleted successfully'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
          ref.refresh(eventListProvider);
          context.go('/my-events');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting event: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
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

    if (_event == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Event'),
        backgroundColor: isDark ? AppColors.grey900 : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _deleteEvent,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Image Upload
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.grey800 : AppColors.grey100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.grey700 : AppColors.grey300,
                  ),
                ),
                child: _newBannerImage != null && _imageBytes != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                          ),
                          if (_isUploadingImage)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(color: Colors.white),
                                    SizedBox(height: 8),
                                    Text('Uploading...', style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _newBannerImage = null;
                                  _imageBytes = null;
                                });
                              },
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black.withOpacity(0.5),
                              ),
                              icon: const Icon(Icons.close, color: Colors.white),
                            ),
                          ),
                        ],
                      )
                    : _currentBannerUrl != null && _currentBannerUrl!.isNotEmpty
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: CachedNetworkImage(
                                  imageUrl: _currentBannerUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: isDark ? AppColors.grey700 : AppColors.grey300,
                                    child: const Center(child: CircularProgressIndicator()),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: isDark ? AppColors.grey700 : AppColors.grey300,
                                    child: const Icon(Icons.broken_image, size: 50),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  onPressed: _pickImage,
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.black.withOpacity(0.5),
                                  ),
                                  icon: const Icon(Icons.edit, color: Colors.white),
                                ),
                              ),
                            ],
                          )
                        : InkWell(
                            onTap: _pickImage,
                            borderRadius: BorderRadius.circular(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cloud_upload_outlined,
                                  size: 48,
                                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap to upload event banner',
                                  style: TextStyle(
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
              ),
              const SizedBox(height: 16),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Event Title *',
                  hintText: 'Enter event title',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: isDark ? AppColors.grey800 : AppColors.grey50,
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter event title' : null,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Enter event description',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: isDark ? AppColors.grey800 : AppColors.grey50,
                ),
                maxLines: 4,
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter event description' : null,
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
                    border: Border.all(color: isDark ? AppColors.grey700 : AppColors.grey200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Color(0xFF2563EB)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _startDate != null
                              ? 'Start: ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                              : 'Select Start Date *',
                          style: TextStyle(
                            color: _startDate != null ? (isDark ? Colors.white : Colors.black) : Colors.grey[500],
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
                    border: Border.all(color: isDark ? AppColors.grey700 : AppColors.grey200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Color(0xFF7C3AED)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _endDate != null
                              ? 'End: ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                              : 'Select End Date *',
                          style: TextStyle(
                            color: _endDate != null ? (isDark ? Colors.white : Colors.black) : Colors.grey[500],
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                onChanged: (value) => setState(() => _isPublic = value),
                activeColor: const Color(0xFF2563EB),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),

              // Update Button
              CustomButton(
                onPressed: _isLoading ? null : _updateEvent,
                text: 'Update Event',
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