import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'flock_provider.dart';
import 'feed_provider.dart';
import 'egg_provider.dart';
import 'incubation_provider.dart';
import 'task_provider.dart';
import 'finance_provider.dart';
import '../models/task_item.dart';
import '../models/incubation.dart';
import '../core/utils/calculations.dart';

class DashboardStats {
  final int totalLiveBirds;
  final int eggsCollectedToday;
  final double totalFeedStockKg;
  final int feedDaysRemaining;
  final double dailyFeedDemandKg;
  final DateTime? estimatedRefillDate;
  final bool hasLowFeedAlert;
  final double todayIncome;
  final double todayExpenses;
  final double currentMonthNet;
  final List<IncubationBatch> activeIncubations;
  final List<TaskItem> todayTasks;
  final List<TaskItem> overdueTasks;
  final int pendingVaccinationsCount;

  const DashboardStats({
    required this.totalLiveBirds,
    required this.eggsCollectedToday,
    required this.totalFeedStockKg,
    required this.feedDaysRemaining,
    required this.dailyFeedDemandKg,
    this.estimatedRefillDate,
    required this.hasLowFeedAlert,
    required this.todayIncome,
    required this.todayExpenses,
    required this.currentMonthNet,
    required this.activeIncubations,
    required this.todayTasks,
    required this.overdueTasks,
    required this.pendingVaccinationsCount,
  });
}

final dashboardProvider = dashboardStatsProvider;

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  final flocks = ref.watch(flocksProvider);
  final feedInventory = ref.watch(feedInventoryProvider);
  final eggLogs = ref.watch(eggLogsProvider);
  final incubations = ref.watch(incubationBatchesProvider);
  final tasks = ref.watch(tasksProvider);
  final vaccinations = ref.watch(vaccinationsProvider);
  final finances = ref.watch(financesProvider);

  final now = DateTime.now();

  // Total Live Birds
  final totalBirds = flocks
      .where((f) => !f.isArchived)
      .fold(0, (sum, f) => sum + f.currentCount);

  // Eggs collected today
  final eggsToday = eggLogs
      .where(
        (e) =>
            e.date.year == now.year &&
            e.date.month == now.month &&
            e.date.day == now.day,
      )
      .fold(0, (sum, e) => sum + e.totalEggs);

  // Feed Stock & Remaining Days
  final totalFeedStock = feedInventory.fold(
    0.0,
    (sum, fi) => sum + fi.currentStockKg,
  );
  final hasLowFeed = feedInventory.any((fi) => fi.isLowStock);

  // Dynamic daily feed consumption calculation based on flock species, purpose, age (weeks/days), and count
  double estimatedDailyFeedKg = 0.0;
  for (final f in flocks.where((f) => !f.isArchived && f.currentCount > 0)) {
    estimatedDailyFeedKg += FarmCalculations.calculateFlockDailyDemandKg(
      birdCount: f.currentCount,
      species: f.species,
      purpose: f.purpose,
      ageWeeks: f.ageWeeks,
      ageDays: f.ageInDays,
    );
  }

  final daysRemaining = FarmCalculations.calculateDaysBeforeRefill(
    totalStockKg: totalFeedStock,
    totalDailyDemandKg: estimatedDailyFeedKg,
  );

  final refillDate = FarmCalculations.calculateEstimatedRefillDate(
    totalStockKg: totalFeedStock,
    totalDailyDemandKg: estimatedDailyFeedKg,
  );

  // Today's finances
  final todayFinances = finances.where(
    (tx) =>
        tx.date.year == now.year &&
        tx.date.month == now.month &&
        tx.date.day == now.day,
  );
  final todayIncome = todayFinances
      .where((tx) => tx.isIncome)
      .fold(0.0, (sum, tx) => sum + tx.amount);
  final todayExpenses = todayFinances
      .where((tx) => tx.isExpense)
      .fold(0.0, (sum, tx) => sum + tx.amount);

  // Current month net profit
  final monthFinances = finances.where(
    (tx) =>
        tx.date.year == now.year &&
        tx.date.month == now.month &&
        !tx.isCapitalInvestment,
  );
  final monthIncome = monthFinances
      .where((tx) => tx.isIncome)
      .fold(0.0, (sum, tx) => sum + tx.amount);
  final monthExpenses = monthFinances
      .where((tx) => tx.isExpense)
      .fold(0.0, (sum, tx) => sum + tx.amount);
  final currentMonthNet = monthIncome - monthExpenses;

  // Active Incubations
  final activeInc = incubations.where((b) => b.status == 'incubating').toList();

  // Tasks
  final todayTasks = tasks.where((t) => t.isDueToday).toList();
  final overdueTasks = tasks.where((t) => t.isOverdue).toList();

  final pendingVax = vaccinations.where((v) => v.status == 'pending').length;

  return DashboardStats(
    totalLiveBirds: totalBirds,
    eggsCollectedToday: eggsToday,
    totalFeedStockKg: totalFeedStock,
    feedDaysRemaining: daysRemaining,
    dailyFeedDemandKg: estimatedDailyFeedKg,
    estimatedRefillDate: refillDate,
    hasLowFeedAlert: hasLowFeed,
    todayIncome: todayIncome,
    todayExpenses: todayExpenses,
    currentMonthNet: currentMonthNet,
    activeIncubations: activeInc,
    todayTasks: todayTasks,
    overdueTasks: overdueTasks,
    pendingVaccinationsCount: pendingVax,
  );
});
