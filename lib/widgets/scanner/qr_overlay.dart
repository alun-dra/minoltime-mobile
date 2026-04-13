import 'package:flutter/material.dart';

class QrOverlay extends StatelessWidget {
  const QrOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x99000000),
            Color(0x22000000),
            Color(0x99000000),
          ],
        ),
      ),
    );
  }
}