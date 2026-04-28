import 'dart:convert';

import '../core/api_client.dart';
import '../models/me_response.dart';
import '../models/access_code_response.dart';

class UserService {
  const UserService();

  
  Future<MeResponse> getMe() async {
    const api = ApiClient();

    final response = await api.get('/api/v1/me');

    final data = jsonDecode(response.body);

    return MeResponse.fromJson(data);
  }

  Future<AccessCodeResponse> getAccessCode(int userId) async {
    const api = ApiClient();

    final response =
        await api.get('/api/v1/users/$userId/access-code');

    final data = jsonDecode(response.body);

    return AccessCodeResponse.fromJson(data);
  }
}