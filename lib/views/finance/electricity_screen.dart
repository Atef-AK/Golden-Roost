import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/localization/app_translations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/responsive.dart';
import '../../core/utils/formatters.dart';
import '../../models/electricity.dart';
import '../../providers/finance_provider.dart';
import '../../providers/settings_provider.dart';

class ElectricityScreen extends ConsumerStatefulWidget {
  const ElectricityScreen({super.key});

  @override
  ConsumerState<ElectricityScreen> createState() => _ElectricityScreenState();
}

class _ElectricityScreenState extends ConsumerState<ElectricityScreen> {
  // Wattage Calculator controllers
  final _calcWattageController = TextEditingController(text: '150');
  final _calcHoursController = TextEditingController(text: '24');
  final _calcDaysController = TextEditingController(text: '30');

  @override
  void dispose() {
    _calcWattageController.dispose();
    _calcHoursController.dispose();
    _calcDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final readings = ref.watch(electricityReadingsProvider);
    final equipment = ref.watch(equipmentProvider);
    final settings = ref.watch(settingsProvider);
    final currency = settings.currency;
    final tariff = settings.electricityKwhRate;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculation result
    final watts = double.tryParse(_calcWattageController.text) ?? 0.0;
    final hours = double.tryParse(_calcHoursController.text) ?? 0.0;
    final days = int.tryParse(_calcDaysController.text) ?? 1;
    final calculatedKwh = (watts * hours * days) / 1000.0;
    final calculatedCost = calculatedKwh * tariff;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('finance_electricity')),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: context.tr('electricity_change_tariff'),
            onPressed: () => _editTariffDialog(context, tariff),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_electricity',
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.speed),
        label: Text(context.tr('electricity_add_reading')),
        onPressed: () => _addMeterReadingDialog(context, tariff),
      ),
      body: ResponsiveContainer(
        maxWidth: 1000,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            // Tariff banner
            Padding(
              padding: const EdgeInsets.all(16),
              child: PremiumCard(
                borderColor: AppColors.primaryTeal.withAlpha(40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryTeal.withAlpha(20),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.bolt,
                              color: AppColors.primaryTeal,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.tr('finance_kwh_rate'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.textMutedDark
                                        : AppColors.textMutedLight,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '${tariff.toStringAsFixed(3)} $currency / kWh',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                      ),
                      onPressed: () => _editTariffDialog(context, tariff),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(context.tr('electricity_change_tariff'), maxLines: 1),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Wattage & Equipment Estimator Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calculate_outlined,
                          color: AppColors.primaryTeal,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            context.tr('finance_calc_wattage'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    LayoutBuilder(
                      builder: (ctx, constraints) {
                        final isNarrow = constraints.maxWidth < 420;
                        if (isNarrow) {
                          return Column(
                            children: [
                              TextField(
                                controller: _calcWattageController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: context.tr('electricity_calc_power'),
                                  suffixText: 'W',
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _calcHoursController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: context.tr('electricity_calc_hours'),
                                        suffixText: 'h',
                                      ),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _calcDaysController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: context.tr('electricity_calc_days'),
                                        suffixText: 'd',
                                      ),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }
                        return Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _calcWattageController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: context.tr('electricity_calc_power'),
                                  suffixText: 'W',
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _calcHoursController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: context.tr('electricity_calc_hours'),
                                  suffixText: 'h',
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _calcDaysController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: context.tr('electricity_calc_days'),
                                  suffixText: 'd',
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTeal.withAlpha(
                          isDark ? 20 : 12,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primaryTeal.withAlpha(40),
                        ),
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        runSpacing: 6,
                        spacing: 8,
                        children: [
                          Text(
                            '${context.tr('electricity_calc_energy')}: ${calculatedKwh.toStringAsFixed(1)} kWh',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                            ),
                          ),
                          Text(
                            '${context.tr('electricity_calc_est')}: ${AppFormatters.formatCurrency(calculatedCost, currency)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: AppColors.primaryTeal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Equipment inventory
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SectionHeader(
                title: context.tr('electricity_equipment_title'),
                actionLabel: context.tr('electricity_add_equipment'),
                onAction: () => _addEquipmentDialog(context),
              ),
            ),
            const SizedBox(height: 8),

            if (equipment.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PremiumCard(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      context.tr('electricity_no_equipment'),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: equipment.map((eq) {
                    final monthlyCost = eq.monthlyCost(tariff);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: PremiumCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryTeal.withAlpha(15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.electrical_services,
                                color: AppColors.primaryTeal,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    eq.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${eq.wattage.toStringAsFixed(0)}W • ${eq.dailyOperatingHours}h/day • ${eq.dailyKwh.toStringAsFixed(2)} kWh/day',
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
                            Text(
                              '~${AppFormatters.formatCurrency(monthlyCost, currency)}/mo',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: AppColors.primaryTeal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 20),

            // Past Meter Readings
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SectionHeader(
                title: context.tr('electricity_readings_title'),
                actionLabel: context.tr('electricity_log_reading'),
                onAction: () => _addMeterReadingDialog(context, tariff),
              ),
            ),
            const SizedBox(height: 8),

            if (readings.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PremiumCard(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      context.tr('electricity_no_readings'),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: readings.map((r) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: PremiumCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.accentLime.withAlpha(
                                  isDark ? 25 : 35,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.speed,
                                color: AppColors.primaryTeal,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${r.kwhConsumed.toStringAsFixed(1)} kWh (${r.meterReadingKwh.toStringAsFixed(0)} ${context.tr('electricity_on_meter')})',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${AppFormatters.formatShortDate(r.date)} ${r.notes.isNotEmpty ? '• ${r.notes}' : ''}',
                                    style: TextStyle(
                                      fontSize: 11,
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
                            Text(
                              AppFormatters.formatCurrency(
                                r.totalCost,
                                currency,
                              ),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: isDark
                                    ? const Color(0xFFF87171)
                                    : AppColors.semanticError,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _editTariffDialog(BuildContext context, double currentTariff) {
    final ctrl = TextEditingController(text: currentTariff.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('finance_electricity_update_tariff_title')),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: context.tr('finance_kwh_rate'),
            suffixText: '${context.tr('tnd')}/kWh',
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
              final newRate = double.tryParse(ctrl.text) ?? currentTariff;
              ref
                  .read(settingsProvider.notifier)
                  .updateElectricityTariff(newRate);
              Navigator.pop(ctx);
            },
            child: Text(context.tr('save')),
          ),
        ],
      ),
    );
  }

  void _addMeterReadingDialog(BuildContext context, double currentTariff) {
    final meterCtrl = TextEditingController();
    final kwhCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: Text(context.tr('finance_electricity_record_reading_title')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: meterCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: context.tr('finance_electricity_current_reading'),
                    suffixText: 'kWh',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: kwhCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: context.tr('finance_electricity_consumed_period'),
                    suffixText: 'kWh',
                  ),
                  onChanged: (val) {
                    final kwh = double.tryParse(val) ?? 0.0;
                    setDState(() {
                      costCtrl.text = (kwh * currentTariff).toStringAsFixed(3);
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: costCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: context.tr('finance_amount'),
                    suffixText: context.tr('tnd'),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  decoration: InputDecoration(
                    labelText: '${context.tr('notes')} (e.g. Monthly coop bill)',
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
                final meter = double.tryParse(meterCtrl.text) ?? 0.0;
                final kwh = double.tryParse(kwhCtrl.text) ?? 0.0;
                final cost =
                    double.tryParse(costCtrl.text) ?? (kwh * currentTariff);

                ref
                    .read(electricityReadingsProvider.notifier)
                    .addReading(
                      ElectricityReading(
                        id: const Uuid().v4(),
                        date: DateTime.now(),
                        meterReadingKwh: meter,
                        kwhConsumed: kwh,
                        tariffPerKwh: currentTariff,
                        totalCost: cost,
                        notes: notesCtrl.text.trim(),
                        createdAt: DateTime.now(),
                      ),
                    );

                Navigator.pop(ctx);
              },
              child: Text(context.tr('finance_electricity_save_reading')),
            ),
          ],
        ),
      ),
    );
  }

  void _addEquipmentDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final wattageCtrl = TextEditingController(text: '100');
    final hoursCtrl = TextEditingController(text: '24');
    final costCtrl = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('finance_electricity_add_equip_title')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: context.tr('finance_electricity_equip_name'),
                  hintText: context.tr('finance_electricity_equip_hint'),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: wattageCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.tr('finance_electricity_power'),
                  suffixText: 'W',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: hoursCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.tr('finance_electricity_equip_hours'),
                  suffixText: context.tr('hours_day'),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: costCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: context.tr('finance_electricity_equip_price'),
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
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              final watts = double.tryParse(wattageCtrl.text) ?? 100.0;
              final hours = double.tryParse(hoursCtrl.text) ?? 24.0;
              final cost = double.tryParse(costCtrl.text) ?? 0.0;

              ref
                  .read(equipmentProvider.notifier)
                  .addEquipment(
                    EquipmentItem(
                      id: const Uuid().v4(),
                      name: name,
                      category: 'equipment',
                      purchaseDate: DateTime.now(),
                      purchaseCost: cost,
                      wattage: watts,
                      dailyOperatingHours: hours,
                      createdAt: DateTime.now(),
                    ),
                  );

              Navigator.pop(ctx);
            },
            child: Text(context.tr('save')),
          ),
        ],
      ),
    );
  }
}
