import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  Future<void> showMarkingNotification({
    required String markingType,
    required String time,
  }) async {
    final typeLabels = {
      'work_in': 'entrada',
      'break_out': 'salida a colacion',
      'break_in': 'regreso de colacion',
      'work_out': 'salida',
    };

    final label = typeLabels[markingType] ?? 'asistencia';

    const androidDetails = AndroidNotificationDetails(
      'marking_channel',
      'Marcaciones',
      channelDescription: 'Notificaciones de marcaciones de asistencia',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Marcacion registrada',
      'Tu $label fue registrada a las $time',
      details,
    );
  }

  Future<void> showSyncNotification(int count) async {
    const androidDetails = AndroidNotificationDetails(
      'sync_channel',
      'Sincronizacion',
      channelDescription: 'Notificaciones de sincronizacion offline',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000 + 1,
      'Sincronizacion completada',
      '$count marcaciones sincronizadas correctamente',
      details,
    );
  }
}
