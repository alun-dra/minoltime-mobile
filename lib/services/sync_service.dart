import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_client.dart';
import '../models/pending_marking.dart';

class SyncService {
  static const String _pendingKey = 'pending_markings';

  const SyncService();

  Future<void> savePendingMarking(PendingMarking marking) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await _loadAll(prefs);
    list.add(marking);
    await _saveAll(prefs, list);
  }

  Future<int> getPendingCount() async {
    final prefs = await SharedPreferences.getInstance();
    final list = await _loadAll(prefs);
    return list.where((m) => !m.synced).length;
  }

  Future<int> syncPendingMarkings() async {
    final prefs = await SharedPreferences.getInstance();
    final list = await _loadAll(prefs);
    final unsynced = list.where((m) => !m.synced).toList();

    if (unsynced.isEmpty) return 0;

    const apiClient = ApiClient();

    try {
      final body = unsynced.map((m) => m.toJson()..remove('synced')).toList();
      final response = await apiClient.post(
        '/api/v1/attendance/batch',
        body: {'items': body},
        requiresAuth: true,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final results = jsonDecode(response.body) as List<dynamic>;
        int syncedCount = 0;
        for (final result in results) {
          final status = result['status'] as String?;
          if (status == 'created' || status == 'duplicate') {
            final idx = result['index'] as int;
            if (idx >= 0 && idx < unsynced.length) {
              unsynced[idx].synced = true;
              syncedCount++;
            }
          }
        }
        await _saveAll(prefs, list);
        return syncedCount;
      }
    } catch (_) {
      // Will retry on next sync
    }

    return 0;
  }

  Future<void> clearSynced() async {
    final prefs = await SharedPreferences.getInstance();
    final list = await _loadAll(prefs);
    list.removeWhere((m) => m.synced);
    await _saveAll(prefs, list);
  }

  Future<List<PendingMarking>> _loadAll(SharedPreferences prefs) async {
    final raw = prefs.getString(_pendingKey);
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

  Future<void> _saveAll(SharedPreferences prefs, List<PendingMarking> list) async {
    final jsonString = jsonEncode(list.map((m) => m.toJson()).toList());
    await prefs.setString(_pendingKey, jsonString);
  }
}
