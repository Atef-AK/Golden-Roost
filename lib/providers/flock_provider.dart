import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/database_helper.dart';
import '../models/flock.dart';
import '../models/bird_movement.dart';
import '../models/finance.dart';

final flocksProvider = StateNotifierProvider<FlocksNotifier, List<Flock>>((
  ref,
) {
  return FlocksNotifier();
});

final flockMovementsProvider =
    FutureProvider.family<List<BirdMovement>, String>((ref, flockId) async {
      return await DatabaseHelper.instance.getBirdMovements(flockId);
    });

class FlocksNotifier extends StateNotifier<List<Flock>> {
  FlocksNotifier() : super([]) {
    loadFlocks();
  }

  Future<void> loadFlocks({bool includeArchived = false}) async {
    final list = await DatabaseHelper.instance.getFlocks(
      includeArchived: includeArchived,
    );
    state = list;
  }

  Future<void> addFlock(Flock flock) async {
    await DatabaseHelper.instance.insertFlock(flock);

    // If purchase price > 0, record purchase expense
    if (flock.totalPurchaseCost > 0) {
      await DatabaseHelper.instance.insertFinance(
        FinancialTransaction(
          id: 'fin_flock_init_${flock.id}',
          type: 'expense',
          category: 'adult_birds',
          amount: flock.totalPurchaseCost,
          date: flock.acquisitionDate,
          flockId: flock.id,
          paymentStatus: 'paid',
          amountPaid: flock.totalPurchaseCost,
          notes: 'Initial flock purchase: ${flock.startCount} birds',
          createdAt: DateTime.now(),
        ),
      );
    }

    await loadFlocks();
  }

  Future<void> updateFlock(Flock flock) async {
    await DatabaseHelper.instance.updateFlock(flock);
    await loadFlocks();
  }

  Future<void> deleteFlock(String id) async {
    await DatabaseHelper.instance.deleteFlock(id);
    await loadFlocks();
  }

  Future<void> toggleArchive(Flock flock) async {
    final updated = flock.copyWith(isArchived: !flock.isArchived);
    await DatabaseHelper.instance.updateFlock(updated);
    await loadFlocks();
  }

  Future<void> recordMovement(BirdMovement movement) async {
    await DatabaseHelper.instance.insertBirdMovement(movement);
    await loadFlocks();
  }

  Future<void> deleteMovement(String id, String flockId) async {
    await DatabaseHelper.instance.deleteBirdMovement(id, flockId);
    await loadFlocks();
  }
}
