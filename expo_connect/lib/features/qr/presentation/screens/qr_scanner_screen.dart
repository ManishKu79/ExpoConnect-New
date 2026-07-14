import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/custom_button.dart';

class QRScannerScreen extends ConsumerStatefulWidget {
  const QRScannerScreen({super.key});

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
  );
  bool _isScanning = true;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: isDark ? AppColors.grey900 : Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                MobileScanner(
                  controller: cameraController,
                  onDetect: (capture) {
                    if (_isScanning) {
                      final List<Barcode> barcodes = capture.barcodes;
                      for (final barcode in barcodes) {
                        if (barcode.rawValue != null) {
                          setState(() {
                            _isScanning = false;
                          });
                          _handleScanResult(barcode.rawValue!);
                        }
                      }
                    }
                  },
                ),
                // Scanner overlay
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.qr_code_scanner,
                          color: Colors.white,
                          size: 50,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Align QR code within the frame',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.grey800 : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                CustomButton(
                  onPressed: () {
                    setState(() {
                      _isScanning = true;
                    });
                    cameraController.start();
                  },
                  text: 'Scan Again',
                  isOutlined: true,
                ),
                const SizedBox(height: 12),
                CustomButton(
                  onPressed: () => context.go('/'),
                  text: 'Back to Home',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleScanResult(String result) {
    // Show result dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code Scanned'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 50),
            const SizedBox(height: 16),
            Text('Result: $result'),
            const SizedBox(height: 8),
            const Text('This QR code contains the above data.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isScanning = true;
              });
              cameraController.start();
            },
            child: const Text('Scan Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/');
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}