import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../widgets/scanner/card_frame.dart';
import '../widgets/scanner/card_header.dart';
import '../widgets/scanner/qr_overlay.dart';

class CardScannerScreen extends StatefulWidget {
  const CardScannerScreen({super.key});

  @override
  State<CardScannerScreen> createState() => _CardScannerScreenState();
}

class _CardScannerScreenState extends State<CardScannerScreen> {
  final MobileScannerController controller = MobileScannerController(
    formats: [
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.itf14,
      BarcodeFormat.codabar,
    ],
  );

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
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),
          const QrOverlay(),
          SafeArea(
            child: Column(
              children: [
                CardHeader(
                  onBack: () => Navigator.pop(context),
                  onToggleFlash: () => controller.toggleTorch(),
                ),
                const Spacer(),
                const CardFrame(),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}