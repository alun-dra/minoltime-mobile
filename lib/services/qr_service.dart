import 'dart:convert';

import '../core/api_client.dart';
import '../models/qr_session_response.dart';

class QrService {
  const QrService();

  Future<QrSessionResponse> generateUserQr({
    required int userId,
  }) async {
    const apiClient = ApiClient();

    final response = await apiClient.post(
      '/api/v1/users/$userId/qr-session',
      body: {},
    );

    final data = jsonDecode(response.body);
    return QrSessionResponse.fromJson(data);
  }
}