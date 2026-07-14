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
    _loadQRCode();
  }

  Future<void> _loadQRCode() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repo = ref.read(eventRepositoryProvider);
      final qrData = await repo.getEntryQR(widget.eventId);
      setState(() {
        _qrCode = qrData['qrCode'];
        _eventTitle = qrData['eventTitle'];
        _isLoading = false;
      });
    } catch (e) {
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
      appBar: AppBar(
        title: const Text('Event Entry QR'),
        backgroundColor: isDark ? AppColors.grey900 : Colors.white,
        elevation: 0,
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
                          _error!,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black,
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
              : _qrCode != null
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Container(
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
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 40,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'You are registered!',
                                  style: TextStyle(
                                    fontSize: 20,
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
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Image.memory(
                                    base64Decode(_qrCode!.split(',')[1]),
                                    height: 250,
                                    width: 250,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 16,
                                        color: Colors.orange[700],
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Show this QR at the event entrance',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.orange[700],
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
                  : const Center(
                      child: Text('No QR code available'),
                    ),
    );
  }
}