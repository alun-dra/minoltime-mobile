import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/auth_exceptions.dart';
import '../models/login_response.dart';

enum LoginType {
  user,
  device,
}

class AuthService {
  const AuthService();

  static const String _prodBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.minoltime.cl',
  );

  String get baseUrl {
    if (kReleaseMode) {
      return _prodBaseUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:8080';
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080';
    }

    return 'http://localhost:8080';
  }

  Future<LoginResponse> login({
    required String username,
    required String password,
    required LoginType loginType,
  }) async {
    final endpoint = loginType == LoginType.device
        ? '/api/v1/device-auth/login'
        : '/api/v1/auth/login';

    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'username': username,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      return _handleLoginResponse(response);
    } on TimeoutException {
      throw const RequestTimeoutException();
    } on SocketException {
      throw const NetworkException();
    } on HttpException {
      throw const NetworkException();
    } on HandshakeException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    } on FormatException {
      throw const GenericServerException();
    }
  }

  Future<LoginResponse> refreshToken({
    required String refreshToken,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/auth/refresh');

    try {
      final response = await http
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'refresh_token': refreshToken,
            }),
          )
          .timeout(const Duration(seconds: 15));

      return _handleLoginResponse(response);
    } on TimeoutException {
      throw const RequestTimeoutException();
    } on SocketException {
      throw const NetworkException();
    } on HttpException {
      throw const NetworkException();
    } on HandshakeException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    } on FormatException {
      throw const GenericServerException();
    }
  }

  Future<void> logoutUser({
    required String refreshToken,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/auth/logout');

    try {
      final response = await http
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'refresh_token': refreshToken,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      }

      if (response.statusCode == 401) {
        throw const SessionExpiredException();
      }

      final backendMessage = _extractMessage(response);

      throw ValidationException(
        backendMessage.isNotEmpty
            ? backendMessage
            : 'No se pudo cerrar la sesión remota',
      );
    } on TimeoutException {
      throw const RequestTimeoutException();
    } on SocketException {
      throw const NetworkException();
    } on HttpException {
      throw const NetworkException();
    } on HandshakeException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    } on FormatException {
      throw const GenericServerException();
    }
  }

  LoginResponse _handleLoginResponse(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      final data = jsonDecode(response.body);

      if (data is! Map<String, dynamic>) {
        throw const GenericServerException();
      }

      return LoginResponse.fromJson(data);
    }

    final backendMessage = _extractMessage(response);

    switch (statusCode) {
      case 400:
        throw ValidationException(
          backendMessage.isNotEmpty ? backendMessage : 'Solicitud inválida',
        );
      case 401:
        throw const InvalidCredentialsException();
      case 403:
        throw ValidationException(
          backendMessage.isNotEmpty
              ? backendMessage
              : 'No tienes permisos para acceder',
        );
      case 422:
        throw ValidationException(
          backendMessage.isNotEmpty ? backendMessage : 'Datos inválidos',
        );
      case 500:
        throw const GenericServerException();
      case 502:
      case 503:
      case 504:
        throw const ServerUnavailableException();
      default:
        throw ValidationException(
          backendMessage.isNotEmpty
              ? backendMessage
              : 'Error inesperado ($statusCode)',
        );
    }
  }

  String _extractMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        if (data['message'] != null) {
          return data['message'].toString();
        }

        if (data['error'] != null) {
          return data['error'].toString();
        }
      }

      return '';
    } catch (_) {
      final text = response.body.trim();
      if (text.isEmpty) return '';
      return text.length > 300 ? text.substring(0, 300) : text;
    }
  }
}