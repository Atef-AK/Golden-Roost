import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/database_helper.dart';
import '../models/finance.dart';
import '../models/electricity.dart';

final financesProvider =
    StateNotifierProvider<FinancesNotifier, List<FinancialTransaction>>((ref) {
      return FinancesNotifier();
    });

final electricityReadingsProvider =
    StateNotifierProvider<ElectricityNotifier, List<ElectricityReading>>((ref) {
      return ElectricityNotifier();
    });

final equipmentProvider =
    StateNotifierProvider<EquipmentNotifier, List<EquipmentItem>>((ref) {
      return EquipmentNotifier();
    });

class FinancesNotifier extends StateNotifier<List<FinancialTransaction>> {
  FinancesNotifier() : super([]) {
    loadFinances();
  }

  Future<void> loadFinances() async {
    final list = await DatabaseHelper.instance.getFinances();
    state = list;
  }

  Future<void> addTransaction(FinancialTransaction tx) async {
    await DatabaseHelper.instance.insertFinance(tx);
    await loadFinances();
  }

  Future<void> updateTransaction(FinancialTransaction tx) async {
    await DatabaseHelper.instance.updateFinance(tx);
    await loadFinances();
  }

  Future<void> deleteTransaction(String id) async {
    await DatabaseHelper.instance.deleteFinance(id);
    await loadFinances();
  }

  double get totalOperatingIncome => state
      .where((tx) => tx.isIncome && !tx.isCapitalInvestment)
      .fold(0.0, (sum, tx) => sum + tx.amount);

  double get totalOperatingExpenses => state
      .where((tx) => tx.isExpense && !tx.isCapitalInvestment)
      .fold(0.0, (sum, tx) => sum + tx.amount);

  double get netOperatingResult =>
      totalOperatingIncome - totalOperatingExpenses;

  double get totalCapitalInvestments => state
      .where((tx) => tx.isCapitalInvestment)
      .fold(0.0, (sum, tx) => sum + tx.amount);

  double get totalCashReceived => state
      .where((tx) => tx.isIncome)
      .fold(0.0, (sum, tx) => sum + tx.amountPaid);

  double get totalUnpaidReceivables => state
      .where((tx) => tx.isIncome)
      .fold(0.0, (sum, tx) => sum + tx.outstandingAmount);
}

class ElectricityNotifier extends StateNotifier<List<ElectricityReading>> {
  ElectricityNotifier() : super([]) {
    loadReadings();
  }

  Future<void> loadReadings() async {
    final list = await DatabaseHelper.instance.getElectricityReadings();
    state = list;
  }

  Future<void> addReading(ElectricityReading reading) async {
    await DatabaseHelper.instance.insertElectricityReading(reading);
    await loadReadings();
  }
}

class EquipmentNotifier extends StateNotifier<List<EquipmentItem>> {
  EquipmentNotifier() : super([]) {
    loadEquipment();
  }

  Future<void> loadEquipment() async {
    final list = await DatabaseHelper.instance.getEquipment();
    state = list;
  }

  Future<void> addEquipment(EquipmentItem item) async {
    await DatabaseHelper.instance.insertEquipment(item);
    await loadEquipment();
  }
}
