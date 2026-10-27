import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:golden_roost/core/database/database_helper.dart';
import 'package:golden_roost/core/sync/sync_service.dart';
import 'package:golden_roost/models/feed.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => '.',
    );
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Feed Idempotency & Stock Validation Regression Tests', () {
    late DatabaseHelper dbHelper;

    setUp(() async {
      dbHelper = DatabaseHelper.instance;
      final db = await dbHelper.database;
      // Clear relevant tables for clean isolated test run
      await db.delete('feed_transactions');
      await db.delete('feed_inventory');
      await db.delete('finances');
      await db.delete('sync_outbox');
      await db.delete('sync_tombstones');
    });

    test('Duplicate feed purchase does not double stock or duplicate finance records', () async {
      final feedItem = FeedItem(
        id: 'feed_test_starter',
        name: 'Starter Mash 20%',
        feedType: 'starter',
        currentStockKg: 50.0,
        lowStockThresholdKg: 10.0,
        bagWeightKg: 50.0,
        costPerBag: 75.0,
        updatedAt: DateTime.now(),
      );
      await dbHelper.insertFeedItem(feedItem);

      final purchaseTx = FeedTransaction(
        id: 'tx_purchase_1001',
        feedId: 'feed_test_starter',
        date: DateTime.now(),
        type: 'purchase',
        quantityKg: 25.0,
        cost: 37.5,
        notes: 'Initial 25kg bag',
        createdAt: DateTime.now(),
      );

      // First execution
      await dbHelper.recordFeedTransaction(purchaseTx);

      var inventory = await dbHelper.getFeedInventory();
      var currentItem = inventory.firstWhere((i) => i.id == 'feed_test_starter');
      expect(currentItem.currentStockKg, equals(75.0)); // 50 + 25

      var finances = await (await dbHelper.database).query('finances', where: 'id = ?', whereArgs: ['fin_feed_tx_purchase_1001']);
      expect(finances.length, equals(1));

      // Duplicate execution (e.g. sync retry or double-click)
      await dbHelper.recordFeedTransaction(purchaseTx);

      inventory = await dbHelper.getFeedInventory();
      currentItem = inventory.firstWhere((i) => i.id == 'feed_test_starter');
      expect(currentItem.currentStockKg, equals(75.0), reason: 'Stock must remain 75.0 and NOT be increased to 100.0 on duplicate transaction');

      finances = await (await dbHelper.database).query('finances', where: 'id = ?', whereArgs: ['fin_feed_tx_purchase_1001']);
      expect(finances.length, equals(1), reason: 'Financial transactions must not be duplicated');
    });

    test('Duplicate feed consumption does not double deduct inventory', () async {
      final feedItem = FeedItem(
        id: 'feed_test_layer',
        name: 'Layer Pellets 16%',
        feedType: 'layer',
        currentStockKg: 100.0,
        lowStockThresholdKg: 20.0,
        bagWeightKg: 50.0,
        costPerBag: 60.0,
        updatedAt: DateTime.now(),
      );
      await dbHelper.insertFeedItem(feedItem);

      final consumeTx = FeedTransaction(
        id: 'tx_consume_2001',
        feedId: 'feed_test_layer',
        flockId: 'flock_layer_1',
        date: DateTime.now(),
        type: 'consumption',
        quantityKg: 15.0,
        notes: 'Daily ration',
        createdAt: DateTime.now(),
      );

      // First execution
      await dbHelper.recordFeedTransaction(consumeTx);

      var inventory = await dbHelper.getFeedInventory();
      var currentItem = inventory.firstWhere((i) => i.id == 'feed_test_layer');
      expect(currentItem.currentStockKg, equals(85.0)); // 100 - 15

      // Duplicate execution
      await dbHelper.recordFeedTransaction(consumeTx);

      inventory = await dbHelper.getFeedInventory();
      currentItem = inventory.firstWhere((i) => i.id == 'feed_test_layer');
      expect(currentItem.currentStockKg, equals(85.0), reason: 'Stock must remain 85.0 and NOT be decremented to 70.0');
    });

    test('Insufficient stock throws InsufficientFeedStockException and does not alter stock', () async {
      final feedItem = FeedItem(
        id: 'feed_test_quail',
        name: 'Quail Finisher',
        feedType: 'custom',
        currentStockKg: 10.0,
        lowStockThresholdKg: 5.0,
        bagWeightKg: 25.0,
        costPerBag: 50.0,
        updatedAt: DateTime.now(),
      );
      await dbHelper.insertFeedItem(feedItem);

      final excessiveTx = FeedTransaction(
        id: 'tx_excessive_3001',
        feedId: 'feed_test_quail',
        date: DateTime.now(),
        type: 'consumption',
        quantityKg: 25.0, // Requests 25kg when only 10kg is available
        notes: 'Excessive consumption attempt',
        createdAt: DateTime.now(),
      );

      expect(
        () => dbHelper.recordFeedTransaction(excessiveTx),
        throwsA(isA<InsufficientFeedStockException>()),
      );

      final inventory = await dbHelper.getFeedInventory();
      final currentItem = inventory.firstWhere((i) => i.id == 'feed_test_quail');
      expect(currentItem.currentStockKg, equals(10.0), reason: 'Stock must remain intact and NOT be clamped to zero on failed transaction');

      final txs = await dbHelper.getFeedTransactions(feedId: 'feed_test_quail');
      expect(txs.isEmpty, isTrue, reason: 'Transaction row must not be committed when exception is thrown');
    });

    test('Updating consumption transaction verifies available stock', () async {
      final feedItem = FeedItem(
        id: 'feed_test_grower',
        name: 'Grower Crumbles',
        feedType: 'grower',
        currentStockKg: 20.0,
        lowStockThresholdKg: 5.0,
        bagWeightKg: 50.0,
        costPerBag: 70.0,
        updatedAt: DateTime.now(),
      );
      await dbHelper.insertFeedItem(feedItem);

      final initialTx = FeedTransaction(
        id: 'tx_grower_4001',
        feedId: 'feed_test_grower',
        date: DateTime.now(),
        type: 'consumption',
        quantityKg: 5.0,
        notes: 'Initial 5kg',
        createdAt: DateTime.now(),
      );
      await dbHelper.recordFeedTransaction(initialTx);

      // Remaining stock is now 15kg. Total available if reversing initial 5kg is 20kg.
      final updatedExcessiveTx = initialTx.copyWith(quantityKg: 30.0); // 30kg exceeds 20kg available

      expect(
        () => dbHelper.updateFeedTransaction(updatedExcessiveTx, 5.0, 0.0),
        throwsA(isA<InsufficientFeedStockException>()),
      );
    });
  });

  group('SyncService Failure Safety Tests', () {
    setUp(() async {
      final db = await DatabaseHelper.instance.database;
      await db.delete('sync_outbox');
      await db.delete('sync_tombstones');
    });

    test('SyncService keeps outbox items when cloudAdapter is null', () async {
      await SyncService.instance.enqueueOperation(
        tableName: 'flocks',
        recordId: 'flock_test_sync',
        action: 'insert',
        data: {'name': 'Test Flock', 'species': 'chicken'},
      );

      final pendingBefore = await DatabaseHelper.instance.getPendingSyncItems();
      expect(pendingBefore.length, equals(1));

      // Attempt sync with isCloudConnected = true but cloudAdapter = null
      final result = await SyncService.instance.synchronize(
        isCloudConnected: true,
        cloudAdapter: null,
      );

      expect(result.status, equals(SyncStatus.error));
      final pendingAfter = await DatabaseHelper.instance.getPendingSyncItems();
      expect(pendingAfter.length, equals(1), reason: 'Pending outbox item must be retained when cloud adapter is not configured');
    });

    test('SyncService marks tombstones synced only upon remote acknowledgement', () async {
      await SyncService.instance.enqueueOperation(
        tableName: 'flocks',
        recordId: 'flock_deleted_test',
        action: 'delete',
        data: {'id': 'flock_deleted_test'},
      );

      var pendingTombstones = await DatabaseHelper.instance.getPendingTombstones();
      expect(pendingTombstones.length, equals(1));

      // Sync with failing tombstone adapter
      await SyncService.instance.synchronize(
        isCloudConnected: true,
        cloudAdapter: (item) async => true,
        cloudTombstoneAdapter: (tombstone) async => false, // Remote rejected tombstone
      );

      pendingTombstones = await DatabaseHelper.instance.getPendingTombstones();
      expect(pendingTombstones.length, equals(1), reason: 'Tombstone must remain pending if remote adapter returns false');

      // Sync with succeeding tombstone adapter
      await SyncService.instance.synchronize(
        isCloudConnected: true,
        cloudAdapter: (item) async => true,
        cloudTombstoneAdapter: (tombstone) async => true, // Remote accepted tombstone
      );

      pendingTombstones = await DatabaseHelper.instance.getPendingTombstones();
      expect(pendingTombstones.isEmpty, isTrue, reason: 'Tombstone marked synced only after remote confirmation');
    });
  });
}
