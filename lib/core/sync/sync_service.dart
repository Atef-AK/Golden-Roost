import 'dart:async';
import 'dart:convert';
import '../../models/sync_item.dart';
import '../database/database_helper.dart';

enum SyncStatus { idle, syncing, success, offline, error }

class SyncResult {
  final int syncedCount;
  final int failedCount;
  final String? errorMessage;
  final SyncStatus status;

  const SyncResult({
    required this.syncedCount,
    required this.failedCount,
    this.errorMessage,
    required this.status,
  });
}

class SyncService {
  static final SyncService instance = SyncService._internal();
  SyncService._internal();

  final _statusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get statusStream => _statusController.stream;

  SyncStatus _currentStatus = SyncStatus.idle;
  SyncStatus get currentStatus => _currentStatus;

  DateTime? _lastSyncTime;
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Enqueues a local entity mutation into the durable SQLite sync outbox
  Future<void> enqueueOperation({
    required String tableName,
    required String recordId,
    required String action, // 'insert', 'update', 'delete'
    required Map<String, dynamic> data,
  }) async {
    final idempotencyKey =
        '${tableName}_${recordId}_${action}_${DateTime.now().millisecondsSinceEpoch}';
    final syncItem = SyncItem(
      id: 'sync_${DateTime.now().millisecondsSinceEpoch}_${recordId.hashCode}',
      tableName: tableName,
      recordId: recordId,
      action: action,
      payload: jsonEncode(data),
      idempotencyKey: idempotencyKey,
      status: 'pending',
      attempts: 0,
      createdAt: DateTime.now(),
    );

    await DatabaseHelper.instance.queueSyncItem(syncItem);

    if (action == 'delete') {
      await DatabaseHelper.instance.recordTombstone(
        SyncTombstone(
          tableName: tableName,
          recordId: recordId,
          deletedAt: DateTime.now(),
          synced: false,
        ),
      );
    }
  }

  /// Synchronizes pending outbox items and tombstones with cloud storage adapter.
  /// Handles offline conditions, network retries, and records conflict resolution.
  Future<SyncResult> synchronize({
    bool isCloudConnected = false,
    Future<bool> Function(SyncItem item)? cloudAdapter,
    Future<bool> Function(SyncTombstone tombstone)? cloudTombstoneAdapter,
  }) async {
    if (_currentStatus == SyncStatus.syncing) {
      return SyncResult(syncedCount: 0, failedCount: 0, status: _currentStatus);
    }

    _setStatus(SyncStatus.syncing);

    // If cloud is not configured or disabled, keep items safely in SQLite outbox
    if (!isCloudConnected) {
      _setStatus(SyncStatus.offline);
      return const SyncResult(
        syncedCount: 0,
        failedCount: 0,
        status: SyncStatus.offline,
        errorMessage:
            'Device is offline or cloud sync is disabled. Pending items are safely persisted in SQLite.',
      );
    }

    final pendingItems = await DatabaseHelper.instance.getPendingSyncItems();
    final pendingTombstones = await DatabaseHelper.instance
        .getPendingTombstones();

    if (pendingItems.isEmpty && pendingTombstones.isEmpty) {
      _lastSyncTime = DateTime.now();
      _setStatus(SyncStatus.success);
      return const SyncResult(
        syncedCount: 0,
        failedCount: 0,
        status: SyncStatus.success,
      );
    }

    int syncedCount = 0;
    int failedCount = 0;
    String? firstError;

    if (pendingItems.isNotEmpty && cloudAdapter == null) {
      _setStatus(SyncStatus.error);
      return const SyncResult(
        syncedCount: 0,
        failedCount: 0,
        status: SyncStatus.error,
        errorMessage:
            'Cannot synchronize: No remote cloud adapter is configured. Outbox records preserved.',
      );
    }

    if (cloudAdapter != null) {
      for (final item in pendingItems) {
        try {
          final uploaded = await cloudAdapter(item);

          if (uploaded) {
            await DatabaseHelper.instance.deleteSyncItem(item.id);
            syncedCount++;
          } else {
            failedCount++;
            await DatabaseHelper.instance.updateSyncItem(
              item.copyWith(
                attempts: item.attempts + 1,
                lastAttempt: DateTime.now(),
                status: 'failed',
                errorMessage: 'Upload rejected by cloud adapter',
              ),
            );
          }
        } catch (e) {
          failedCount++;
          firstError ??= e.toString();
          await DatabaseHelper.instance.updateSyncItem(
            item.copyWith(
              attempts: item.attempts + 1,
              lastAttempt: DateTime.now(),
              status: 'failed',
              errorMessage: e.toString(),
            ),
          );
        }
      }
    }

    // Process tombstones only if a tombstone adapter is provided and confirms deletion
    if (pendingTombstones.isNotEmpty) {
      if (cloudTombstoneAdapter == null) {
        failedCount += pendingTombstones.length;
        firstError ??=
            'Cannot synchronize tombstones: No remote tombstone adapter is configured. Deletion records preserved locally.';
      } else {
        for (final tombstone in pendingTombstones) {
          try {
            final tombstoneSynced = await cloudTombstoneAdapter(tombstone);
            if (tombstoneSynced) {
              await DatabaseHelper.instance.markTombstoneSynced(
                tombstone.tableName,
                tombstone.recordId,
              );
              syncedCount++;
            } else {
              failedCount++;
              firstError ??= 'Tombstone deletion rejected by remote adapter';
            }
          } catch (e) {
            failedCount++;
            firstError ??= e.toString();
          }
        }
      }
    }

    _lastSyncTime = DateTime.now();

    // Verify whether any items or tombstones remain pending in SQLite
    final remainingItems = await DatabaseHelper.instance.getPendingSyncItems();
    final remainingTombstones = await DatabaseHelper.instance
        .getPendingTombstones();

    final isFullySynced =
        remainingItems.isEmpty &&
        remainingTombstones.isEmpty &&
        failedCount == 0;

    _setStatus(isFullySynced ? SyncStatus.success : SyncStatus.error);

    return SyncResult(
      syncedCount: syncedCount,
      failedCount: failedCount,
      errorMessage: firstError,
      status: _currentStatus,
    );
  }

  void _setStatus(SyncStatus status) {
    _currentStatus = status;
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
  }

  void dispose() {
    _statusController.close();
  }
}
