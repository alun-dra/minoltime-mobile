import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/local_qr_session.dart';
import '../models/qr_session_response.dart';

class QrSessionService {
  static const String _keyQrSession = 'active_qr_session';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  const QrSessionService();

  Future<void> saveQrSession(QrSessionResponse response) async {
    final expiresAt = DateTime.now()
        .add(Duration(seconds: response.expiresIn))
        .toIso8601String();

    final localSession = LocalQrSession(
      token: response.token,
      expiresIn: response.expiresIn,
      expiresAt: expiresAt,
    );

    await _secureStorage.write(
      key: _keyQrSession,
      value: jsonEncode(localSession.toJson()),
    );
  }

  Future<LocalQrSession?> getQrSession() async {
    final raw = await _secureStorage.read(key: _keyQrSession);

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
    await _secureStorage.delete(key: _keyQrSession);
  }
}
