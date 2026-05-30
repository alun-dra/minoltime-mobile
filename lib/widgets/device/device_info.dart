import 'package:flutter/material.dart';

class DeviceInfo extends StatelessWidget {
  final String username;
  final String ipAddress;

  const DeviceInfo({
    super.key,
    required this.username,
    required this.ipAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Usuario: $username',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Dirección IP: $ipAddress',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.82),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}