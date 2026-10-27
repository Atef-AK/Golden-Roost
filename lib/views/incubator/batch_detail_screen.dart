import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/localization/app_translations.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/responsive.dart';
import '../../core/utils/formatters.dart';
import '../../models/incubation.dart';
import '../../providers/incubation_provider.dart';
import '../../providers/settings_provider.dart';

class BatchDetailScreen extends ConsumerStatefulWidget {
  final String batchId;

  const BatchDetailScreen({super.key, required this.batchId});

  @override
  ConsumerState<BatchDetailScreen> createState() => _BatchDetailScreenState();
}

class _BatchDetailScreenState extends ConsumerState<BatchDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final batches = ref.watch(incubationBatchesProvider);
    final batch = batches.cast<IncubationBatch?>().firstWhere(
      (b) => b?.id == widget.batchId,
      orElse: () => null,
    );

    final currency = ref.watch(settingsProvider).currency;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (batch == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('batch_not_found_title'))),
        body: Center(
          child: Text(context.tr('batch_not_found_desc')),
        ),
      );
    }

    final readingsAsync = ref.watch(incubationReadingsProvider(batch.id));
    final isActive = batch.status == 'incubating';

    return Scaffold(
      appBar: AppBar(
        title: Text('${context.trSpecies(batch.species)} - ${context.tr('incubator_title')}'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'delete') _deleteBatch(batch);
            },
            itemBuilder: (ctx) => [
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
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
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
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                  ),
                  icon: const Icon(Icons.device_thermostat, size: 14),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(context.tr('incubator_log_reading'), maxLines: 1),
                  ),
                  onPressed: () => _showAddReadingDialog(batch),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                  ),
                  icon: const Icon(Icons.wb_sunny_outlined, size: 14),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(context.tr('incubator_candling'), maxLines: 1),
                  ),
                  onPressed: () => _showCandlingDialog(batch),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                  ),
                  onPressed: () => _showHatchResultsDialog(batch),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(context.tr('incubator_hatched'), maxLines: 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ResponsiveContainer(
        maxWidth: 1000,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            // Countdown / Status Hero Card
            PremiumCard(
              padding: const EdgeInsets.all(18),
              borderColor: isActive
                  ? AppColors.primaryTeal.withAlpha(50)
                  : null,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${batch.eggsSetCount} ${context.tr('incubator_eggs_set')}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${context.tr('incubator_title')}: ${batch.incubatorName}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.textMutedDark
                                    : AppColors.textMutedLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(
                        label: isActive
                            ? '${batch.daysUntilHatch} ${context.tr('incubator_days_left_badge')}'
                            : batch.status.toUpperCase(),
                        variant: isActive
                            ? BadgeVariant.primary
                            : BadgeVariant.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (batch.daysSinceSet / batch.durationDays).clamp(
                        0.0,
                        1.0,
                      ),
                      minHeight: 8,
                      backgroundColor: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFE2E8F0),
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
                          '${context.tr('incubator_day_x_of_y')} ${batch.daysSinceSet} ${context.tr('flocks_of')} ${batch.durationDays}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
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
                        '${context.tr('incubator_expected_hatch_short')}: ${AppFormatters.formatShortDate(batch.expectedHatchDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Rates & Financial Metrics
            PremiumCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('incubator_perf_rates'),
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MetricItem(
                        label: context.tr('incubator_fertility_rate'),
                        value: AppFormatters.formatPercent(batch.fertilityRate),
                      ),
                      _MetricItem(
                        label: context.tr('incubator_hatch_rate_set'),
                        value: AppFormatters.formatPercent(
                          batch.hatchRateFromSet,
                        ),
                      ),
                      _MetricItem(
                        label: context.tr('incubator_hatch_rate_fertile'),
                        value: AppFormatters.formatPercent(
                          batch.hatchRateFromFertile,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    height: 24,
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MetricItem(
                        label: context.tr('incubator_fertile_eggs'),
                        value:
                            '${batch.fertileEggsCount} / ${batch.eggsSetCount}',
                      ),
                      _MetricItem(
                        label: context.tr('incubator_hatched_chicks'),
                        value: '${batch.hatchedCount}',
                        color: AppColors.semanticSuccess,
                      ),
                      _MetricItem(
                        label: context.tr('incubator_dead_in_shell_label'),
                        value: '${batch.deadInShellCount}',
                        color: AppColors.semanticError,
                      ),
                    ],
                  ),
                  Divider(
                    height: 24,
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MetricItem(
                        label: context.tr('incubator_total_batch_cost'),
                        value: AppFormatters.formatCurrency(
                          batch.totalBatchCost,
                          currency,
                        ),
                      ),
                      _MetricItem(
                        label: context.tr('incubator_cost_per_chick_label'),
                        value: batch.hatchedCount > 0
                            ? AppFormatters.formatCurrency(
                                batch.costPerChick,
                                currency,
                              )
                            : 'N/A',
                        color: AppColors.primaryTeal,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // If chicks have hatched, show transfer to flock button!
            if (batch.hatchedCount > 0 && batch.status != 'transferred') ...[
              const SizedBox(height: 14),
              PremiumCard(
                borderColor: AppColors.semanticSuccess.withAlpha(50),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.semanticSuccess.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.add_home_work_outlined,
                        color: AppColors.semanticSuccess,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${batch.hatchedCount} ${context.tr('incubator_chicks_ready')}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? const Color(0xFF4ADE80)
                                  : AppColors.semanticSuccess,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.tr('incubator_transfer_desc'),
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
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryTeal,
                      ),
                      onPressed: () => _showTransferWizard(batch),
                      child: Text(context.tr('incubator_transfer_btn')),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Temperature & Humidity Log
            SectionHeader(
              title: context.tr('incubator_temp_hum_logs'),
              actionLabel: context.tr('incubator_log_btn'),
              onAction: () => _showAddReadingDialog(batch),
            ),
            const SizedBox(height: 8),

            readingsAsync.when(
              data: (readings) {
                if (readings.isEmpty) {
                  return PremiumCard(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        context.tr('incubator_no_readings'),
                        style: TextStyle(
                          fontSize: 13,
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
                  children: readings.map((r) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: PremiumCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryTeal.withAlpha(15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.device_thermostat,
                                color: AppColors.primaryTeal,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${r.temperatureC.toStringAsFixed(1)}°C • ${r.humidityPercent.toStringAsFixed(0)}% Humidity',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${AppFormatters.formatShortDate(r.dateTime)} ${r.dateTime.hour}:${r.dateTime.minute.toString().padLeft(2, '0')} • Turner: ${r.turned ? "Turned" : "Static"} ${r.notes.isNotEmpty ? '• ${r.notes}' : ''}',
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
              error: (err, _) => Text('Error loading readings: $err'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddReadingDialog(IncubationBatch batch) {
    final tempCtrl = TextEditingController(text: '37.6');
    final humCtrl = TextEditingController(text: '55');
    final notesCtrl = TextEditingController();
    bool turned = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: Text(context.tr('incubator_log_reading')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: tempCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: context.tr('incubator_temp'),
                          suffixText: '°C',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: humCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: context.tr('incubator_humidity'),
                          suffixText: '%',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: Text(context.tr('incubator_eggs_turned')),
                  value: turned,
                  activeColor: AppColors.primaryTeal,
                  onChanged: (val) => setDState(() => turned = val ?? true),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesCtrl,
                  decoration: InputDecoration(
                    labelText: context.tr('incubator_notes_hint'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.tr('cancel')),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
              ),
              onPressed: () {
                final temp = double.tryParse(tempCtrl.text) ?? 37.5;
                final hum = double.tryParse(humCtrl.text) ?? 55.0;

                ref
                    .read(incubationBatchesProvider.notifier)
                    .addReading(
                      IncubationReading(
                        id: const Uuid().v4(),
                        batchId: batch.id,
                        dateTime: DateTime.now(),
                        temperatureC: temp,
                        humidityPercent: hum,
                        turned: turned,
                        notes: notesCtrl.text.trim(),
                      ),
                    );

                Navigator.pop(ctx);
                ref.invalidate(incubationReadingsProvider(batch.id));
              },
              child: Text(context.tr('save')),
            ),
          ],
        ),
      ),
    );
  }

  void _showCandlingDialog(IncubationBatch batch) {
    final fertileCtrl = TextEditingController(
      text: batch.fertileEggsCount.toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('incubator_record_candling')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${context.tr('incubator_eggs_set')}: ${batch.eggsSetCount}'),
            const SizedBox(height: 12),
            TextField(
              controller: fertileCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: context.tr('incubator_num_fertile'),
                helperText: context.tr('incubator_embryo_helper'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
            ),
            onPressed: () {
              final fertile = int.tryParse(fertileCtrl.text) ?? 0;
              final updated = batch.copyWith(
                fertileEggsCount: fertile,
                candlingDate: DateTime.now(),
              );
              ref.read(incubationBatchesProvider.notifier).updateBatch(updated);
              Navigator.pop(ctx);
            },
            child: Text(context.tr('save')),
          ),
        ],
      ),
    );
  }

  void _showHatchResultsDialog(IncubationBatch batch) {
    final hatchedCtrl = TextEditingController(
      text: batch.hatchedCount.toString(),
    );
    final deadCtrl = TextEditingController(
      text: batch.deadInShellCount.toString(),
    );
    final culledCtrl = TextEditingController(
      text: batch.culledChicksCount.toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('incubator_hatch_results')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: hatchedCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.tr('incubator_healthy_hatched'),
                  prefixIcon: const Icon(AppIcons.chicks),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: deadCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.tr('incubator_dead_in_shell_label'),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: culledCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.tr('incubator_culled_weak'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
            ),
            onPressed: () {
              final hatched = int.tryParse(hatchedCtrl.text) ?? 0;
              final dead = int.tryParse(deadCtrl.text) ?? 0;
              final culled = int.tryParse(culledCtrl.text) ?? 0;

              final updated = batch.copyWith(
                hatchedCount: hatched,
                deadInShellCount: dead,
                culledChicksCount: culled,
                status: 'completed',
              );

              ref.read(incubationBatchesProvider.notifier).updateBatch(updated);
              Navigator.pop(ctx);
            },
            child: Text(context.tr('save')),
          ),
        ],
      ),
    );
  }

  void _showTransferWizard(IncubationBatch batch) {
    final nameCtrl = TextEditingController(
      text:
          '${batch.species.toUpperCase()} Chicks Batch ${AppFormatters.formatShortDate(DateTime.now())}',
    );
    final penCtrl = TextEditingController(text: 'Brooder Box A');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('incubator_transfer_title')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${context.tr('incubator_transfer_btn')}: ${batch.hatchedCount} (${batch.incubatorName}).',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: context.tr('incubator_new_flock_name'),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: penCtrl,
              decoration: InputDecoration(
                labelText: context.tr('incubator_pen_location'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
            ),
            onPressed: () async {
              final successMsg = context.tr('incubator_transferred_success');
              await ref
                  .read(incubationBatchesProvider.notifier)
                  .transferChicksToNewFlock(
                    batch: batch,
                    newFlockName: nameCtrl.text.trim(),
                    housingLocation: penCtrl.text.trim(),
                  );
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: Text(successMsg),
                  ),
                );
              }
            },
            child: Text(context.tr('incubator_confirm_transfer')),
          ),
        ],
      ),
    );
  }

  void _deleteBatch(IncubationBatch batch) {
    ref.read(incubationBatchesProvider.notifier).deleteBatch(batch.id);
    context.pop();
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _MetricItem({required this.label, required this.value, this.color});

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
                  fontSize: 15,
                  color: color ??
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
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
