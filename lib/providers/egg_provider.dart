import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/database_helper.dart';
import '../models/egg_record.dart';

final eggLogsProvider = StateNotifierProvider<EggLogsNotifier, List<EggLog>>((
  ref,
) {
  return EggLogsNotifier();
});

final eggSalesProvider = StateNotifierProvider<EggSalesNotifier, List<EggSale>>(
  (ref) {
    return EggSalesNotifier();
  },
);

class EggLogsNotifier extends StateNotifier<List<EggLog>> {
  EggLogsNotifier() : super([]) {
    loadLogs();
  }

  Future<void> loadLogs({String? flockId}) async {
    final list = await DatabaseHelper.instance.getEggLogs(flockId: flockId);
    state = list;
  }

  Future<void> recordLog(EggLog log) async {
    await DatabaseHelper.instance.insertEggLog(log);
    await loadLogs();
  }

  Future<void> updateLog(EggLog log) async {
    await DatabaseHelper.instance.updateEggLog(log);
    await loadLogs();
  }

  Future<void> deleteLog(String id) async {
    await DatabaseHelper.instance.deleteEggLog(id);
    await loadLogs();
  }
}

class EggSalesNotifier extends StateNotifier<List<EggSale>> {
  EggSalesNotifier() : super([]) {
    loadSales();
  }

  Future<void> loadSales() async {
    final list = await DatabaseHelper.instance.getEggSales();
    state = list;
  }

  Future<void> recordSale(EggSale sale) async {
    await DatabaseHelper.instance.insertEggSale(sale);
    await loadSales();
  }

  Future<void> deleteSale(String id) async {
    await DatabaseHelper.instance.deleteEggSale(id);
    await loadSales();
  }
}
