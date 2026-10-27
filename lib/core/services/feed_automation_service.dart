import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../utils/calculations.dart';
import '../../models/flock.dart';
import '../../models/feed.dart';
import '../../models/task_item.dart';

class FeedForecastResult {
  final Map<String, double> flockDemandsKg;
  final double totalDemandKg;

  const FeedForecastResult({
    required this.flockDemandsKg,
    required this.totalDemandKg,
  });
}

class FeedDeductionResult {
  final double deductedKg;
  final String feedName;
  final String targetName;
  final double remainingStockKg;
  final bool success;
  final bool isReconciled;

  const FeedDeductionResult({
    required this.deductedKg,
    required this.feedName,
    required this.targetName,
    required this.remainingStockKg,
    this.success = true,
    this.isReconciled = false,
  });
}

class FeedAutomationService {
  static final FeedAutomationService instance = FeedAutomationService._();
  FeedAutomationService._();

  static const String estimatedTag = '[ESTIMATED]';

  /// Pure, read-only calculation of projected daily feed demand.
  /// Never modifies inventory or writes transactions.
  FeedForecastResult forecastDailyDemand({required List<Flock> flocks}) {
    final demands = <String, double>{};
    double total = 0.0;

    for (final flock in flocks.where((f) => !f.isArchived && f.currentCount > 0)) {
      final demand = FarmCalculations.calculateFlockDailyDemandKg(
        birdCount: flock.currentCount,
        species: flock.species,
        purpose: flock.purpose,
        ageWeeks: flock.ageInWeeks,
        ageDays: flock.ageInDays,
      );
      demands[flock.id] = demand;
      total += demand;
    }

    return FeedForecastResult(
      flockDemandsKg: demands,
      totalDemandKg: total,
    );
  }

  /// Records an actual, verified feeding event for a flock.
  /// Reconciles with any prior auto-estimate for the same day to eliminate double-deduction.
  Future<FeedDeductionResult?> recordActualFeedConsumption({
    required String flockId,
    required String feedId,
    required double quantityKg,
    DateTime? date,
    String? notes,
  }) async {
    if (quantityKg <= 0.0) return null;
    final db = DatabaseHelper.instance;
    final now = date ?? DateTime.now();

    final inventory = await db.getFeedInventory();
    final feedItem = inventory.cast<FeedItem?>().firstWhere(
      (item) => item?.id == feedId,
      orElse: () => null,
    );
    if (feedItem == null) return null;

    final flock = await db.getFlockById(flockId);
    final targetName = flock?.name ?? 'Flock';

    // Check if an estimated auto-entry exists for this flock today
    final existingTxs = await db.getFeedTransactions(flockId: flockId);
    final estimatedToday = existingTxs.where((tx) {
      return tx.type == 'consumption' &&
          tx.notes.contains(estimatedTag) &&
          tx.date.year == now.year &&
          tx.date.month == now.month &&
          tx.date.day == now.day;
    }).toList();

    bool reconciled = false;
    double netDeductKg = quantityKg;

    // If an estimate existed, offset it to prevent double deduction
    if (estimatedToday.isNotEmpty) {
      for (final estTx in estimatedToday) {
        // Roll back estimated deduction in inventory
        final rolledBackStock = feedItem.currentStockKg + estTx.quantityKg;
        await db.updateFeedItem(
          feedItem.copyWith(currentStockKg: rolledBackStock, updatedAt: DateTime.now()),
        );
        // Delete estimated transaction so the actual entry supersedes it
        await db.deleteFeedTransaction(estTx.id);
        reconciled = true;
      }
    }

    // Now record actual consumption
    final tx = FeedTransaction(
      id: const Uuid().v4(),
      feedId: feedId,
      flockId: flockId,
      date: now,
      type: 'consumption',
      quantityKg: netDeductKg,
      notes: notes ?? 'Actual feeding recorded for $targetName',
      createdAt: DateTime.now(),
    );

    await db.recordFeedTransaction(tx);

    final refreshedItems = await db.getFeedInventory();
    final refreshedItem = refreshedItems.firstWhere((i) => i.id == feedId);

    return FeedDeductionResult(
      deductedKg: netDeductKg,
      feedName: feedItem.name,
      targetName: targetName,
      remainingStockKg: refreshedItem.currentStockKg,
      isReconciled: reconciled,
    );
  }

  /// Automatically calculates and reduces daily feed consumption across all active flocks.
  /// Accounts for actual live birds count (with mortality and sales already subtracted).
  /// Strictly checks if user enabled `autoFeedDeduction` in settings.
  /// Prevents duplicate deductions for the calendar day.
  Future<List<FeedDeductionResult>> syncDailyFeedConsumption({
    DateTime? forDate,
  }) async {
    final results = <FeedDeductionResult>[];
    final db = DatabaseHelper.instance;

    // Guard: strictly check user setting
    final settings = await db.getSettings();
    if (!settings.autoFeedDeduction) {
      debugPrint('[FeedAutomation] Auto feed deduction is disabled in settings. Skipping.');
      return results;
    }

    final now = forDate ?? DateTime.now();

    final allFlocks = await db.getFlocks();
    final activeFlocks = allFlocks.where((f) => !f.isArchived && f.currentCount > 0).toList();
    if (activeFlocks.isEmpty) return results;

    final inventory = await db.getFeedInventory();
    if (inventory.isEmpty) return results;

    for (final flock in activeFlocks) {
      // Check if consumption (actual or estimated) already logged for this flock on this day
      final existingTxs = await db.getFeedTransactions(flockId: flock.id);
      final alreadyLoggedToday = existingTxs.any((tx) {
        return tx.type == 'consumption' &&
            tx.date.year == now.year &&
            tx.date.month == now.month &&
            tx.date.day == now.day;
      });

      if (alreadyLoggedToday) continue;

      final demandKg = FarmCalculations.calculateFlockDailyDemandKg(
        birdCount: flock.currentCount,
        species: flock.species,
        purpose: flock.purpose,
        ageWeeks: flock.ageInWeeks,
        ageDays: flock.ageInDays,
      );

      if (demandKg <= 0.001) continue;

      final bestFeed = _findBestFeedItem(flock, inventory);
      if (bestFeed == null) continue;

      final deductKg = demandKg > bestFeed.currentStockKg
          ? bestFeed.currentStockKg
          : demandKg;

      if (deductKg <= 0.001) continue;

      final tx = FeedTransaction(
        id: const Uuid().v4(),
        feedId: bestFeed.id,
        flockId: flock.id,
        date: now,
        type: 'consumption',
        quantityKg: double.parse(deductKg.toStringAsFixed(2)),
        notes: '$estimatedTag Auto daily feeding (${flock.name}: ${flock.currentCount} birds, ${flock.ageInWeeks}w)',
        createdAt: DateTime.now(),
      );

      await db.recordFeedTransaction(tx);

      // Refresh local inventory instance stock
      final updatedStock = (bestFeed.currentStockKg - deductKg).clamp(0.0, 999999.0);
      final index = inventory.indexWhere((item) => item.id == bestFeed.id);
      if (index != -1) {
        inventory[index] = bestFeed.copyWith(currentStockKg: updatedStock);
      }

      results.add(
        FeedDeductionResult(
          deductedKg: deductKg,
          feedName: bestFeed.name,
          targetName: flock.name,
          remainingStockKg: updatedStock,
        ),
      );
    }

    return results;
  }

  /// Automatically deducts feed when a user marks a Feeding task as completed.
  Future<FeedDeductionResult?> deductForCompletedTask(TaskItem task) async {
    final db = DatabaseHelper.instance;
    final inventory = await db.getFeedInventory();
    if (inventory.isEmpty) return null;

    final allFlocks = await db.getFlocks();

    Flock? targetFlock;
    if (task.flockId != null) {
      targetFlock = allFlocks.cast<Flock?>().firstWhere(
        (f) => f?.id == task.flockId,
        orElse: () => null,
      );
    }

    double demandKg = 0.0;
    FeedItem? selectedFeed;
    String targetName = '';

    if (targetFlock != null && targetFlock.currentCount > 0) {
      targetName = targetFlock.name;
      demandKg = FarmCalculations.calculateFlockDailyDemandKg(
        birdCount: targetFlock.currentCount,
        species: targetFlock.species,
        purpose: targetFlock.purpose,
        ageWeeks: targetFlock.ageInWeeks,
        ageDays: targetFlock.ageInDays,
      );
      selectedFeed = _findBestFeedItem(targetFlock, inventory);
    } else {
      final activeFlocks = allFlocks.where((f) => !f.isArchived && f.currentCount > 0).toList();
      targetName = activeFlocks.isNotEmpty ? '${activeFlocks.length} Flocks' : 'Farm Flock';
      for (final f in activeFlocks) {
        demandKg += FarmCalculations.calculateFlockDailyDemandKg(
          birdCount: f.currentCount,
          species: f.species,
          purpose: f.purpose,
          ageWeeks: f.ageInWeeks,
          ageDays: f.ageInDays,
        );
      }
      if (demandKg <= 0.0) demandKg = 5.0; // Default fallback
      selectedFeed = inventory.firstWhere(
        (i) => i.currentStockKg > 0,
        orElse: () => inventory.first,
      );
    }

    if (selectedFeed == null || selectedFeed.currentStockKg <= 0) {
      return null;
    }

    final deductKg = demandKg > selectedFeed.currentStockKg
        ? selectedFeed.currentStockKg
        : demandKg;

    if (deductKg <= 0.01) return null;

    // Delegate to recordActualFeedConsumption to guarantee reconciliation if an estimate existed
    return await recordActualFeedConsumption(
      flockId: targetFlock?.id ?? (allFlocks.isNotEmpty ? allFlocks.first.id : 'flock_default'),
      feedId: selectedFeed.id,
      quantityKg: double.parse(deductKg.toStringAsFixed(2)),
      notes: 'Task completed: ${task.title} ($targetName)',
    );
  }

  FeedItem? _findBestFeedItem(Flock flock, List<FeedItem> inventory) {
    final withStock = inventory.where((i) => i.currentStockKg > 0).toList();
    if (withStock.isEmpty) return null;

    final pur = flock.purpose.toLowerCase();
    final species = flock.species.toLowerCase();

    // 1. Quail match
    if (species.contains('quail')) {
      final quailMatch = withStock.cast<FeedItem?>().firstWhere(
        (i) => i?.feedType == 'quail' || (i?.name.toLowerCase().contains('quail') ?? false),
        orElse: () => null,
      );
      if (quailMatch != null) return quailMatch;
    }

    // 2. Layer match
    if (pur.contains('layer') || pur.contains('egg')) {
      final layerMatch = withStock.cast<FeedItem?>().firstWhere(
        (i) => i?.feedType == 'layer' || (i?.name.toLowerCase().contains('layer') ?? false),
        orElse: () => null,
      );
      if (layerMatch != null) return layerMatch;
    }

    // 3. Broiler / Meat match
    if (pur.contains('meat') || pur.contains('broiler')) {
      final meatMatch = withStock.cast<FeedItem?>().firstWhere(
        (i) => i?.feedType == 'grower' || i?.feedType == 'starter',
        orElse: () => null,
      );
      if (meatMatch != null) return meatMatch;
    }

    // 4. Fallback to highest stock
    withStock.sort((a, b) => b.currentStockKg.compareTo(a.currentStockKg));
    return withStock.first;
  }
}
