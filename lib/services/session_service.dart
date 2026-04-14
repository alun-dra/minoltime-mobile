import 'package:shared_preferences/shared_preferences.dart';

import 'auth_service.dart';
import '../models/login_response.dart';

class SessionService {
  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUsername = 'username';
  static const _keyRole = 'role';
  static const _keyTokenType = 'token_type';
  static const _keyExpiresAt = 'expires_at';
  static const _keyRefreshExpiresAt = 'refresh_expires_at';
  static const _keyExpiresIn = 'expires_in';
  static const _keyLoginType = 'login_type';

  const SessionService();

  Future<void> saveSession({
    required LoginResponse response,
    required LoginType loginType,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_keyAccessToken, response.accessToken);
    await prefs.setString(_keyRefreshToken, response.refreshToken);
    await prefs.setString(_keyUsername, response.username);
    await prefs.setString(_keyRole, response.role);
    await prefs.setString(_keyTokenType, response.tokenType);
    await prefs.setString(_keyExpiresAt, response.expiresAt);
    await prefs.setString(_keyRefreshExpiresAt, response.refreshExpiresAt);
    await prefs.setInt(_keyExpiresIn, response.expiresIn);
    await prefs.setString(_keyLoginType, loginType.name);
  }

  Future<bool> hasSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyAccessToken);
    return token != null && token.isNotEmpty;
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole);
  }

  Future<LoginType?> getLoginType() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keyLoginType);

    if (value == null || value.isEmpty) return null;

    if (value == LoginType.device.name) {
      return LoginType.device;
    }

    return LoginType.user;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyTokenType);
    await prefs.remove(_keyExpiresAt);
    await prefs.remove(_keyRefreshExpiresAt);
    await prefs.remove(_keyExpiresIn);
    await prefs.remove(_keyLoginType);
  }
}