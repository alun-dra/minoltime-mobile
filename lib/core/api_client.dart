import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/auth_exceptions.dart';
import '../core/session_expiration_handler.dart';
import '../models/login_response.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';

class ApiClient {
  static const Duration _timeout = Duration(seconds: 15);

  const ApiClient();

  Future<Map<String, String>> _buildHeaders({
    bool requiresAuth = true,
  }) async {
    const sessionService = SessionService();
    final token = requiresAuth ? await sessionService.getAccessToken() : null;

    return {
      'Content-Type': 'application/json',
      if (requiresAuth && token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(
    String path, {
    bool requiresAuth = true,
    bool retryOnAuthFailure = true,
  }) async {
    final baseUrl = const AuthService().baseUrl;
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _buildHeaders(requiresAuth: requiresAuth);

    try {
      final response = await http.get(uri, headers: headers).timeout(_timeout);

      return await _processResponse(
        response: response,
        method: 'GET',
        path: path,
        requiresAuth: requiresAuth,
        retryOnAuthFailure: retryOnAuthFailure,
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

  Future<http.Response> post(
    String path, {
    Object? body,
    bool requiresAuth = true,
    bool retryOnAuthFailure = true,
  }) async {
    final baseUrl = const AuthService().baseUrl;
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _buildHeaders(requiresAuth: requiresAuth);

    try {
      final response = await http
          .post(
            uri,
            headers: headers,
            body: jsonEncode(body ?? <String, dynamic>{}),
          )
          .timeout(_timeout);

      return await _processResponse(
        response: response,
        method: 'POST',
        path: path,
        body: body,
        requiresAuth: requiresAuth,
        retryOnAuthFailure: retryOnAuthFailure,
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

  Future<http.Response> delete(
    String path, {
    Object? body,
    bool requiresAuth = true,
    bool retryOnAuthFailure = true,
  }) async {
    final baseUrl = const AuthService().baseUrl;
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _buildHeaders(requiresAuth: requiresAuth);

    try {
      final response = await http
          .delete(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);

      return await _processResponse(
        response: response,
        method: 'DELETE',
        path: path,
        body: body,
        requiresAuth: requiresAuth,
        retryOnAuthFailure: retryOnAuthFailure,
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

  Future<http.Response> _processResponse({
    required http.Response response,
    required String method,
    required String path,
    Object? body,
    required bool requiresAuth,
    required bool retryOnAuthFailure,
  }) async {
    if (response.statusCode != 401) {
      _handleErrors(response, requiresAuth: requiresAuth);
      return response;
    }

    if (!requiresAuth) {
      // Endpoint público (ej. marcación de asistencia): un 401 aquí significa
      // credencial/token de marcación inválido, no una sesión de usuario expirada.
      _handleErrors(response, requiresAuth: false);
      return response;
    }

    if (!retryOnAuthFailure) {
      await SessionExpirationHandler.handle();
      throw const SessionExpiredException();
    }

    final refreshed = await _tryRefreshUserSession();

    if (!refreshed) {
      await SessionExpirationHandler.handle();
      throw const SessionExpiredException();
    }

    return _retryRequest(
      method: method,
      path: path,
      body: body,
      requiresAuth: requiresAuth,
    );
  }

  Future<http.Response> _retryRequest({
    required String method,
    required String path,
    Object? body,
    required bool requiresAuth,
  }) async {
    switch (method) {
      case 'GET':
        return get(
          path,
          requiresAuth: requiresAuth,
          retryOnAuthFailure: false,
        );
      case 'POST':
        return post(
          path,
          body: body,
          requiresAuth: requiresAuth,
          retryOnAuthFailure: false,
        );
      case 'DELETE':
        return delete(
          path,
          body: body,
          requiresAuth: requiresAuth,
          retryOnAuthFailure: false,
        );
      default:
        throw const SessionExpiredException();
    }
  }

  Future<bool> _tryRefreshUserSession() async {
    const sessionService = SessionService();
    const authService = AuthService();

    final loginType = await sessionService.getLoginType();
    if (loginType != LoginType.user) {
      return false;
    }

    final refreshToken = await sessionService.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      final LoginResponse refreshed = await authService.refreshToken(
        refreshToken: refreshToken,
      );

      await sessionService.updateUserTokens(
        accessToken: refreshed.accessToken,
        refreshToken: refreshed.refreshToken,
        expiresAt: refreshed.expiresAt,
        refreshExpiresAt: refreshed.refreshExpiresAt,
        expiresIn: refreshed.expiresIn,
        tokenType: refreshed.tokenType,
        role: refreshed.role,
        username: refreshed.username,
      );

      return true;
    } catch (_) {
      return false;
    }
  }

  void _handleErrors(http.Response response, {bool requiresAuth = true}) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      return;
    }

    final backendMessage = _extractMessage(response);

    switch (statusCode) {
      case 400:
        throw ValidationException(
          backendMessage.isNotEmpty ? backendMessage : 'Solicitud inválida',
        );
      case 401:
        if (!requiresAuth) {
          throw ValidationException(
            backendMessage.isNotEmpty
                ? backendMessage
                : 'Datos de marcación inválidos',
          );
        }
        throw const SessionExpiredException();
      case 403:
        throw ValidationException(
          backendMessage.isNotEmpty
              ? backendMessage
              : 'No tienes permisos para acceder',
        );
      case 404:
        throw ValidationException(
          backendMessage.isNotEmpty ? backendMessage : 'Recurso no encontrado',
        );
      case 409:
        throw const FraudSuspicionException();
      case 422:
        throw ValidationException(
          backendMessage.isNotEmpty ? backendMessage : 'Datos inválidos',
        );
      case 429:
        throw RateLimitException(_extractRetryAfterSeconds(response));
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
              : 'Error en la petición ($statusCode)',
        );
    }
  }

  int? _extractRetryAfterSeconds(http.Response response) {
    final header = response.headers['retry-after'];
    if (header == null) return null;
    return int.tryParse(header.trim());
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