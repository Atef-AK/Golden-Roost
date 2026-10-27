import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/app_translations.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/responsive.dart';
import '../../core/utils/formatters.dart';
import '../../models/incubation.dart';
import '../../providers/incubation_provider.dart';
import '../widgets/empty_state_view.dart';

class IncubatorScreen extends ConsumerStatefulWidget {
  const IncubatorScreen({super.key});

  @override
  ConsumerState<IncubatorScreen> createState() => _IncubatorScreenState();
}

class _IncubatorScreenState extends ConsumerState<IncubatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final batches = ref.watch(incubationBatchesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activeBatches = batches
        .where((b) => b.status == 'incubating')
        .toList();
    final completedBatches = batches
        .where((b) => b.status != 'incubating')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('incubator_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: context.tr('incubator_new_batch'),
            onPressed: () => context.push('/incubator/new'),
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primaryTeal,
              labelColor: AppColors.primaryTeal,
              unselectedLabelColor: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(context.tr('incubator_batches')),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          activeBatches.length.toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(context.tr('incubator_history')),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withAlpha(30),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          completedBatches.length.toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_incubator',
        elevation: 2,
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: Text(
          context.tr('incubator_new_batch'),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        onPressed: () => context.push('/incubator/new'),
      ),
      body: ResponsiveContainer(
        maxWidth: 1100,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBatchesList(activeBatches, isActive: true),
            _buildBatchesList(completedBatches, isActive: false),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchesList(
    List<IncubationBatch> list, {
    required bool isActive,
  }) {
    if (list.isEmpty) {
      return EmptyStateView(
        icon: Icons.wb_incandescent_outlined,
        title: isActive
            ? context.tr('incubator_empty_active_title')
            : context.tr('incubator_empty_history_title'),
        description: isActive
            ? context.tr('incubator_empty_active_desc')
            : context.tr('incubator_empty_history_desc'),
        buttonText: isActive ? context.tr('incubator_new_batch') : null,
        onButtonPressed: isActive ? () => context.push('/incubator/new') : null,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;

        if (isWide) {
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.85,
            ),
            itemCount: list.length,
            itemBuilder: (ctx, index) => _BatchCard(batch: list[index]),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          itemCount: list.length,
          itemBuilder: (ctx, index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _BatchCard(batch: list[index]),
          ),
        );
      },
    );
  }
}

class _BatchCard extends StatelessWidget {
  final IncubationBatch batch;

  const _BatchCard({required this.batch});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isActive = batch.status == 'incubating';

    final progressPct = batch.durationDays > 0
        ? (batch.daysSinceSet / batch.durationDays).clamp(0.0, 1.0)
        : 0.0;

    return PremiumCard(
      onTap: () => context.push('/incubator/${batch.id}'),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: (batch.status == 'hatched'
                                ? Colors.amber
                                : AppColors.warning)
                            .withAlpha(24),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: (batch.status == 'hatched'
                                  ? Colors.amber
                                  : AppColors.warning)
                              .withAlpha(50),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        batch.status == 'hatched'
                            ? AppIcons.chicks
                            : AppIcons.incubator,
                        color: batch.status == 'hatched'
                            ? const Color(0xFFD97706)
                            : AppColors.warning,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${batch.eggsSetCount} ${batch.species.toUpperCase()} Eggs',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Machine: ${batch.incubatorName}',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isActive)
                StatusBadge.warning(
                  '${batch.daysUntilHatch}d to hatch',
                  icon: Icons.timer_outlined,
                )
              else
                StatusBadge.success(
                  batch.status.toUpperCase(),
                  icon: Icons.check_circle_outline,
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (isActive) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progressPct,
                minHeight: 6,
                backgroundColor: isDark
                    ? AppColors.borderDark
                    : AppColors.borderLight,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryTeal,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Day ${batch.daysSinceSet} of ${batch.durationDays}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryTeal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Expected: ${AppFormatters.formatShortDate(batch.expectedHatchDate)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.pageBackgroundDark
                  : const Color(0xFFF8FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatCell(
                  label: 'Fertility',
                  value: '${batch.fertilityRate.toStringAsFixed(0)}%',
                  subtext: '${batch.fertileEggsCount} fertile',
                  highlight: true,
                ),
                _StatCell(
                  label: 'Hatch Rate',
                  value: '${batch.hatchRateFromSet.toStringAsFixed(0)}%',
                  subtext: '${batch.hatchedCount} hatched',
                ),
                _StatCell(
                  label: 'Batch Cost',
                  value: AppFormatters.formatCurrency(
                    batch.totalBatchCost,
                    'TND',
                  ),
                  subtext: batch.hatchedCount > 0
                      ? '${batch.costPerChick.toStringAsFixed(3)}/chick'
                      : 'Pending',
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final String subtext;
  final bool highlight;

  const _StatCell({
    required this.label,
    required this.value,
    required this.subtext,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textSecondaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: highlight
                    ? AppColors.primaryTeal
                    : (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight),
              ),
            ),
          ),
          Text(
            subtext,
            style: TextStyle(
              fontSize: 9.5,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textSecondaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
