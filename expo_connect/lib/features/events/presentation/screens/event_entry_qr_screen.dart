import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../providers/event_provider.dart';

class EventEntryQRScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventEntryQRScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventEntryQRScreen> createState() => _EventEntryQRScreenState();
}

class _EventEntryQRScreenState extends ConsumerState<EventEntryQRScreen> {
  String? _qrCode;
  String? _eventTitle;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    print('🔵 ===== EVENT ENTRY QR SCREEN INIT =====');
    print('📝 Event ID received: "${widget.eventId}"');
    
    if (widget.eventId.isEmpty || 
        widget.eventId == 'undefined' || 
        widget.eventId == 'null') {
      setState(() {
        _error = 'Invalid event ID. Please go back and try again.';
        _isLoading = false;
      });
      print('❌ Invalid event ID');
    } else {
      print('✅ Valid event ID, loading QR...');
      _loadQRCode();
    }
  }

  Future<void> _loadQRCode() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('🔍 Loading QR code for event: ${widget.eventId}');
      
      final repo = ref.read(eventRepositoryProvider);
      final response = await repo.getEntryQR(widget.eventId);
      
      print('📝 Response received: $response');
      
      if (response == null) {
        throw Exception('No data received from server');
      }
      
      final qrCode = response['qrCode'];
      final eventTitle = response['eventTitle'];
      
      print('📝 QR Code: ${qrCode != null ? "Present (length: ${qrCode.length})" : "NULL"}');
      print('📝 Event Title: $eventTitle');
      
      if (qrCode == null || qrCode.isEmpty) {
        throw Exception('QR code is empty. Make sure you are registered for this event.');
      }
      
      setState(() {
        _qrCode = qrCode;
        _eventTitle = eventTitle ?? 'Event';
        _isLoading = false;
      });
      
      print('✅ QR Code loaded successfully');
    } catch (e) {
      print('❌ Load QR error: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    print('🔍 Building QR Screen - isLoading: $_isLoading, qrCode: ${_qrCode != null ? "Present" : "NULL"}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Entry QR'),
        backgroundColor: isDark ? AppColors.grey900 : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQRCode,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load QR Code',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Make sure you are registered for this event.',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          onPressed: _loadQRCode,
                          text: 'Retry',
                        ),
                        const SizedBox(height: 12),
                        CustomButton(
                          onPressed: () => context.go('/my-events'),
                          text: 'Back to My Events',
                          isOutlined: true,
                        ),
                      ],
                    ),
                  ),
                )
              : _qrCode != null && _qrCode.isNotEmpty
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
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
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 48,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'You are registered!',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  _eventTitle ?? 'Event',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    '✓ REGISTERED',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isDark ? AppColors.grey700 : AppColors.grey200,
                                    ),
                                  ),
                                  child: _qrCode!.startsWith('data:image')
                                      ? Image.memory(
                                          base64Decode(_qrCode!.split(',')[1]),
                                          height: 250,
                                          width: 250,
                                          fit: BoxFit.contain,
                                        )
                                      : Image.network(
                                          _qrCode!,
                                          height: 250,
                                          width: 250,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Icon(Icons.broken_image, size: 50);
                                          },
                                        ),
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.orange.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 20,
                                        color: Colors.orange[700],
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Show this QR code at the event entrance for check-in',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.orange[700],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('QR Code saved to gallery!'),
                                  backgroundColor: Color(0xFF10B981),
                                ),
                              );
                            },
                            text: 'Save QR to Gallery',
                            isOutlined: true,
                          ),
                          const SizedBox(height: 12),
                          CustomButton(
                            onPressed: () => context.go('/my-events'),
                            text: 'Back to My Events',
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.qr_code,
                            size: 80,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No QR Code Available',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please register for the event first.',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            onPressed: () => context.go('/events'),
                            text: 'Browse Events',
                          ),
                        ],
                      ),
                    ),
    );
  }
}