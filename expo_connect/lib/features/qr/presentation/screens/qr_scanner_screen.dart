import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../events/presentation/providers/event_provider.dart';

class QRScannerScreen extends ConsumerStatefulWidget {
  const QRScannerScreen({super.key});

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  bool _isVerifying = false;
  String? _scanResult;
  final TextEditingController _manualController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  Future<void> _verifyQR(String qrData) async {
    if (qrData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter or paste QR code data'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
      _scanResult = null;
    });

    try {
      final repo = ref.read(eventRepositoryProvider);
      final result = await repo.verifyEntryQR(qrData);
      
      print('📝 QR Verification Result: $result');
      
      setState(() {
        _scanResult = '✅ Entry Granted!';
        _isVerifying = false;
      });
      
      _showResultDialog(true, result);
    } catch (e) {
      print('❌ QR Verification error: $e');
      setState(() {
        _scanResult = '❌ Entry Denied';
        _isVerifying = false;
      });
      
      _showResultDialog(false, null);
    }
  }

  void _showResultDialog(bool success, dynamic data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: success ? Colors.green : Colors.red,
              size: 30,
            ),
            const SizedBox(width: 12),
            Text(
              success ? 'Entry Granted! ✅' : 'Entry Denied! ❌',
              style: TextStyle(
                color: success ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (success && data != null) ...[
              _buildInfoRow('Event', data['event']?['title'] ?? 'N/A'),
              const SizedBox(height: 4),
              _buildInfoRow('Visitor', data['user']?['name'] ?? 'N/A'),
              const SizedBox(height: 4),
              _buildInfoRow('Email', data['user']?['email'] ?? 'N/A'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '✅ Verified - Welcome to the event!',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 8),
              const Text(
                'Invalid QR Code',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This QR code is either invalid, expired, or the user is not registered.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '❌ Please try again with a valid QR code.',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _scanResult = null;
                _manualController.clear();
              });
            },
            child: const Text('Try Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
        backgroundColor: isDark ? AppColors.grey900 : Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.qr_code_scanner,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                'Verify Visitor Entry',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                'Enter or paste the QR code data from the visitor\'s entry pass',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // QR Data Input
              Container(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'QR Code Data',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _manualController,
                        decoration: InputDecoration(
                          hintText: 'Paste QR code data here...',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.grey[500] : Colors.grey[400],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: isDark ? AppColors.grey700 : AppColors.grey50,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        maxLines: 4,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Example QR Data Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: Colors.blue[700],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Example QR Data',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '{"type":"event_entry","eventId":"67a1b2c3...","userId":"67b2c3d4...","eventTitle":"Tech Expo 2024","userName":"John Doe"}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Verify Button
              CustomButton(
                onPressed: _isVerifying
                    ? null
                    : () {
                        if (_manualController.text.isNotEmpty) {
                          _verifyQR(_manualController.text);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter or paste QR code data'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      },
                text: 'Verify Entry',
                isLoading: _isVerifying,
              ),
              
              const SizedBox(height: 12),
              
              // Result Display
              if (_scanResult != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: _scanResult!.contains('✅')
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _scanResult!.contains('✅')
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _scanResult!.contains('✅')
                            ? Icons.check_circle
                            : Icons.error,
                        color: _scanResult!.contains('✅')
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _scanResult!,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _scanResult!.contains('✅')
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 24),
              
              // Back Button
              CustomButton(
                onPressed: () => context.go('/'),
                text: 'Back to Home',
                isOutlined: true,
              ),
              
              const SizedBox(height: 16),
              
              // Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or',
                      style: TextStyle(
                        color: isDark ? Colors.grey[500] : Colors.grey[400],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Upload QR Code Image Option
              InkWell(
                onTap: () async {
                  try {
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 800,
                    );
                    
                    if (image != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Image selected! Please enter the QR data manually.'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    }
                  } catch (e) {
                    print('❌ Image picker error: $e');
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.grey800 : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.grey700 : AppColors.grey200,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Upload QR Code Image',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}