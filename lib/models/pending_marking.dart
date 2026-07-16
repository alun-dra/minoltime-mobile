import 'package:uuid/uuid.dart';

class PendingMarking {
  final String idempotencyKey;
  final String rut;
  final String pin;
  final int branchId;
  final int accessPointId;
  final String timestamp;
  final double? lat;
  final double? lng;
  final double? accuracy;
  bool synced;
  String? lastError;

  PendingMarking({
    String? idempotencyKey,
    required this.rut,
    required this.pin,
    required this.branchId,
    required this.accessPointId,
    String? timestamp,
    this.lat,
    this.lng,
    this.accuracy,
    this.synced = false,
    this.lastError,
  })  : idempotencyKey = idempotencyKey ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now().toUtc().toIso8601String();

  Map<String, dynamic> toJson() => {
        'idempotency_key': idempotencyKey,
        'rut': rut,
        'pin': pin,
        'branch_id': branchId,
        'access_point_id': accessPointId,
        'timestamp': timestamp,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        if (accuracy != null) 'accuracy': accuracy,
        'synced': synced,
        if (lastError != null) 'last_error': lastError,
      };

  factory PendingMarking.fromJson(Map<String, dynamic> json) => PendingMarking(
        idempotencyKey: json['idempotency_key'] as String,
        rut: json['rut'] as String,
        pin: json['pin'] as String,
        branchId: json['branch_id'] as int,
        accessPointId: json['access_point_id'] as int,
        timestamp: json['timestamp'] as String,
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
        accuracy: (json['accuracy'] as num?)?.toDouble(),
        synced: json['synced'] as bool? ?? false,
        lastError: json['last_error'] as String?,
      );
}
