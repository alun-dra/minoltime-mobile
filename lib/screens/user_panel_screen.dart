import 'package:flutter/material.dart';

import '../models/me_response.dart';
import '../services/session_service.dart';
import '../services/user_service.dart';
import '../widgets/user/user_action_button.dart';
import '../widgets/user/user_header.dart';
import '../widgets/user/user_info.dart';
import 'login_screen.dart';
import 'user_access_code_screen.dart';
import 'user_marks_screen.dart';
import 'user_qr_screen.dart';

class UserPanelScreen extends StatefulWidget {
  const UserPanelScreen({super.key});

  @override
  State<UserPanelScreen> createState() => _UserPanelScreenState();
}

class _UserPanelScreenState extends State<UserPanelScreen> {
  final UserService _userService = const UserService();

  MeResponse? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final response = await _userService.getMe();

      if (!mounted) return;

      setState(() {
        user = response;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    const sessionService = SessionService();
    await sessionService.clearSession();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

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
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : Center(
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 420),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 34,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          UserHeader(
                            title: user?.fullName ?? 'Usuario',
                            subtitle: 'Bienvenido',
                          ),
                          const SizedBox(height: 16),
                          UserInfo(
                            username: user?.username ?? '',
                            fullName: user?.fullName ?? '',
                          ),
                          const SizedBox(height: 28),

                          /// BOTONES
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
                                  builder: (_) =>
                                      const UserAccessCodeScreen(),
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

                          const SizedBox(height: 22),

                          /// LOGOUT
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () => _logout(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4D00C9),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Cerrar sesión',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
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