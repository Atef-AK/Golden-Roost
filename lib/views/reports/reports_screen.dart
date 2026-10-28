import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/app_translations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/responsive.dart';
import '../../core/utils/csv_exporter.dart';
import '../../core/utils/pdf_report_generator.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/egg_provider.dart';
import '../../providers/feed_provider.dart';
import '../../providers/finance_provider.dart';
import '../../providers/flock_provider.dart';
import '../../providers/settings_provider.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final flocks = ref.watch(flocksProvider);
    final eggLogs = ref.watch(eggLogsProvider);
    final settings = ref.watch(settingsProvider);
    final currency = settings.currency;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('reports_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: context.tr('reports_generate_pdf'),
            onPressed: () => _generatePdf(context),
          ),
        ],
      ),
      body: ResponsiveContainer(
        maxWidth: 1000,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            // Export Actions Hero Card
            PremiumCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal.withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.picture_as_pdf,
                          color: AppColors.primaryTeal,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('reports_exec_title'),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.tr('reports_exec_desc'),
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
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryTeal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.picture_as_pdf, size: 18),
                      label: Text(
                        _isExporting
                            ? 'Generating PDF...'
                            : context.tr('reports_export_pdf_btn'),
                      ),
                      onPressed: _isExporting
                          ? null
                          : () => _generatePdf(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.table_chart, size: 14),
                        label: Text(context.tr('reports_csv_flocks')),
                        onPressed: () => _exportCsv('flocks'),
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.table_chart, size: 14),
                        label: Text(context.tr('reports_csv_eggs')),
                        onPressed: () => _exportCsv('eggs'),
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.table_chart, size: 14),
                        label: Text(context.tr('reports_csv_finances')),
                        onPressed: () => _exportCsv('finances'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 1. Egg Production Trend Graph (FlChart)
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
                          context.tr('eggs_laying_trend'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.show_chart,
                        color: AppColors.primaryTeal,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.tr('reports_egg_trend_sub'),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 180,
                    child: _buildEggProductionChart(eggLogs, isDark),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. Financial Income vs Expense Bar Chart
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
                          context.tr('reports_fin_perf_title'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.bar_chart,
                        color: AppColors.primaryTeal,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${context.tr('reports_fin_perf_sub')} ($currency)',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 180,
                    child: _buildFinancesBarChart(
                      ref.watch(financesProvider.notifier),
                      isDark,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. Performance Summary Table
            PremiumCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('reports_flock_performance'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (flocks.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          context.tr('reports_no_flocks'),
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                        ),
                      ),
                    )
                  else
                    ...flocks.map((f) {
                      final flockEggs = eggLogs
                          .where((e) => e.flockId == f.id)
                          .fold(0, (sum, e) => sum + e.totalEggs);
                      final mortality = f.startCount > f.currentCount
                          ? (f.startCount - f.currentCount)
                          : 0;
                      final mortPercent =
                          (mortality / (f.startCount > 0 ? f.startCount : 1)) *
                          100;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.cardDark
                                : AppColors.pageBackgroundLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      f.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  StatusBadge(
                                    label:
                                        '${f.currentCount} ${context.tr('movement_live')}',
                                    variant: BadgeVariant.success,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${context.tr('flocks_species')}: ${context.trSpecies(f.species)} • ${context.tr('flocks_age')}: ${f.ageInDays}${context.tr('flocks_days_short')}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark
                                            ? AppColors.textMutedDark
                                            : AppColors.textMutedLight,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${context.tr('eggs_title')}: $flockEggs',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryTeal,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${context.tr('flocks_mortality')}: $mortality ${context.tr('flocks_lost')} (${mortPercent.toStringAsFixed(1)}%)',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: mortPercent > 5
                                      ? AppColors.semanticError
                                      : (isDark
                                            ? AppColors.textMutedDark
                                            : AppColors.textMutedLight),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEggProductionChart(List<dynamic> logs, bool isDark) {
    if (logs.isEmpty) {
      return Center(
        child: Text(
          context.tr('reports_no_egg_data'),
          style: TextStyle(
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
      );
    }

    final recent = logs.take(7).toList().reversed.toList();
    final spots = <FlSpot>[];
    for (int i = 0; i < recent.length; i++) {
      spots.add(FlSpot(i.toDouble(), recent[i].totalEggs.toDouble()));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                final idx = val.toInt();
                if (idx >= 0 && idx < recent.length) {
                  return Text(
                    'D${recent[idx].date.day}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primaryTeal,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primaryTeal.withAlpha(25),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancesBarChart(FinancesNotifier notifier, bool isDark) {
    final income = notifier.totalOperatingIncome;
    final expenses = notifier.totalOperatingExpenses;
    final net = notifier.netOperatingResult;

    if (income == 0 && expenses == 0) {
      return Center(
        child: Text(
          context.tr('reports_no_finance_data'),
          style: TextStyle(
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                switch (val.toInt()) {
                  case 0:
                    return Text(
                      context.tr('finance_income'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    );
                  case 1:
                    return Text(
                      context.tr('finance_expenses'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    );
                  case 2:
                    return Text(
                      context.tr('finance_net_profit'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    );
                  default:
                    return const SizedBox();
                }
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: income,
                color: isDark
                    ? const Color(0xFF4ADE80)
                    : AppColors.semanticSuccess,
                width: 24,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: expenses,
                color: isDark
                    ? const Color(0xFFF87171)
                    : AppColors.semanticError,
                width: 24,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                toY: net < 0 ? 0 : net,
                color: AppColors.primaryTeal,
                width: 24,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _generatePdf(BuildContext context) async {
    setState(() => _isExporting = true);
    try {
      final flocks = ref.read(flocksProvider);
      final feedItems = ref.read(feedInventoryProvider);
      final finances = ref.read(financesProvider);
      final stats = ref.read(dashboardStatsProvider);
      final settings = ref.read(settingsProvider);
      final notifier = ref.read(financesProvider.notifier);

      final pdfBytes = await PdfReportGenerator.generateFarmReport(
        settings: settings,
        flocks: flocks,
        feedItems: feedItems,
        finances: finances,
        totalLiveBirds: stats.totalLiveBirds,
        eggsCollectedToday: stats.eggsCollectedToday,
        totalIncome: notifier.totalOperatingIncome,
        totalExpenses: notifier.totalOperatingExpenses,
        netProfit: notifier.netOperatingResult,
      );

      await PdfReportGenerator.printOrShareReport(pdfBytes);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Report generation: $e')));
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _exportCsv(String type) async {
    try {
      String path = '';
      if (type == 'flocks') {
        path = await CsvExporter.exportFlocks(ref.read(flocksProvider));
      } else if (type == 'eggs') {
        path = await CsvExporter.exportEggLogs(ref.read(eggLogsProvider));
      } else if (type == 'finances') {
        path = await CsvExporter.exportFinances(ref.read(financesProvider));
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Exported to: $path')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('CSV Export error: $e')));
    }
  }
}
