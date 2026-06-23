import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../services/notification_service.dart';
import '../services/sync_service.dart';

class OfflineSyncManager {
  static final OfflineSyncManager _instance = OfflineSyncManager._internal();
  factory OfflineSyncManager() => _instance;
  OfflineSyncManager._internal();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _syncing = false;

  void initialize() {
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = results.any(
        (r) => r != ConnectivityResult.none,
      );
      if (hasConnection) {
        _trySyncPending();
      }
    });
  }

  Future<void> _trySyncPending() async {
    if (_syncing) return;
    _syncing = true;

    try {
      const syncService = SyncService();
      final pendingCount = await syncService.getPendingCount();
      if (pendingCount == 0) return;

      final syncedCount = await syncService.syncPendingMarkings();
      if (syncedCount > 0) {
        await syncService.clearSynced();
        await NotificationService().showSyncNotification(syncedCount);
      }
    } catch (_) {
      // Will retry on next connectivity change
    } finally {
      _syncing = false;
    }
  }

  Future<void> manualSync() async {
    await _trySyncPending();
  }

  void dispose() {
    _subscription?.cancel();
  }
}
