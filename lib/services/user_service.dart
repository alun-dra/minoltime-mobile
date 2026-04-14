import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/me_response.dart';
import 'auth_service.dart';
import 'session_service.dart';

class UserService {
  const UserService();

  Future<MeResponse> getMe() async {
    const sessionService = SessionService();
    final token = await sessionService.getAccessToken();

    if (token == null) {
      throw Exception('No hay sesión activa');
    }

    final baseUrl = const AuthService().baseUrl;

    final uri = Uri.parse('$baseUrl/api/v1/me');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return MeResponse.fromJson(data);
    }

    throw Exception('Error al obtener datos del usuario');
  }
}