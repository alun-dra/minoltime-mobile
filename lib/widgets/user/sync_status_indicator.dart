import 'package:flutter/material.dart';

import '../../core/offline_sync_manager.dart';
import '../../services/sync_service.dart';

class SyncStatusIndicator extends StatefulWidget {
  const SyncStatusIndicator({super.key});

  @override
  State<SyncStatusIndicator> createState() => _SyncStatusIndicatorState();
}

class _SyncStatusIndicatorState extends State<SyncStatusIndicator> {
  int _pendingCount = 0;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  Future<void> _loadCount() async {
    const syncService = SyncService();
    final count = await syncService.getPendingCount();
    if (mounted) {
      setState(() => _pendingCount = count);
    }
  }

  Future<void> _onTap() async {
    if (_syncing) return;
    setState(() => _syncing = true);

    try {
      await OfflineSyncManager().manualSync();
      await _loadCount();
    } finally {
      if (mounted) {
        setState(() => _syncing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_pendingCount == 0) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: _onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _syncing
              ? Colors.blue.withValues(alpha: 0.15)
              : Colors.orange.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _syncing ? Colors.blue.shade300 : Colors.orange.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_syncing)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.blue,
                ),
              )
            else
              Icon(
                Icons.cloud_upload_outlined,
                size: 16,
                color: Colors.orange.shade700,
              ),
            const SizedBox(width: 6),
            Text(
              _syncing ? 'Sincronizando...' : '$_pendingCount pendientes',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _syncing ? Colors.blue.shade700 : Colors.orange.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
