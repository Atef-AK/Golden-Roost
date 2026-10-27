import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/responsive.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/egg_record.dart';
import '../../../models/finance.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/egg_provider.dart';
import '../../../providers/finance_provider.dart';
import '../../../providers/settings_provider.dart';

class DashboardAnalyticsCard extends ConsumerStatefulWidget {
  const DashboardAnalyticsCard({super.key});

  @override
  ConsumerState<DashboardAnalyticsCard> createState() =>
      _DashboardAnalyticsCardState();
}

class _DashboardAnalyticsCardState extends ConsumerState<DashboardAnalyticsCard> {
  int _selectedTab = 0; // 0: Egg Yield, 1: Cash Flow, 2: Feed Runway

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final eggLogs = ref.watch(eggLogsProvider);
    final finances = ref.watch(financesProvider);
    final stats = ref.watch(dashboardStatsProvider);
    final settings = ref.watch(settingsProvider);

    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Metric Filter Pills
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primaryTeal.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.auto_graph_rounded,
                        color: AppColors.primaryTeal,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        context.tr('dash_analytics_title'),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
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
            ],
          ),
          const SizedBox(height: 14),

          // Custom Tab Selector Pills
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.cardBackgroundDark
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _TabButton(
                    label: context.tr('dash_tab_eggs'),
                    icon: AppIcons.eggs,
                    isSelected: _selectedTab == 0,
                    activeColor: AppColors.warning,
                    onTap: () => setState(() => _selectedTab = 0),
                  ),
                ),
                Expanded(
                  child: _TabButton(
                    label: context.tr('dash_tab_finance'),
                    icon: Icons.payments_outlined,
                    isSelected: _selectedTab == 1,
                    activeColor: AppColors.semanticSuccess,
                    onTap: () => setState(() => _selectedTab = 1),
                  ),
                ),
                Expanded(
                  child: _TabButton(
                    label: context.tr('dash_tab_feed'),
                    icon: AppIcons.feed,
                    isSelected: _selectedTab == 2,
                    activeColor: AppColors.primaryTeal,
                    onTap: () => setState(() => _selectedTab = 2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Active Chart Presentation
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _selectedTab == 0
                ? _EggTrendChart(
                    key: const ValueKey('egg_chart'),
                    eggLogs: eggLogs,
                    isDark: isDark,
                  )
                : _selectedTab == 1
                    ? _CashFlowChart(
                        key: const ValueKey('cash_chart'),
                        finances: finances,
                        currency: settings.currency,
                        isDark: isDark,
                      )
                    : _FeedRunwayIndicator(
                        key: const ValueKey('feed_runway'),
                        stats: stats,
                        isDark: isDark,
                      ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF1E293B) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 30 : 15),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected
                  ? activeColor
                  : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight)
                      : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// 1. Egg Production Trend (7-Day Curved Area Line Chart)
// -------------------------------------------------------------
class _EggTrendChart extends StatelessWidget {
  final List<EggLog> eggLogs;
  final bool isDark;

  const _EggTrendChart({
    super.key,
    required this.eggLogs,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Group collections for the last 7 calendar days
    final List<DateTime> last7Days = List.generate(
      7,
      (i) => today.subtract(Duration(days: 6 - i)),
    );

    final Map<String, int> dailyCounts = {};
    for (final day in last7Days) {
      final key = DateFormat('yyyy-MM-dd').format(day);
      dailyCounts[key] = 0;
    }

    for (final log in eggLogs) {
      final key = DateFormat('yyyy-MM-dd').format(log.date);
      if (dailyCounts.containsKey(key)) {
        dailyCounts[key] = (dailyCounts[key] ?? 0) + log.totalEggs;
      }
    }

    final spots = <FlSpot>[];
    int total7d = 0;
    int maxEggs = 0;
    String peakDayLabel = '—';

    for (int i = 0; i < last7Days.length; i++) {
      final day = last7Days[i];
      final key = DateFormat('yyyy-MM-dd').format(day);
      final count = dailyCounts[key] ?? 0;
      total7d += count;
      if (count > maxEggs) {
        maxEggs = count;
        peakDayLabel = DateFormat(
          'E',
          Localizations.localeOf(context).languageCode,
        ).format(day);
      }
      spots.add(FlSpot(i.toDouble(), count.toDouble()));
    }

    final double avgDaily = total7d / 7.0;
    final double maxY = max(10.0, (maxEggs * 1.25).ceilToDouble());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary KPI Banner
        Row(
          children: [
            _MiniKpi(
              label: context.tr('dash_total_7d'),
              value: '$total7d',
              color: AppColors.warning,
            ),
            const SizedBox(width: 12),
            _MiniKpi(
              label: context.tr('dash_avg_daily'),
              value: avgDaily.toStringAsFixed(1),
              color: AppColors.primaryTeal,
            ),
            const SizedBox(width: 12),
            _MiniKpi(
              label: context.tr('dash_peak_day'),
              value: '$maxEggs ($peakDayLabel)',
              color: AppColors.semanticSuccess,
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Line Chart
        SizedBox(
          height: 160,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY > 20 ? (maxY / 4).roundToDouble() : 5,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: isDark
                      ? AppColors.borderDark.withAlpha(70)
                      : AppColors.borderLight,
                  strokeWidth: 0.8,
                  dashArray: [4, 4],
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: maxY > 20 ? (maxY / 3).roundToDouble() : 5,
                    getTitlesWidget: (val, meta) {
                      return Text(
                        val.toInt().toString(),
                        style: TextStyle(
                          fontSize: 9.5,
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    interval: 1,
                    getTitlesWidget: (val, meta) {
                      final idx = val.toInt();
                      if (idx < 0 || idx >= last7Days.length) {
                        return const SizedBox.shrink();
                      }
                      final isToday = idx == 6;
                      final day = last7Days[idx];
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          isToday
                              ? context.tr('dash_today')
                              : DateFormat(
                                  'E',
                                  Localizations.localeOf(context).languageCode,
                                ).format(day),
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight:
                                isToday ? FontWeight.w700 : FontWeight.w500,
                            color: isToday
                                ? AppColors.warning
                                : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: 6,
              minY: 0,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.35,
                  color: AppColors.warning,
                  barWidth: 2.8,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.warning.withAlpha(isDark ? 65 : 45),
                        AppColors.warning.withAlpha(0),
                      ],
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFF0F172A),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final idx = spot.x.toInt();
                      final dayStr = idx >= 0 && idx < last7Days.length
                          ? DateFormat('EEE, MMM d').format(last7Days[idx])
                          : '';
                      return LineTooltipItem(
                        '${spot.y.toInt()} eggs\n',
                        const TextStyle(
                          color: AppColors.warning,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: dayStr,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.normal,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------
// 2. Weekly Farm Cash Flow (Income vs Operating Expenses BarChart)
// -------------------------------------------------------------
class _CashFlowChart extends StatelessWidget {
  final List<FinancialTransaction> finances;
  final String currency;
  final bool isDark;

  const _CashFlowChart({
    super.key,
    required this.finances,
    required this.currency,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final List<DateTime> last7Days = List.generate(
      7,
      (i) => today.subtract(Duration(days: 6 - i)),
    );

    final Map<String, double> dailyIncome = {};
    final Map<String, double> dailyExpense = {};

    for (final day in last7Days) {
      final key = DateFormat('yyyy-MM-dd').format(day);
      dailyIncome[key] = 0.0;
      dailyExpense[key] = 0.0;
    }

    double totalIncome7d = 0.0;
    double totalExpense7d = 0.0;

    for (final tx in finances) {
      final key = DateFormat('yyyy-MM-dd').format(tx.date);
      if (dailyIncome.containsKey(key)) {
        if (tx.isIncome) {
          dailyIncome[key] = (dailyIncome[key] ?? 0.0) + tx.amount;
          totalIncome7d += tx.amount;
        } else if (tx.isExpense) {
          dailyExpense[key] = (dailyExpense[key] ?? 0.0) + tx.amount;
          totalExpense7d += tx.amount;
        }
      }
    }

    double maxVal = 0.0;
    for (int i = 0; i < last7Days.length; i++) {
      final key = DateFormat('yyyy-MM-dd').format(last7Days[i]);
      maxVal = max(maxVal, max(dailyIncome[key] ?? 0.0, dailyExpense[key] ?? 0.0));
    }
    final double maxY = max(50.0, (maxVal * 1.25).ceilToDouble());
    final double net7d = totalIncome7d - totalExpense7d;

    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < last7Days.length; i++) {
      final key = DateFormat('yyyy-MM-dd').format(last7Days[i]);
      final inc = dailyIncome[key] ?? 0.0;
      final exp = dailyExpense[key] ?? 0.0;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barsSpace: 4,
          barRods: [
            BarChartRodData(
              toY: inc,
              color: AppColors.semanticSuccess,
              width: 7,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
            ),
            BarChartRodData(
              toY: exp,
              color: const Color(0xFFE11D48),
              width: 7,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary KPI Banner
        Row(
          children: [
            _MiniKpi(
              label: context.tr('dash_income'),
              value: '+${AppFormatters.formatCurrency(totalIncome7d, currency)}',
              color: AppColors.semanticSuccess,
            ),
            const SizedBox(width: 10),
            _MiniKpi(
              label: context.tr('dash_expense'),
              value: '-${AppFormatters.formatCurrency(totalExpense7d, currency)}',
              color: const Color(0xFFE11D48),
            ),
            const SizedBox(width: 10),
            _MiniKpi(
              label: context.tr('dash_net'),
              value: '${net7d >= 0 ? '+' : ''}${AppFormatters.formatCurrency(net7d, currency)}',
              color: net7d >= 0 ? AppColors.semanticSuccess : const Color(0xFFE11D48),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Bar Chart
        SizedBox(
          height: 160,
          child: BarChart(
            BarChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY / 3,
                getDrawingHorizontalLine: (val) => FlLine(
                  color: isDark
                      ? AppColors.borderDark.withAlpha(70)
                      : AppColors.borderLight,
                  strokeWidth: 0.8,
                  dashArray: [4, 4],
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: maxY / 3,
                    getTitlesWidget: (val, meta) {
                      return Text(
                        val.toInt().toString(),
                        style: TextStyle(
                          fontSize: 9.5,
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    interval: 1,
                    getTitlesWidget: (val, meta) {
                      final idx = val.toInt();
                      if (idx < 0 || idx >= last7Days.length) {
                        return const SizedBox.shrink();
                      }
                      final isToday = idx == 6;
                      final day = last7Days[idx];
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          isToday
                              ? context.tr('dash_today')
                              : DateFormat(
                                  'E',
                                  Localizations.localeOf(context).languageCode,
                                ).format(day),
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight:
                                isToday ? FontWeight.w700 : FontWeight.w500,
                            color: isToday
                                ? AppColors.primaryTeal
                                : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minY: 0,
              maxY: maxY,
              barGroups: barGroups,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFF0F172A),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final isInc = rodIndex == 0;
                    return BarTooltipItem(
                      '${isInc ? context.tr('dash_income') : context.tr('dash_expense')}: ${rod.toY.toStringAsFixed(1)} $currency',
                      TextStyle(
                        color: isInc
                            ? AppColors.semanticSuccess
                            : const Color(0xFFE11D48),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------
// 3. Feed Stock & Burn Rate Runway Indicator
// -------------------------------------------------------------
class _FeedRunwayIndicator extends StatelessWidget {
  final DashboardStats stats;
  final bool isDark;

  const _FeedRunwayIndicator({
    super.key,
    required this.stats,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final daysRemaining = stats.feedDaysRemaining;
    final stockKg = stats.totalFeedStockKg;
    final dailyBurnKg = stats.dailyFeedDemandKg;
    final hasBirds = stats.totalLiveBirds > 0;
    final isCritical = hasBirds && stockKg > 0 && daysRemaining <= 3;
    final isWarning = hasBirds && stockKg > 0 && daysRemaining > 3 && daysRemaining <= 7;

    final statusColor = !hasBirds || stockKg <= 0
        ? AppColors.primaryTeal
        : (isCritical
            ? AppColors.error
            : isWarning
                ? AppColors.warning
                : AppColors.semanticSuccess);

    final statusText = !hasBirds
        ? context.tr('flocks_empty')
        : (stockKg <= 0
            ? context.tr('dash_feed_status_critical')
            : (isCritical
                ? context.tr('dash_feed_status_critical')
                : isWarning
                    ? context.tr('dash_feed_status_warning')
                    : context.tr('dash_feed_status_good')));

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: statusColor.withAlpha(60),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          AppIcons.feed,
                          color: statusColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasBirds && stockKg > 0
                                ? '$daysRemaining ${context.tr('dash_feed_days_left')}'
                                : '-- ${context.tr('dash_feed_days_left')}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                            ),
                          ),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${AppFormatters.formatWeight(stockKg)} ${context.tr('dash_in_silo')}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (daysRemaining / 30.0).clamp(0.05, 1.0),
                  minHeight: 8,
                  backgroundColor: isDark
                      ? AppColors.borderDark
                      : const Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            _MiniKpi(
              label: context.tr('dash_daily_burn'),
              value: '~${dailyBurnKg.toStringAsFixed(1)} kg/day',
              color: AppColors.primaryTeal,
            ),
            const SizedBox(width: 10),
            _MiniKpi(
              label: context.tr('dash_days_supply'),
              value: '$daysRemaining ${context.tr('flocks_days')}',
              color: statusColor,
            ),
            const SizedBox(width: 10),
            _MiniKpi(
              label: context.tr('dash_total_flocks_fed'),
              value: '${stats.totalLiveBirds} ${context.tr('birds')}',
              color: AppColors.warning,
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniKpi extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniKpi({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
