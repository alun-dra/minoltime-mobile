import 'package:flutter/material.dart';

import '../core/api_error_handler.dart';
import '../core/auth_exceptions.dart';
import '../models/me_response.dart';
import '../services/auth_service.dart';
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
  String? errorMessage;

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
        errorMessage = null;
      });
    } on AuthException catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.message;
      });

      ApiErrorHandler.handle(context, e);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'No se pudo cargar la información del usuario';
      });

      ApiErrorHandler.handle(
        context,
        const ValidationException('No se pudo cargar la información del usuario'),
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    const sessionService = SessionService();
    const authService = AuthService();

    try {
      final loginType = await sessionService.getLoginType();
      final refreshToken = await sessionService.getRefreshToken();

      if (loginType == LoginType.user &&
          refreshToken != null &&
          refreshToken.isNotEmpty) {
        await authService.logoutUser(
          refreshToken: refreshToken,
        );
      }
    } catch (_) {
      // Aunque falle el logout remoto, cerramos sesión local igual.
    }

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

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'Ocurrió un error inesperado',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 180,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    errorMessage = null;
                  });
                  _loadUser();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF5E1CCF),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Reintentar',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
              const SizedBox(height: 22),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyChild;

    if (isLoading) {
      bodyChild = const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    } else if (errorMessage != null && user == null) {
      bodyChild = _buildErrorState();
    } else {
      bodyChild = _buildContent(context);
    }

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
          child: bodyChild,
        ),
      ),
    );
  }
}