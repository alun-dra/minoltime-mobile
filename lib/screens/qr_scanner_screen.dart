import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../widgets/scanner/qr_frame.dart';
import '../widgets/scanner/qr_header.dart';
import '../widgets/scanner/qr_overlay.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController controller = MobileScannerController(
    facing: CameraFacing.front,
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );

  bool _handled = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;

    if (capture.barcodes.isEmpty) return;

    final Barcode barcode = capture.barcodes.first;
    final String? value = barcode.rawValue;

    if (value == null || value.trim().isEmpty) return;

    _handled = true;
    controller.stop();

    Navigator.pop(context, value.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            fit: BoxFit.cover,
            onDetect: _onDetect,
          ),
          const QrOverlay(),
          SafeArea(
            child: Column(
              children: [
                QrHeader(
                  onBack: () => Navigator.pop(context),
                  onToggleFlash: () => controller.toggleTorch(),
                ),
                const Spacer(),
                const QrFrame(),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}