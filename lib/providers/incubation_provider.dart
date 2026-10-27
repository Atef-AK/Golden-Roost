import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/database_helper.dart';
import '../models/incubation.dart';
import '../models/flock.dart';
import 'flock_provider.dart';

final incubationBatchesProvider =
    StateNotifierProvider<IncubationBatchesNotifier, List<IncubationBatch>>((
      ref,
    ) {
      return IncubationBatchesNotifier(ref);
    });

final incubationReadingsProvider =
    FutureProvider.family<List<IncubationReading>, String>((
      ref,
      batchId,
    ) async {
      return await DatabaseHelper.instance.getIncubationReadings(batchId);
    });

class IncubationBatchesNotifier extends StateNotifier<List<IncubationBatch>> {
  final Ref ref;

  IncubationBatchesNotifier(this.ref) : super([]) {
    loadBatches();
  }

  Future<void> loadBatches() async {
    final list = await DatabaseHelper.instance.getIncubationBatches();
    state = list;
  }

  Future<void> addBatch(IncubationBatch batch) async {
    await DatabaseHelper.instance.insertIncubationBatch(batch);
    await loadBatches();
  }

  Future<void> updateBatch(IncubationBatch batch) async {
    await DatabaseHelper.instance.updateIncubationBatch(batch);
    await loadBatches();
  }

  Future<void> deleteBatch(String id) async {
    await DatabaseHelper.instance.deleteIncubationBatch(id);
    await loadBatches();
  }

  Future<void> addReading(IncubationReading reading) async {
    await DatabaseHelper.instance.insertIncubationReading(reading);
  }

  /// Transfers hatched chicks directly into a new or existing flock without double counting
  Future<void> transferChicksToNewFlock({
    required IncubationBatch batch,
    required String newFlockName,
    required String housingLocation,
  }) async {
    if (batch.hatchedCount <= 0) return;

    final costPerChick = batch.costPerChick;
    final now = DateTime.now();

    final newFlock = Flock(
      id: 'flock_hatched_${batch.id}',
      name: newFlockName,
      species: batch.species,
      breed: '${batch.species} (Hatched in ${batch.incubatorName})',
      purpose: 'mixed',
      acquisitionDate: now,
      startCount: batch.hatchedCount,
      currentCount: batch.hatchedCount,
      maleCount: 0,
      femaleCount: 0,
      purchasePricePerBird: costPerChick,
      totalPurchaseCost: batch.totalBatchCost,
      supplier: 'Own Hatchery (${batch.incubatorName})',
      housingLocation: housingLocation,
      notes:
          'Hatched from batch ${batch.id}. Fertility: ${batch.fertilityRate.toStringAsFixed(1)}%, Hatch Rate: ${batch.hatchRateFromSet.toStringAsFixed(1)}%',
      createdAt: now,
    );

    // Save flock
    await ref.read(flocksProvider.notifier).addFlock(newFlock);

    // Mark batch as completed
    final updatedBatch = batch.copyWith(status: 'completed');
    await updateBatch(updatedBatch);
  }
}
