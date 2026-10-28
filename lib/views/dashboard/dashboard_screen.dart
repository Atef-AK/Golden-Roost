import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/app_translations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/responsive.dart';
import '../../core/utils/formatters.dart';
import '../../models/farm_settings.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/feed_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/task_provider.dart';
import '../widgets/quick_action_sheet.dart';
import '../eggs/egg_log_form_dialog.dart';
import '../feed/feed_log_dialog.dart';
import '../flocks/bird_movement_dialog.dart';
import '../finance/finance_form_dialog.dart';
import '../tasks/task_form_dialog.dart';
import '../tasks/water_care_dialog.dart';
import '../widgets/chicken_icon.dart';
import 'widgets/dashboard_charts.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardStatsProvider);
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pendingAlertsCount =
        stats.overdueTasks.length + (stats.hasLowFeedAlert ? 1 : 0);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/brand/app_icon_golden_roost.jpg',
                width: 38,
                height: 38,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.forestEmerald, AppColors.deepForest],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.egg_alt_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    settings.farmName,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16.5,
                      letterSpacing: -0.3,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        context.tr('dash_live_connected'),
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          ' • ${AppFormatters.formatFullDate(DateTime.now(), locale: settings.language)}',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bolt_rounded, color: AppColors.primaryTeal),
            tooltip: context.tr('dash_quick_action'),
            onPressed: () => _openQuickActions(context),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                tooltip: context.tr('dash_pending'),
                onPressed: () {
                  if (stats.overdueTasks.isNotEmpty) {
                    context.push('/tasks');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.tr('dash_no_tasks_today')),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
              if (pendingAlertsCount > 0)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(3.5),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      pendingAlertsCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: context.tr('settings_title'),
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryTeal,
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
        },
        child: ResponsiveContainer(
          maxWidth: 1100,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              // 1. Critical Warning Banners
              if (stats.overdueTasks.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.errorSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.error.withAlpha(60)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${stats.overdueTasks.length} ${context.tr('dash_overdue_tasks_alert')}',
                            style: const TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                          ),
                          onPressed: () => context.push('/tasks'),
                          child: Text(context.tr('dash_view_tasks')),
                        ),
                      ],
                    ),
                  ),
                ),

              if (stats.hasLowFeedAlert)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warningSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.warning.withAlpha(80),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.warning,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            context.tr('feed_low_stock_warning'),
                            style: const TextStyle(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.warning,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                          ),
                          onPressed: () => context.push('/feed'),
                          child: Text(context.tr('feed_restock')),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              // 2. Executive Operations Bento Grid (Stripe / Apple style)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildOperationsBentoGrid(
                  context,
                  stats,
                  settings,
                  isDark,
                ),
              ),

              const SizedBox(height: 16),

              // 2.5 Visual Analytics & Trends Charts
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: DashboardAnalyticsCard(),
              ),

              const SizedBox(height: 16),

              // 3. Compact Quick Actions Ribbon
              SectionHeader(
                title: context.tr('dash_quick_action'),
                trailing: TextButton(
                  onPressed: () => _openQuickActions(context),
                  child: Text(context.tr('dash_view_all')),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _ActionPill(
                      icon: Icons.grain_rounded,
                      label: context.tr('dash_quick_feed'),
                      color: AppColors.primaryTeal,
                      onTap: () => FeedLogDialog.show(context),
                    ),
                    const SizedBox(width: 8),
                    _ActionPill(
                      icon: Icons.egg_outlined,
                      label: context.tr('dash_quick_eggs'),
                      color: AppColors.warning,
                      onTap: () => EggLogFormDialog.show(context),
                    ),
                    const SizedBox(width: 8),
                    _ActionPill(
                      icon: Icons.water_drop_outlined,
                      label: context.tr('dash_quick_water'),
                      color: AppColors.info,
                      onTap: () => WaterCareDialog.show(context),
                    ),
                    const SizedBox(width: 8),
                    _ActionPill(
                      icon: Icons.receipt_long_outlined,
                      label: context.tr('dash_quick_expense'),
                      color: const Color(0xFFC0403B),
                      onTap: () => FinanceFormDialog.show(
                        context,
                        initialType: 'expense',
                      ),
                    ),
                    const SizedBox(width: 8),
                    _ActionPill(
                      icon: Icons.heart_broken_outlined,
                      label: context.tr('dash_quick_mortality'),
                      color: AppColors.error,
                      onTap: () => BirdMovementDialog.show(
                        context,
                        initialType: 'mortality',
                      ),
                    ),
                    const SizedBox(width: 8),
                    _ActionPill(
                      icon: Icons.sell_outlined,
                      label: context.tr('dash_quick_sale'),
                      color: AppColors.success,
                      onTap: () =>
                          BirdMovementDialog.show(context, initialType: 'sale'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 4. Active Incubator Spotlight Banner
              if (stats.activeIncubations.isNotEmpty) ...[
                SectionHeader(
                  title: context.tr('incubator_batches'),
                  subtitle:
                      '${stats.activeIncubations.length} ${context.tr('incubator_batches')}',
                  trailing: TextButton(
                    onPressed: () => context.push('/incubator'),
                    child: Text(context.tr('dash_view_all')),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: stats.activeIncubations.map((batch) {
                      final progress = (batch.durationDays > 0)
                          ? (batch.daysSinceSet / batch.durationDays).clamp(
                              0.0,
                              1.0,
                            )
                          : 0.0;

                      return PremiumCard(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppColors.warning.withAlpha(
                                            20,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.wb_incandescent_outlined,
                                          size: 16,
                                          color: AppColors.warning,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${batch.eggsSetCount} ${batch.species.toUpperCase()}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: isDark
                                                ? AppColors.textPrimaryDark
                                                : AppColors.textPrimaryLight,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                StatusBadge.warning(
                                  '${context.tr('incubator_expected_hatch_short')} ${batch.daysUntilHatch}d',
                                  icon: Icons.timer_outlined,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                                backgroundColor: isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryTeal,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${batch.incubatorName} • ${context.tr('incubator_day_x_of_y')} ${batch.daysSinceSet}/${batch.durationDays}',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: () =>
                                      context.push('/incubator/${batch.id}'),
                                  child: Text(context.tr('view')),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // 5. Priority Tasks Section (Today's Tasks)
              SectionHeader(
                title: context.tr('dash_todays_tasks'),
                subtitle: context.tr('dash_tasks_subtitle'),
                trailing: TextButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(context.tr('tasks_add')),
                  onPressed: () => TaskFormDialog.show(context),
                ),
              ),

              if (stats.todayTasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: PremiumCard(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.success.withAlpha(20),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_outline,
                            color: AppColors.success,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('dash_no_tasks_today'),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.5,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                ),
                              ),
                              Text(
                                context.tr('tasks_empty_desc'),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: stats.todayTasks.map((task) {
                      return PremiumCard(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: task.isCompleted,
                              activeColor: AppColors.primaryTeal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              onChanged: (val) async {
                                final res = await ref
                                    .read(tasksProvider.notifier)
                                    .toggleComplete(task);
                                if (res != null && context.mounted) {
                                  ref
                                      .read(feedInventoryProvider.notifier)
                                      .loadInventory();
                                  ref.invalidate(feedTransactionsProvider);
                                  ref.invalidate(dashboardStatsProvider);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: const Color(0xFF0F766E),
                                      behavior: SnackBarBehavior.floating,
                                      content: Row(
                                        children: [
                                          const Icon(
                                            Icons.check_circle_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '${context.tr('feed_task_completed_deducted')}: ${res.deductedKg.toStringAsFixed(1)} kg (${res.feedName})',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color:
                                    (task.isCompleted
                                            ? Colors.grey
                                            : AppColors.primaryTeal)
                                        .withAlpha(20),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                _getCategoryIcon(task.category),
                                size: 16,
                                color: task.isCompleted
                                    ? Colors.grey
                                    : AppColors.primaryTeal,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: TextStyle(
                                      decoration: task.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.5,
                                      color: task.isCompleted
                                          ? (isDark
                                                ? AppColors.textTertiaryDark
                                                : AppColors.textTertiaryLight)
                                          : (isDark
                                                ? AppColors.textPrimaryDark
                                                : AppColors.textPrimaryLight),
                                    ),
                                  ),
                                  Text(
                                    '${task.category.toUpperCase()} • ${task.dueTime ?? 'Anytime'}${task.notes.isNotEmpty ? ' • ${task.notes}' : ''}',
                                    style: TextStyle(
                                      fontSize: 11,
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
                            if (task.isOverdue && !task.isCompleted) ...[
                              const SizedBox(width: 8),
                              StatusBadge.error(context.tr('tasks_overdue')),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

              const SizedBox(height: 16),

              // 6. Farm Activity Timeline Section
              SectionHeader(
                title: context.tr('dash_recent_activity'),
                trailing: TextButton(
                  onPressed: () => context.push('/reports'),
                  child: Text(context.tr('dash_view_all')),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PremiumCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      _TimelineRow(
                        icon: Icons.egg_outlined,
                        color: AppColors.warning,
                        title: context.tr('dash_activity_egg'),
                        subtitle:
                            '${stats.eggsCollectedToday} ${context.tr('eggs_today_collected')}',
                        time: context.tr('dash_today'),
                      ),
                      const Divider(height: 16),
                      _TimelineRow(
                        icon: Icons.grain_rounded,
                        color: AppColors.success,
                        title: context.tr('dash_activity_feed'),
                        subtitle:
                            '${AppFormatters.formatWeight(stats.totalFeedStockKg)} ${context.tr('feed_stock_levels')}',
                        time: context.tr('dash_today'),
                      ),
                      const Divider(height: 16),
                      _TimelineRow(
                        iconWidget: const ChickenIcon(
                          size: 16,
                          color: AppColors.primaryTeal,
                        ),
                        color: AppColors.primaryTeal,
                        title: context.tr('dash_total_birds'),
                        subtitle:
                            '${stats.totalLiveBirds} ${context.tr('dash_sub_live_birds')}',
                        time: context.tr('dash_today'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openQuickActions(BuildContext context) {
    QuickActionSheet.show(
      context,
      onLogFeed: () => FeedLogDialog.show(context),
      onLogWater: () => WaterCareDialog.show(context),
      onCollectEggs: () => EggLogFormDialog.show(context),
      onRecordMortality: () =>
          BirdMovementDialog.show(context, initialType: 'mortality'),
      onRecordSale: () => BirdMovementDialog.show(context, initialType: 'sale'),
      onAddExpense: () =>
          FinanceFormDialog.show(context, initialType: 'expense'),
      onAddIncome: () => FinanceFormDialog.show(context, initialType: 'income'),
      onAddVaccineOrTask: () => TaskFormDialog.show(context),
      onNewIncubation: () => context.push('/incubator/new'),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'feeding':
        return Icons.grain_rounded;
      case 'watering':
        return Icons.water_drop_outlined;
      case 'vaccination':
        return Icons.medical_services_outlined;
      case 'cleaning':
        return Icons.cleaning_services_outlined;
      case 'weighing':
        return Icons.scale_outlined;
      case 'incubation':
        return Icons.wb_incandescent_outlined;
      case 'maintenance':
        return Icons.build_outlined;
      default:
        return Icons.check_circle_outline;
    }
  }

  Widget _buildOperationsBentoGrid(
    BuildContext context,
    DashboardStats stats,
    FarmSettings settings,
    bool isDark,
  ) {
    final cardBorder = isDark
        ? const Color(0xFF1E283D)
        : const Color(0xFFE2E8F0);
    final cardBg = isDark ? const Color(0xFF0F1626) : Colors.white;

    return Column(
      children: [
        // 1. Hero Bento Card: Live Flock & Bird Operations
        InkWell(
          onTap: () => context.push('/flocks'),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF131D31), Color(0xFF0C1322)],
                    )
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
                    ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: cardBorder, width: 1),
              boxShadow: AppShadows.card(isDark),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF059669), Color(0xFF10B981)],
                              ),
                              borderRadius: BorderRadius.circular(11),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981).withAlpha(70),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: ChickenIcon(color: Colors.white, size: 21),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.tr('dash_total_birds'),
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  context.tr('dash_sub_live_birds'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? AppColors.textTertiaryDark
                                        : AppColors.textTertiaryLight,
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFF10B981,
                        ).withAlpha(isDark ? 40 : 25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF10B981).withAlpha(90),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            context.tr('dash_active_flocks_badge'),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      stats.totalLiveBirds.toString(),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.2,
                        height: 1.0,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.tr('birds'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Directionality.of(context) == TextDirection.rtl
                          ? Icons.chevron_left_rounded
                          : Icons.chevron_right_rounded,
                      color: isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8),
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF172033)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: Color(0xFF10B981),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            context.tr('flocks_active'),
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${stats.pendingVaccinationsCount} ${context.tr('dash_pending')}',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: stats.pendingVaccinationsCount > 0
                              ? AppColors.warning
                              : (isDark
                                    ? AppColors.textTertiaryDark
                                    : AppColors.textTertiaryLight),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 2. Dual Bento: Egg Yield + Feed Runway
        Row(
          children: [
            // Egg Yield Bento
            Expanded(
              child: InkWell(
                onTap: () => context.push('/eggs'),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: cardBorder, width: 1),
                    boxShadow: AppShadows.card(isDark),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.warning.withAlpha(35),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.egg_rounded,
                              color: AppColors.warning,
                              size: 20,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withAlpha(
                                isDark ? 40 : 25,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              context.tr('dash_today'),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        stats.eggsCollectedToday.toString(),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.tr('dash_eggs_today'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: (stats.eggsCollectedToday / 400.0).clamp(
                            0.05,
                            1.0,
                          ),
                          minHeight: 4,
                          backgroundColor: isDark
                              ? const Color(0xFF1E283D)
                              : const Color(0xFFE2E8F0),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Feed Runway Bento
            Expanded(
              child: InkWell(
                onTap: () => context.push('/feed'),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: cardBorder, width: 1),
                    boxShadow: AppShadows.card(isDark),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withAlpha(35),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.grain_rounded,
                              color: Color(0xFF10B981),
                              size: 20,
                            ),
                          ),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2.5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF10B981,
                                ).withAlpha(isDark ? 40 : 25),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                context.tr('dash_safe_reserve'),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF10B981),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        stats.feedDaysRemaining > 0
                            ? '~${stats.feedDaysRemaining}d'
                            : (stats.totalLiveBirds == 0 ||
                                      stats.totalFeedStockKg == 0
                                  ? '--'
                                  : '0d'),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stats.dailyFeedDemandKg > 0
                            ? '${context.tr('dash_feed_stock')} • ${stats.dailyFeedDemandKg.toStringAsFixed(1)} kg/d'
                            : context.tr('dash_feed_stock'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: (stats.feedDaysRemaining / 60.0).clamp(
                            0.05,
                            1.0,
                          ),
                          minHeight: 4,
                          backgroundColor: isDark
                              ? const Color(0xFF1E283D)
                              : const Color(0xFFE2E8F0),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 3. Executive Financial Ledger Card (Revolut / Stripe P&L Style)
        InkWell(
          onTap: () => context.push('/finance'),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF131D31), Color(0xFF0C1322)],
                    )
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF1E283D)
                    : const Color(0xFF334155),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 80 : 35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: Colors.white,
                            size: 17,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          context.tr('dash_month_net'),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
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
                        color: Colors.white.withAlpha(18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        settings.currency,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppFormatters.formatCurrency(
                        stats.currentMonthNet,
                        settings.currency,
                      ),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.6,
                        color: stats.currentMonthNet >= 0
                            ? const Color(0xFF34D399)
                            : const Color(0xFFFB7185),
                      ),
                    ),
                    Icon(
                      Directionality.of(context) == TextDirection.rtl
                          ? Icons.chevron_left_rounded
                          : Icons.chevron_right_rounded,
                      color: Colors.white54,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.arrow_upward_rounded,
                              size: 13,
                              color: Color(0xFF34D399),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              context.tr('dash_income'),
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: Colors.white70,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '+${AppFormatters.formatCurrency(stats.todayIncome, settings.currency)}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF34D399),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE11D48).withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.arrow_downward_rounded,
                              size: 13,
                              color: Color(0xFFFB7185),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              context.tr('dash_expense'),
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: Colors.white70,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              AppFormatters.formatCurrency(
                                stats.todayExpenses,
                                settings.currency,
                              ),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFFB7185),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.cardBackgroundDark
              : AppColors.cardBackgroundLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 14, color: color),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final IconData? icon;
  final Widget? iconWidget;
  final Color color;
  final String title;
  final String subtitle;
  final String time;

  const _TimelineRow({
    this.icon,
    this.iconWidget,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: iconWidget ?? Icon(icon!, color: color, size: 16),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
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
        Text(
          time,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.textTertiaryDark
                : AppColors.textTertiaryLight,
          ),
        ),
      ],
    );
  }
}
