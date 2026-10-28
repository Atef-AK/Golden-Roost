import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/app_translations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/responsive.dart';
import '../../core/utils/formatters.dart';
import '../../models/bird_movement.dart';
import '../../models/egg_record.dart';
import '../../models/feed.dart';
import '../../models/finance.dart';
import '../../models/flock.dart';
import '../../models/health_record.dart';
import '../../models/vaccination.dart';
import '../../providers/egg_provider.dart';
import '../../providers/feed_provider.dart';
import '../../providers/finance_provider.dart';
import '../../providers/flock_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/task_provider.dart';
import '../eggs/egg_log_form_dialog.dart';
import '../feed/feed_log_dialog.dart';
import '../tasks/task_form_dialog.dart';
import 'bird_movement_dialog.dart';
import '../../core/utils/calculations.dart';

class FlockDetailScreen extends ConsumerStatefulWidget {
  final String flockId;

  const FlockDetailScreen({super.key, required this.flockId});

  @override
  ConsumerState<FlockDetailScreen> createState() => _FlockDetailScreenState();
}

class _FlockDetailScreenState extends ConsumerState<FlockDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final flocks = ref.watch(flocksProvider);
    final flock = flocks.cast<Flock?>().firstWhere(
      (f) => f?.id == widget.flockId,
      orElse: () => null,
    );

    final currency = ref.watch(settingsProvider).currency;

    if (flock == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('flocks_title'))),
        body: Center(child: Text(context.tr('flocks_empty'))),
      );
    }

    final movementsAsync = ref.watch(flockMovementsProvider(flock.id));
    final eggLogs = ref
        .watch(eggLogsProvider)
        .where((e) => e.flockId == flock.id)
        .toList();
    final feedLogs =
        (ref.watch(feedTransactionsProvider(flock.id)).valueOrNull ?? [])
            .where((t) => t.flockId == flock.id)
            .toList();
    final vaxs = ref
        .watch(vaccinationsProvider)
        .where((v) => v.flockId == flock.id)
        .toList();
    final healthRecords = ref
        .watch(healthRecordsProvider)
        .where((h) => h.flockId == flock.id)
        .toList();
    final finances = ref
        .watch(financesProvider)
        .where((f) => f.flockId == flock.id)
        .toList();

    // Financial totals for this flock
    final flockExpenses = finances
        .where((f) => f.isExpense && !f.isCapitalInvestment)
        .fold(0.0, (sum, f) => sum + f.amount);
    final flockIncome = finances
        .where((f) => f.isIncome)
        .fold(0.0, (sum, f) => sum + f.amount);
    final flockNetProfit = flockIncome - flockExpenses;

    return Scaffold(
      appBar: AppBar(
        title: Text(flock.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_calendar_outlined),
            tooltip: context.tr('flocks_edit_hatch_date'),
            onPressed: () => _editFlockBirthDate(context, flock),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: context.tr('flocks_edit'),
            onPressed: () => context.push('/flocks/edit/${flock.id}'),
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: context.tr('flocks_record_mortality'),
            onPressed: () =>
                BirdMovementDialog.show(context, initialFlockId: flock.id),
          ),
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'archive') {
                ref.read(flocksProvider.notifier).toggleArchive(flock);
              } else if (val == 'delete') {
                _confirmDelete(context, flock);
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'archive',
                child: Text(
                  flock.isArchived
                      ? context.tr('flocks_active')
                      : context.tr('flocks_archived'),
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  context.tr('delete'),
                  style: const TextStyle(color: AppColors.semanticError),
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.primaryTeal,
          labelColor: AppColors.primaryTeal,
          unselectedLabelColor: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          tabs: [
            Tab(text: context.tr('flocks_tab_overview')),
            Tab(text: context.tr('flocks_tab_eggs')),
            Tab(text: context.tr('flocks_tab_feed')),
            Tab(text: context.tr('flocks_tab_health')),
            Tab(text: context.tr('flocks_tab_finance')),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.cardBackgroundDark
              : AppColors.cardBackgroundLight,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 10,
                    ),
                  ),
                  icon: const Icon(Icons.egg_outlined, size: 16),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(context.tr('dash_quick_eggs'), maxLines: 1),
                  ),
                  onPressed: () =>
                      EggLogFormDialog.show(context, initialFlockId: flock.id),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 10,
                    ),
                  ),
                  icon: const Icon(Icons.restaurant, size: 16),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(context.tr('dash_quick_feed'), maxLines: 1),
                  ),
                  onPressed: () =>
                      FeedLogDialog.show(context, initialFlockId: flock.id),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.semanticError.withAlpha(20),
                  foregroundColor: AppColors.semanticError,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.heart_broken_outlined, size: 20),
                tooltip: context.tr('dash_quick_mortality'),
                onPressed: () => BirdMovementDialog.show(
                  context,
                  initialFlockId: flock.id,
                  initialType: 'mortality',
                ),
              ),
            ],
          ),
        ),
      ),
      body: ResponsiveContainer(
        maxWidth: 1000,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(flock, movementsAsync, isDark),
            _buildEggsTab(flock, eggLogs, isDark),
            _buildFeedTab(flock, feedLogs, isDark),
            _buildHealthTab(flock, vaxs, healthRecords, isDark),
            _buildFinancesTab(
              flock,
              finances,
              currency,
              flockExpenses,
              flockIncome,
              flockNetProfit,
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(
    Flock flock,
    AsyncValue<List<BirdMovement>> movementsAsync,
    bool isDark,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        // Main stats card
        PremiumCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${flock.currentCount} ${context.tr('flocks_live_birds_count')}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryTeal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusBadge(
                    label: context.trPurpose(flock.purpose),
                    variant: BadgeVariant.primary,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${context.tr('flocks_species')}: ${context.trSpecies(flock.species)} • ${context.tr('flocks_breed')}: ${flock.breed.isNotEmpty ? flock.breed : context.tr('flocks_standard_breed')}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${context.tr('flocks_location_label')}: ${flock.housingLocation.isNotEmpty ? flock.housingLocation : context.tr('flocks_main_pen')}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _editFlockBirthDate(context, flock),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withAlpha(isDark ? 35 : 15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.primaryTeal.withAlpha(isDark ? 65 : 40),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.cake_outlined,
                        size: 16,
                        color: AppColors.primaryTeal,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${context.tr('flocks_age_label')}: ${flock.ageInWeeks} ${context.tr('flocks_weeks')} (${flock.ageInDays} ${context.tr('flocks_days')}) • ${AppFormatters.formatShortDate(flock.effectiveBirthDate)}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryTeal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.edit_calendar_rounded,
                        size: 16,
                        color: AppColors.primaryTeal,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${context.tr('flocks_acquired_label')}: ${AppFormatters.formatShortDate(flock.acquisitionDate)}',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
              ),
              Divider(
                height: 24,
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MetricMini(
                    label: context.tr('flocks_starting_label'),
                    value: flock.startCount.toString(),
                  ),
                  _MetricMini(
                    label: context.tr('flocks_males_label'),
                    value: flock.maleCount.toString(),
                  ),
                  _MetricMini(
                    label: context.tr('flocks_females_label'),
                    value: flock.femaleCount.toString(),
                  ),
                  _MetricMini(
                    label: context.tr('flocks_mortality_label'),
                    value:
                        '${((flock.startCount - flock.currentCount) / (flock.startCount > 0 ? flock.startCount : 1) * 100).toStringAsFixed(1)}%',
                    color: (flock.startCount - flock.currentCount) > 0
                        ? AppColors.semanticError
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // SectionHeader with flexible title and action
        SectionHeader(
          title: context.tr('flocks_chronological_movements'),
          actionLabel: context.tr('flocks_add_movement'),
          onAction: () =>
              BirdMovementDialog.show(context, initialFlockId: flock.id),
        ),
        const SizedBox(height: 6),

        movementsAsync.when(
          data: (movements) {
            if (movements.isEmpty) {
              return PremiumCard(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    context.tr('flocks_no_movements'),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return Column(
              children: movements.map((m) {
                final isNegative = m.isReduction;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: PremiumCard(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isNegative
                                ? AppColors.semanticError.withAlpha(20)
                                : AppColors.semanticSuccess.withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isNegative ? Icons.remove : Icons.add,
                            color: isNegative
                                ? AppColors.semanticError
                                : AppColors.semanticSuccess,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${context.trMovementType(m.type)} (${isNegative ? "-" : "+"}${m.count})',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${AppFormatters.formatShortDate(m.date)}${m.reasonOrBuyer.isNotEmpty ? ' • ${m.reasonOrBuyer}' : ''}${m.notes.isNotEmpty ? ' • ${m.notes}' : ''}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.textMutedDark
                                      : AppColors.textMutedLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Text('Error: $err'),
        ),
      ],
    );
  }

  Widget _buildEggsTab(Flock flock, List<EggLog> logs, bool isDark) {
    if (logs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.egg_outlined, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(context.tr('eggs_title')),
              const SizedBox(height: 12),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                ),
                onPressed: () =>
                    EggLogFormDialog.show(context, initialFlockId: flock.id),
                child: Text(context.tr('eggs_collect')),
              ),
            ],
          ),
        ),
      );
    }

    final totalUsable = logs.fold(0, (sum, e) => sum + e.usableEggs);
    final totalCracked = logs.fold(0, (sum, e) => sum + e.crackedEggs);
    final totalDirty = logs.fold(0, (sum, e) => sum + e.dirtyEggs);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        PremiumCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MetricMini(
                label: context.tr('eggs_usable'),
                value: totalUsable.toString(),
                color: AppColors.primaryTeal,
              ),
              _MetricMini(
                label: context.tr('eggs_cracked'),
                value: totalCracked.toString(),
                color: AppColors.semanticError,
              ),
              _MetricMini(
                label: context.tr('eggs_dirty'),
                value: totalDirty.toString(),
                color: AppColors.semanticWarning,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SectionHeader(title: context.tr('eggs_title')),
        const SizedBox(height: 6),
        ...logs.map((log) {
          final females = flock.femaleCount > 0
              ? flock.femaleCount
              : flock.currentCount;
          final layingPct = females > 0 ? (log.totalEggs / females) * 100 : 0.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PremiumCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.egg_outlined,
                      color: AppColors.primaryTeal,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${log.totalEggs} ${context.tr('eggs_total')} (${layingPct.toStringAsFixed(1)}%)',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${AppFormatters.formatShortDate(log.date)} • ${log.collectionTime} • ${context.tr('eggs_usable')}: ${log.usableEggs}, ${context.tr('eggs_cracked')}: ${log.crackedEggs}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: () =>
                        ref.read(eggLogsProvider.notifier).deleteLog(log.id),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFeedTab(Flock flock, List<FeedTransaction> txs, bool isDark) {
    final gramsPerBird = FarmCalculations.getDailyIntakeGramsPerBird(
      species: flock.species,
      purpose: flock.purpose,
      ageWeeks: flock.ageWeeks,
      ageDays: flock.ageInDays,
    );
    final dailyFlockDemandKg = FarmCalculations.calculateFlockDailyDemandKg(
      birdCount: flock.currentCount,
      species: flock.species,
      purpose: flock.purpose,
      ageWeeks: flock.ageWeeks,
      ageDays: flock.ageInDays,
    );

    final totalKg = txs
        .where((t) => t.type == 'consumption')
        .fold(0.0, (sum, t) => sum + t.quantityKg);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        // Daily Demand & Age-Based Feeding Guideline Card
        PremiumCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.grain_rounded,
                          size: 16,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.tr('feed_daily_burn'),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '~${gramsPerBird.toStringAsFixed(0)} g/bird/day',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${dailyFlockDemandKg.toStringAsFixed(2)} kg/day',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                      Text(
                        '${flock.currentCount} ${context.tr('birds')} • ${flock.ageWeeks} ${context.tr('flocks_weeks')}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 14),
                    label: Text(
                      context.tr('feed_log_btn'),
                      style: const TextStyle(fontSize: 12),
                    ),
                    onPressed: () =>
                        FeedLogDialog.show(context, initialFlockId: flock.id),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        if (txs.isNotEmpty)
          PremiumCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('feed_total_consumed'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${totalKg.toStringAsFixed(1)} kg',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryTeal,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 14),
        SectionHeader(title: context.tr('feed_title')),
        const SizedBox(height: 6),
        ...txs.map((t) {
          final perBirdGrams = flock.currentCount > 0
              ? (t.quantityKg * 1000.0) / flock.currentCount
              : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PremiumCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal.withAlpha(15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      color: AppColors.primaryTeal,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${t.quantityKg.toStringAsFixed(1)} kg (~${perBirdGrams.toStringAsFixed(0)} g/${context.tr('dash_total_birds')})',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${AppFormatters.formatShortDate(t.date)} ${t.notes.isNotEmpty ? '• ${t.notes}' : ''}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildHealthTab(
    Flock flock,
    List<VaccinationSchedule> vaxs,
    List<HealthRecord> health,
    bool isDark,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        SectionHeader(
          title: context.tr('tasks_title'),
          actionLabel: context.tr('tasks_add'),
          onAction: () => TaskFormDialog.show(
            context,
            initialFlockId: flock.id,
            initialCategory: 'vaccination',
          ),
        ),
        const SizedBox(height: 6),
        if (vaxs.isEmpty)
          PremiumCard(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                context.tr('tasks_empty_desc'),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
              ),
            ),
          )
        else
          ...vaxs.map((v) {
            final isDone = v.status == 'completed';
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: PremiumCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      isDone ? Icons.check_circle : Icons.schedule,
                      color: isDone
                          ? AppColors.semanticSuccess
                          : AppColors.semanticWarning,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            v.vaccineName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${context.tr('date')}: ${AppFormatters.formatShortDate(v.targetDate)} • ${v.administrationRoute}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isDone)
                      TextButton(
                        onPressed: () {
                          final updated = v.copyWith(
                            status: 'completed',
                            completedDate: DateTime.now(),
                          );
                          ref
                              .read(vaccinationsProvider.notifier)
                              .updateVaccination(updated);
                        },
                        child: Text(context.tr('tasks_mark_complete')),
                      ),
                  ],
                ),
              ),
            );
          }),
        const SizedBox(height: 16),
        SectionHeader(title: context.tr('tasks_observations')),
        const SizedBox(height: 6),
        if (health.isEmpty)
          PremiumCard(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'No health incidents recorded.',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
              ),
            ),
          )
        else
          ...health.map((h) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: PremiumCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.medical_services_outlined,
                      color: AppColors.semanticError,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            h.symptomOrDiagnosis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${AppFormatters.formatShortDate(h.date)} • ${h.treatmentAdministered}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildFinancesTab(
    Flock flock,
    List<FinancialTransaction> finances,
    String currency,
    double expenses,
    double income,
    double netProfit,
    bool isDark,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        PremiumCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${context.tr('finance_net_profit')}: ${AppFormatters.formatCurrency(netProfit, currency)}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: netProfit >= 0
                      ? AppColors.semanticSuccess
                      : AppColors.semanticError,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${context.tr('finance_income')}: +${AppFormatters.formatCurrency(income, currency)} • ${context.tr('finance_expenses')}: -${AppFormatters.formatCurrency(expenses, currency)}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SectionHeader(title: context.tr('finance_title')),
        const SizedBox(height: 6),
        if (finances.isEmpty)
          PremiumCard(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                context.tr('finance_no_tx'),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
              ),
            ),
          )
        else
          ...finances.map((f) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: PremiumCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      f.isIncome ? Icons.south_west : Icons.north_east,
                      color: f.isIncome
                          ? AppColors.semanticSuccess
                          : AppColors.semanticError,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${f.category.toUpperCase()}: ${f.notes.isNotEmpty ? f.notes : f.type}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            AppFormatters.formatShortDate(f.date),
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${f.isIncome ? "+" : "-"}${AppFormatters.formatCurrency(f.amount, currency)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: f.isIncome
                            ? AppColors.semanticSuccess
                            : AppColors.semanticError,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Future<void> _editFlockBirthDate(BuildContext context, Flock flock) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: flock.effectiveBirthDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      helpText: context.tr('flocks_edit_hatch_date'),
    );
    if (picked != null) {
      final updated = flock.copyWith(hatchDate: picked);
      await ref.read(flocksProvider.notifier).updateFlock(updated);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF0F766E),
            behavior: SnackBarBehavior.floating,
            content: Text(
              '${context.tr('flocks_age_preview')}: ${updated.ageInWeeks} ${context.tr('flocks_weeks')} (${updated.ageInDays} ${context.tr('flocks_days')})',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context, Flock flock) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('delete')),
        content: Text(context.tr('confirm_delete')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.semanticError,
            ),
            onPressed: () {
              ref.read(flocksProvider.notifier).deleteFlock(flock.id);
              Navigator.pop(ctx);
              context.pop();
            },
            child: Text(context.tr('delete')),
          ),
        ],
      ),
    );
  }
}

class _MetricMini extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _MetricMini({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color:
                      color ??
                      (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
