import 'dart:convert';

import '../core/api_client.dart';
import '../core/auth_exceptions.dart';
import '../models/pending_marking.dart';
import '../models/validate_qr_response.dart';
import '../services/geofence_service.dart';
import '../services/notification_service.dart';
import '../services/sync_service.dart';

class AttendanceService {
  const AttendanceService();

  Future<Map<String, dynamic>?> _getGeoData() async {
    const geo = GeofenceService();
    final location = await geo.getCurrentLocation();
    if (location == null) return null;
    return {
      'lat': location.lat,
      'lng': location.lng,
      'accuracy': location.accuracy,
    };
  }

  Future<void> _showMarkingNotification(ValidateQrResponse result) async {
    final markingType = result.workOutAt != null
        ? 'work_out'
        : result.breakInAt != null
            ? 'break_in'
            : result.breakOutAt != null
                ? 'break_out'
                : 'work_in';
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    await NotificationService().showMarkingNotification(
      markingType: markingType,
      time: timeStr,
    );
  }

  Future<ValidateQrResponse> validateQr({
    required String token,
    required int accessPointId,
  }) async {
    const apiClient = ApiClient();
    final geoData = await _getGeoData();

    final body = <String, dynamic>{
      'token': token,
      'access_point_id': accessPointId,
    };
    if (geoData != null) body.addAll(geoData);

    final response = await apiClient.post(
      '/api/v1/attendance/validate-qr',
      requiresAuth: false,
      body: body,
    );

    final result = ValidateQrResponse.fromJson(jsonDecode(response.body));
    await _showMarkingNotification(result);
    return result;
  }

  Future<ValidateQrResponse> validateAccessCode({
    required String accessCode,
    required int accessPointId,
  }) async {
    const apiClient = ApiClient();
    final geoData = await _getGeoData();

    final body = <String, dynamic>{
      'access_code': accessCode,
      'access_point_id': accessPointId,
    };
    if (geoData != null) body.addAll(geoData);

    final response = await apiClient.post(
      '/api/v1/attendance/validate-access-code',
      requiresAuth: false,
      body: body,
    );

    final result = ValidateQrResponse.fromJson(jsonDecode(response.body));
    await _showMarkingNotification(result);
    return result;
  }

  Future<ValidateQrResponse> validateBarcode({
    required String barcode,
    required int accessPointId,
  }) async {
    const apiClient = ApiClient();
    final geoData = await _getGeoData();

    final body = <String, dynamic>{
      'barcode': barcode,
      'access_point_id': accessPointId,
    };
    if (geoData != null) body.addAll(geoData);

    final response = await apiClient.post(
      '/api/v1/attendance/validate-barcode',
      requiresAuth: false,
      body: body,
    );

    final result = ValidateQrResponse.fromJson(jsonDecode(response.body));
    await _showMarkingNotification(result);
    return result;
  }

  Future<ValidateQrResponse?> validateRutPinWithOffline({
    required String rut,
    required String pin,
    required int branchId,
    required int accessPointId,
  }) async {
    const apiClient = ApiClient();
    final geoData = await _getGeoData();

    final body = <String, dynamic>{
      'rut': rut,
      'pin': pin,
      'branch_id': branchId,
      'access_point_id': accessPointId,
    };
    if (geoData != null) body.addAll(geoData);

    try {
      final response = await apiClient.post(
        '/api/v1/attendance/validate-pin',
        requiresAuth: false,
        body: body,
      );
      final result = ValidateQrResponse.fromJson(jsonDecode(response.body));
      await _showMarkingNotification(result);
      return result;
    } on NetworkException {
      final pending = PendingMarking(
        rut: rut,
        pin: pin,
        branchId: branchId,
        accessPointId: accessPointId,
        lat: geoData?['lat'] as double?,
        lng: geoData?['lng'] as double?,
        accuracy: geoData?['accuracy'] as double?,
      );
      const syncService = SyncService();
      await syncService.savePendingMarking(pending);
      return null;
    }
  }
}