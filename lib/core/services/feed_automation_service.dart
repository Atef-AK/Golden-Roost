import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../utils/calculations.dart';
import '../../models/flock.dart';
import '../../models/feed.dart';
import '../../models/task_item.dart';

class FeedDeductionResult {
  final double deductedKg;
  final String feedName;
  final String targetName;
  final double remainingStockKg;
  final bool success;

  const FeedDeductionResult({
    required this.deductedKg,
    required this.feedName,
    required this.targetName,
    required this.remainingStockKg,
    this.success = true,
  });
}

class FeedAutomationService {
  static final FeedAutomationService instance = FeedAutomationService._();
  FeedAutomationService._();

  /// Automatically calculates and reduces daily feed consumption across all active flocks.
  /// Accounts for actual live birds count (with mortality and sales already subtracted).
  /// Safely checks if consumption has already been logged for the calendar day.
  Future<List<FeedDeductionResult>> syncDailyFeedConsumption({
    DateTime? forDate,
  }) async {
    final results = <FeedDeductionResult>[];
    final db = DatabaseHelper.instance;
    final now = forDate ?? DateTime.now();

    final allFlocks = await db.getFlocks();
    final activeFlocks = allFlocks.where((f) => !f.isArchived && f.currentCount > 0).toList();
    if (activeFlocks.isEmpty) return results;

    final inventory = await db.getFeedInventory();
    if (inventory.isEmpty) return results;

    for (final flock in activeFlocks) {
      // Check if consumption already logged for this flock on this day
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
        notes: 'Auto daily feeding (${flock.name}: ${flock.currentCount} birds, ${flock.ageInWeeks}w)',
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
      // General task: calculate across all active flocks or standard batch
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
      if (demandKg <= 0.0) demandKg = 5.0; // Default minimum fallback
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

    final tx = FeedTransaction(
      id: const Uuid().v4(),
      feedId: selectedFeed.id,
      flockId: targetFlock?.id,
      date: DateTime.now(),
      type: 'consumption',
      quantityKg: double.parse(deductKg.toStringAsFixed(2)),
      notes: 'Task done: ${task.title} ($targetName)',
      createdAt: DateTime.now(),
    );

    await db.recordFeedTransaction(tx);
    final remaining = (selectedFeed.currentStockKg - deductKg).clamp(0.0, 999999.0);

    return FeedDeductionResult(
      deductedKg: deductKg,
      feedName: selectedFeed.name,
      targetName: targetName,
      remainingStockKg: remaining,
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
