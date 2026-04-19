import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/login_response.dart';
import 'auth_service.dart';

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

  static const _keyDeviceId = 'device_id';
  static const _keyAccessPointId = 'access_point_id';
  static const _keyDirection = 'direction';
  static const _keyDeviceName = 'device_name';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  const SessionService();

  Future<void> saveSession({
    required LoginResponse response,
    required LoginType loginType,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await _secureStorage.write(
      key: _keyAccessToken,
      value: response.accessToken,
    );
    await _secureStorage.write(
      key: _keyRefreshToken,
      value: response.refreshToken,
    );

    await prefs.setString(_keyUsername, response.username);
    await prefs.setString(_keyRole, response.role);
    await prefs.setString(_keyTokenType, response.tokenType);
    await prefs.setString(_keyExpiresAt, response.expiresAt);
    await prefs.setString(_keyRefreshExpiresAt, response.refreshExpiresAt);
    await prefs.setInt(_keyExpiresIn, response.expiresIn);
    await prefs.setString(_keyLoginType, loginType.name);

    if (response.deviceId != null) {
      await prefs.setInt(_keyDeviceId, response.deviceId!);
    } else {
      await prefs.remove(_keyDeviceId);
    }

    if (response.accessPointId != null) {
      await prefs.setInt(_keyAccessPointId, response.accessPointId!);
    } else {
      await prefs.remove(_keyAccessPointId);
    }

    if (response.direction != null && response.direction!.isNotEmpty) {
      await prefs.setString(_keyDirection, response.direction!);
    } else {
      await prefs.remove(_keyDirection);
    }

    if (response.name != null && response.name!.isNotEmpty) {
      await prefs.setString(_keyDeviceName, response.name!);
    } else {
      await prefs.remove(_keyDeviceName);
    }
  }

  Future<bool> hasSession() async {
    final token = await _secureStorage.read(key: _keyAccessToken);
    return token != null && token.isNotEmpty;
  }

  Future<String?> getAccessToken() async {
    return _secureStorage.read(key: _keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: _keyRefreshToken);
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole);
  }

  Future<String?> getTokenType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyTokenType);
  }

  Future<String?> getExpiresAt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyExpiresAt);
  }

  Future<String?> getRefreshExpiresAt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshExpiresAt);
  }

  Future<int?> getExpiresIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyExpiresIn);
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

  Future<int?> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyDeviceId);
  }

  Future<int?> getAccessPointId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyAccessPointId);
  }

  Future<String?> getDirection() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDirection);
  }

  Future<String?> getDeviceName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDeviceName);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();

    await _secureStorage.delete(key: _keyAccessToken);
    await _secureStorage.delete(key: _keyRefreshToken);

    await prefs.remove(_keyUsername);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyTokenType);
    await prefs.remove(_keyExpiresAt);
    await prefs.remove(_keyRefreshExpiresAt);
    await prefs.remove(_keyExpiresIn);
    await prefs.remove(_keyLoginType);
    await prefs.remove(_keyDeviceId);
    await prefs.remove(_keyAccessPointId);
    await prefs.remove(_keyDirection);
    await prefs.remove(_keyDeviceName);
  }

  Future<void> updateUserTokens({
    required String accessToken,
    required String refreshToken,
    required String expiresAt,
    required String refreshExpiresAt,
    required int expiresIn,
    required String tokenType,
    required String role,
    required String username,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await _secureStorage.write(
      key: _keyAccessToken,
      value: accessToken,
    );
    await _secureStorage.write(
      key: _keyRefreshToken,
      value: refreshToken,
    );

    await prefs.setString(_keyExpiresAt, expiresAt);
    await prefs.setString(_keyRefreshExpiresAt, refreshExpiresAt);
    await prefs.setInt(_keyExpiresIn, expiresIn);
    await prefs.setString(_keyTokenType, tokenType);
    await prefs.setString(_keyRole, role);
    await prefs.setString(_keyUsername, username);
  }

  Future<bool> isUserSession() async {
    final loginType = await getLoginType();
    return loginType == LoginType.user;
  }
}