import 'package:flutter/material.dart';

class CardHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onToggleFlash;

  const CardHeader({
    super.key,
    required this.onBack,
    required this.onToggleFlash,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
          ),
          const Expanded(
            child: Text(
              'Leer tarjeta',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            onPressed: onToggleFlash,
            icon: const Icon(
              Icons.flash_on_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}