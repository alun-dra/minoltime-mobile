import 'package:flutter/material.dart';

import '../widgets/user/user_action_button.dart';
import '../widgets/user/user_header.dart';
import '../widgets/user/user_info.dart';
import 'user_access_code_screen.dart';
import 'user_marks_screen.dart';
import 'user_qr_screen.dart';

class UserPanelScreen extends StatelessWidget {
  const UserPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF7A1FEA),
              Color(0xFF9B2CF3),
              Color(0xFFC12DFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const UserHeader(
                      title: 'Panel del usuario',
                      subtitle: 'Bienvenido',
                    ),
                    const SizedBox(height: 16),
                    const UserInfo(
                      username: 'alvaro.villalobos',
                      fullName: 'Álvaro Villalobos',
                    ),
                    const SizedBox(height: 28),
                    UserActionButton(
                      text: 'Generar QR',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UserQrScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    UserActionButton(
                      text: 'Ver código de acceso',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UserAccessCodeScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    UserActionButton(
                      text: 'Ver marcaciones',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UserMarksScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}