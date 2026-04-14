import 'package:flutter/material.dart';

import '../screens/login_screen.dart';
import '../services/session_service.dart';
import 'app_navigator.dart';

class SessionExpirationHandler {
  const SessionExpirationHandler._();

  static bool _isHandling = false;

  static Future<void> handle() async {
    if (_isHandling) return;
    _isHandling = true;

    try {
      const sessionService = SessionService();
      await sessionService.clearSession();

      AppNavigator.scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Tu sesión ha expirado. Inicia sesión nuevamente'),
        ),
      );

      final navigator = AppNavigator.navigatorKey.currentState;
      if (navigator == null) return;

      navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    } finally {
      _isHandling = false;
    }
  }
}