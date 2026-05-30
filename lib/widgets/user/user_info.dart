import 'package:flutter/material.dart';

class UserInfo extends StatelessWidget {
  final String username;
  final String fullName;

  const UserInfo({
    super.key,
    required this.username,
    required this.fullName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          fullName,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.95),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Usuario: $username',
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