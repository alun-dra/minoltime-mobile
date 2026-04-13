import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../widgets/scanner/qr_header.dart';
import '../widgets/scanner/qr_overlay.dart';
import '../widgets/scanner/qr_frame.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _handled = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;

    final barcode =
        capture.barcodes.isNotEmpty ? capture.barcodes.first : null;

    final value = barcode?.rawValue;

    if (value == null || value.isEmpty) return;

    _handled = true;
    controller.stop();

    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Cámara
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),

          /// Overlay oscuro
          const QrOverlay(),

          /// UI
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