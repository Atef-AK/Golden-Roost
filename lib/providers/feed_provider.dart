import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/database_helper.dart';
import '../models/feed.dart';

final feedInventoryProvider =
    StateNotifierProvider<FeedInventoryNotifier, List<FeedItem>>((ref) {
      return FeedInventoryNotifier();
    });

final feedTransactionsProvider =
    FutureProvider.family<List<FeedTransaction>, String?>((ref, flockId) async {
      return await DatabaseHelper.instance.getFeedTransactions(
        flockId: flockId,
      );
    });

final waterCareLogsProvider = FutureProvider.family<List<WaterCareLog>, String>(
  (ref, flockId) async {
    return await DatabaseHelper.instance.getWaterCareLogs(flockId);
  },
);

class FeedInventoryNotifier extends StateNotifier<List<FeedItem>> {
  FeedInventoryNotifier() : super([]) {
    loadInventory();
  }

  Future<void> loadInventory() async {
    final list = await DatabaseHelper.instance.getFeedInventory();
    state = list;
  }

  Future<void> addFeedItem(FeedItem item) async {
    await DatabaseHelper.instance.insertFeedItem(item);
    await loadInventory();
  }

  Future<void> updateFeedItem(FeedItem item) async {
    await DatabaseHelper.instance.updateFeedItem(item);
    await loadInventory();
  }

  Future<void> deleteFeedItem(String id) async {
    await DatabaseHelper.instance.deleteFeedItem(id);
    await loadInventory();
  }

  Future<void> recordTransaction(FeedTransaction tx) async {
    await DatabaseHelper.instance.recordFeedTransaction(tx);
    await loadInventory();
  }

  Future<void> updateTransaction(
    FeedTransaction tx,
    double oldQuantityKg,
    double oldCost,
  ) async {
    await DatabaseHelper.instance.updateFeedTransaction(
      tx,
      oldQuantityKg,
      oldCost,
    );
    await loadInventory();
  }

  Future<void> deleteTransaction(String txId) async {
    await DatabaseHelper.instance.deleteFeedTransaction(txId);
    await loadInventory();
  }

  Future<void> logWaterCare(WaterCareLog log) async {
    await DatabaseHelper.instance.insertWaterCareLog(log);
  }
}
