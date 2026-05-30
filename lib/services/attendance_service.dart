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

    return ValidateQrResponse.fromJson(jsonDecode(response.body));
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

    return ValidateQrResponse.fromJson(jsonDecode(response.body));
  }

  Future<ValidateQrResponse> validateBarcode({
    required String barcode,
    required int accessPointId,
  }) async {
    const apiClient = ApiClient();

    final response = await apiClient.post(
      '/api/v1/attendance/validate-barcode',
      requiresAuth: false,
      body: {
        'barcode': barcode,
        'access_point_id': accessPointId,
      },
    );

    return ValidateQrResponse.fromJson(jsonDecode(response.body));
  }
}