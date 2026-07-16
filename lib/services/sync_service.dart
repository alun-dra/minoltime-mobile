import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/api_client.dart';
import '../models/pending_marking.dart';

class SyncService {
  static const String _pendingKey = 'pending_markings';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  const SyncService();

  Future<void> savePendingMarking(PendingMarking marking) async {
    final list = await _loadAll();
    list.add(marking);
    await _saveAll(list);
  }

  Future<int> getPendingCount() async {
    final list = await _loadAll();
    return list.where((m) => !m.synced).length;
  }

  Future<int> syncPendingMarkings() async {
    final list = await _loadAll();
    final unsynced = list.where((m) => !m.synced).toList();

    if (unsynced.isEmpty) return 0;

    const apiClient = ApiClient();

    try {
      final body = unsynced
          .map((m) => m.toJson()
            ..remove('synced')
            ..remove('last_error'))
          .toList();

      final response = await apiClient.post(
        '/api/v1/attendance/batch',
        body: body,
        requiresAuth: true,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final results = jsonDecode(response.body) as List<dynamic>;
        int syncedCount = 0;
        for (final result in results) {
          final status = result['status'] as String?;
          final idx = result['index'] as int?;
          if (idx == null || idx < 0 || idx >= unsynced.length) continue;

          if (status == 'created' || status == 'duplicate') {
            unsynced[idx].synced = true;
            unsynced[idx].lastError = null;
            syncedCount++;
          } else if (status == 'error') {
            unsynced[idx].lastError = result['error']?.toString();
          }
        }
        await _saveAll(list);
        return syncedCount;
      }
    } catch (_) {
      // Will retry on next sync
    }

    return 0;
  }

  Future<void> clearSynced() async {
    final list = await _loadAll();
    list.removeWhere((m) => m.synced);
    await _saveAll(list);
  }

  Future<List<PendingMarking>> _loadAll() async {
    final raw = await _secureStorage.read(key: _pendingKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final jsonList = jsonDecode(raw) as List<dynamic>;
      return jsonList
          .map((e) => PendingMarking.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAll(List<PendingMarking> list) async {
    final jsonString = jsonEncode(list.map((m) => m.toJson()).toList());
    await _secureStorage.write(key: _pendingKey, value: jsonString);
  }
}
