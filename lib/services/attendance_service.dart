import 'dart:convert';

import '../core/api_client.dart';
import '../models/validate_qr_response.dart';

class AttendanceService {
  const AttendanceService();

  Future<ValidateQrResponse> validateQr({
    required String token,
    required int accessPointId,
  }) async {
    const apiClient = ApiClient();

    final response = await apiClient.post(
      '/api/v1/attendance/validate-qr',
      requiresAuth: false,
      body: {
        'token': token,
        'access_point_id': accessPointId,
      },
    );

    final data = jsonDecode(response.body);
    return ValidateQrResponse.fromJson(data);
  }

  Future<ValidateQrResponse> validateAccessCode({
    required String accessCode,
    required int accessPointId,
  }) async {
    const apiClient = ApiClient();

    final response = await apiClient.post(
      '/api/v1/attendance/validate-access-code',
      requiresAuth: false,
      body: {
        'access_code': accessCode,
        'access_point_id': accessPointId,
      },
    );

    final data = jsonDecode(response.body);
    return ValidateQrResponse.fromJson(data);
  }
}