import 'dart:convert';

import '../core/api_client.dart';
import '../models/me_response.dart';

class UserService {
  const UserService();

  Future<MeResponse> getMe() async {
    const api = ApiClient();

    final response = await api.get('/api/v1/me');

    final data = jsonDecode(response.body);

    return MeResponse.fromJson(data);
  }
}