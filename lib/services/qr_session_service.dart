import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/local_qr_session.dart';
import '../models/qr_session_response.dart';

class QrSessionService {
  static const String _keyQrSession = 'active_qr_session';

  const QrSessionService();

  Future<void> saveQrSession(QrSessionResponse response) async {
    final prefs = await SharedPreferences.getInstance();

    final expiresAt = DateTime.now()
        .add(Duration(seconds: response.expiresIn))
        .toIso8601String();

    final localSession = LocalQrSession(
      token: response.token,
      expiresIn: response.expiresIn,
      expiresAt: expiresAt,
    );

    await prefs.setString(
      _keyQrSession,
      jsonEncode(localSession.toJson()),
    );
  }

  Future<LocalQrSession?> getQrSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyQrSession);

    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final session = LocalQrSession.fromJson(data);

      if (session.isExpired) {
        await clearQrSession();
        return null;
      }

      return session;
    } catch (_) {
      await clearQrSession();
      return null;
    }
  }

  Future<bool> hasValidQrSession() async {
    final session = await getQrSession();
    return session != null && !session.isExpired;
  }

  Future<void> clearQrSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyQrSession);
  }
}