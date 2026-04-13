import 'package:flutter/material.dart';

class CardFrame extends StatelessWidget {
  const CardFrame({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 300,
          height: 140,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 3),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Apunta la cámara al código de barras',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'La tarjeta se leerá automáticamente',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}