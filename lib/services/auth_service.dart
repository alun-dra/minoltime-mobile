import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/login_response.dart';

enum LoginType {
  user,
  device,
}

class AuthService {
  const AuthService();

  String get baseUrl {
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

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return LoginResponse.fromJson(data);
    }

    String message = 'Error al iniciar sesión';

    try {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['message'] != null) {
        message = data['message'].toString();
      }
    } catch (_) {}

    throw Exception(message);
  }
}