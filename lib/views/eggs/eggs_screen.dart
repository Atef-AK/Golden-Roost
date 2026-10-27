import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/localization/app_translations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/responsive.dart';
import '../../core/utils/calculations.dart';
import '../../core/utils/formatters.dart';
import '../../models/egg_record.dart';
import '../../providers/egg_provider.dart';
import '../../providers/flock_provider.dart';
import '../../providers/settings_provider.dart';
import '../widgets/empty_state_view.dart';
import 'egg_log_form_dialog.dart';

class EggsScreen extends ConsumerStatefulWidget {
  const EggsScreen({super.key});

  @override
  ConsumerState<EggsScreen> createState() => _EggsScreenState();
}

class _EggsScreenState extends ConsumerState<EggsScreen>
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
    final logs = ref.watch(eggLogsProvider);
    final sales = ref.watch(eggSalesProvider);
    final settings = ref.watch(settingsProvider);
    final currency = settings.currency;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final totalCollected = logs.fold(0, (sum, l) => sum + l.totalEggs);
    final totalUsable = logs.fold(0, (sum, l) => sum + l.usableEggs);
    final totalCracked = logs.fold(0, (sum, l) => sum + l.crackedEggs);
    final totalIncubation = logs.fold(0, (sum, l) => sum + l.keptForIncubation);
    final totalSold = sales.fold(0, (sum, s) => sum + s.quantity);
    final totalRevenue = sales.fold(0.0, (sum, s) => sum + s.totalAmount);
    final availableSaleable = FarmCalculations.calculateAvailableSaleableEggs(
      totalUsableEggs: totalUsable,
      reservedForIncubation: totalIncubation,
      totalSold: totalSold,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('eggs_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.point_of_sale),
            tooltip: context.tr('eggs_sell'),
            onPressed: () => _showSellEggsDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: context.tr('eggs_collect'),
            onPressed: () => EggLogFormDialog.show(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '${context.tr('eggs_total')} (${logs.length})'),
            Tab(text: '${context.tr('eggs_sales_tab')} (${sales.length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_eggs',
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.egg_outlined),
        label: Text(context.tr('eggs_collect')),
        onPressed: () => EggLogFormDialog.show(context),
      ),
      body: ResponsiveContainer(
        maxWidth: 1000,
        child: Column(
          children: [
            // KPI Summary Ribbon
            Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  final isWide = constraints.maxWidth >= 600;
                  final crossAxisCount = isWide ? 4 : 2;

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: isWide ? 2.2 : 1.7,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _EggKpiCard(
                        label: context.tr('eggs_total_collected_kpi'),
                        value: totalCollected.toString(),
                        icon: Icons.egg_outlined,
                        color: AppColors.primaryTeal,
                      ),
                      _EggKpiCard(
                        label: context.tr('eggs_available_stock_kpi'),
                        value: availableSaleable.toString(),
                        icon: Icons.inventory_2_outlined,
                        color: AppColors.semanticSuccess,
                      ),
                      _EggKpiCard(
                        label: context.tr('eggs_cracked_kpi'),
                        value: totalCracked.toString(),
                        icon: Icons.broken_image_outlined,
                        color: isDark
                            ? const Color(0xFFF87171)
                            : AppColors.semanticError,
                      ),
                      _EggKpiCard(
                        label: context.tr('eggs_revenue_kpi'),
                        value: AppFormatters.formatCurrency(
                          totalRevenue,
                          currency,
                        ),
                        icon: Icons.payments_outlined,
                        color: AppColors.semanticSuccess,
                      ),
                    ],
                  );
                },
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLogsList(logs),
                  _buildSalesList(sales, currency),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogsList(List<EggLog> logs) {
    if (logs.isEmpty) {
      return EmptyStateView(
        icon: Icons.egg_outlined,
        title: context.tr('eggs_empty_logs_title'),
        description: context.tr('eggs_empty_logs_desc'),
      );
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      itemCount: logs.length,
      itemBuilder: (ctx, index) {
        final log = logs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: PremiumCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.egg_outlined,
                    color: AppColors.primaryTeal,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${log.totalEggs} ${context.tr('eggs_title')} (${log.usableEggs} ${context.tr('eggs_usable')})',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Text(
                            AppFormatters.formatShortDate(log.date),
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            '${context.tr('time')}: ${log.collectionTime}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                            ),
                          ),
                          if (log.crackedEggs > 0)
                            StatusBadge(
                              label: '${log.crackedEggs} ${context.tr('eggs_cracked_badge')}',
                              variant: BadgeVariant.error,
                            ),
                          if (log.dirtyEggs > 0)
                            StatusBadge(
                              label: '${log.dirtyEggs} ${context.tr('eggs_dirty_badge')}',
                              variant: BadgeVariant.warning,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                  onPressed: () =>
                      EggLogFormDialog.show(context, initialLog: log),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                  onPressed: () => _confirmDeleteLog(context, log.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSalesList(List<EggSale> sales, String currency) {
    if (sales.isEmpty) {
      return Center(
        child: EmptyStateView(
          icon: Icons.point_of_sale_outlined,
          title: context.tr('eggs_empty_sales_title'),
          description: context.tr('eggs_empty_sales_desc'),
          actionLabel: context.tr('eggs_sell'),
          onAction: () => _showSellEggsDialog(context),
        ),
      );
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      itemCount: sales.length,
      itemBuilder: (ctx, index) {
        final s = sales[index];
        final isPaid = s.paymentStatus == 'paid';

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: PremiumCard(
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
                    Icons.attach_money,
                    color: AppColors.semanticSuccess,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${s.quantity} eggs to ${s.buyerName.isNotEmpty ? s.buyerName : "Customer"}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '+${AppFormatters.formatCurrency(s.totalAmount, currency)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? const Color(0xFF4ADE80)
                                  : AppColors.semanticSuccess,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${AppFormatters.formatShortDate(s.date)} • @ ${s.unitPrice.toStringAsFixed(3)} $currency',
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
                          StatusBadge(
                            label: s.paymentStatus.toUpperCase(),
                            variant: isPaid
                                ? BadgeVariant.success
                                : BadgeVariant.warning,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                  onPressed: () => _confirmDeleteSale(context, s.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteLog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('eggs_delete_log_title')),
        content: Text(
          context.tr('eggs_delete_log_confirm'),
        ),
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
              ref.read(eggLogsProvider.notifier).deleteLog(id);
              Navigator.pop(ctx);
            },
            child: Text(context.tr('delete')),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSale(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('eggs_delete_sale_title')),
        content: Text(
          context.tr('eggs_delete_sale_confirm'),
        ),
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
              ref.read(eggSalesProvider.notifier).deleteSale(id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.tr('eggs_sale_removed'))),
              );
            },
            child: Text(context.tr('delete')),
          ),
        ],
      ),
    );
  }

  void _showSellEggsDialog(BuildContext context) {
    final currency = ref.read(settingsProvider).currency;
    final logs = ref.read(eggLogsProvider);
    final sales = ref.read(eggSalesProvider);
    final totalUsable = logs.fold(0, (sum, l) => sum + l.usableEggs);
    final totalSold = sales.fold(0, (sum, s) => sum + s.quantity);
    final totalIncubation = logs.fold(0, (sum, l) => sum + l.keptForIncubation);
    final availableSaleable = FarmCalculations.calculateAvailableSaleableEggs(
      totalUsableEggs: totalUsable,
      reservedForIncubation: totalIncubation,
      totalSold: totalSold,
    );

    final qtyCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: '0.350');
    final buyerCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String paymentStatus = 'paid';
    String? selectedFlockId;

    final flocks = ref
        .read(flocksProvider)
        .where((f) => !f.isArchived)
        .toList();
    if (flocks.isNotEmpty) selectedFlockId = flocks.first.id;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: Text(context.tr('eggs_sell')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (flocks.isNotEmpty)
                  DropdownButtonFormField<String?>(
                    isExpanded: true,
                    initialValue: selectedFlockId,
                    decoration: InputDecoration(
                      labelText: context.tr('flocks_name'),
                    ),
                    items: flocks
                        .map(
                          (f) => DropdownMenuItem(
                            value: f.id,
                            child: Text(f.name),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setDState(() => selectedFlockId = val),
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: qtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: context.tr('eggs_sell_qty'),
                    helperText: '${context.tr('eggs_available_stock_kpi')}: $availableSaleable',
                    prefixIcon: const Icon(Icons.egg),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: '${context.tr('eggs_unit_price_label')} ($currency)',
                    suffixText: currency,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: buyerCtrl,
                  decoration: InputDecoration(
                    labelText: context.tr('eggs_buyer'),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: paymentStatus,
                  decoration: InputDecoration(
                    labelText: context.tr('finance_payment_status'),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'paid',
                      child: Text(context.tr('finance_paid')),
                    ),
                    DropdownMenuItem(
                      value: 'unpaid',
                      child: Text(context.tr('finance_unpaid')),
                    ),
                  ],
                  onChanged: (val) => setDState(() => paymentStatus = val!),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesCtrl,
                  decoration: InputDecoration(labelText: context.tr('notes')),
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
                final qty = int.tryParse(qtyCtrl.text) ?? 0;
                final price = double.tryParse(priceCtrl.text) ?? 0.0;
                if (qty <= 0) return;

                if (qty > availableSaleable) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${context.tr('eggs_oversell_warning')} ($availableSaleable ${context.tr('eggs_total')})',
                      ),
                      backgroundColor: AppColors.semanticError,
                    ),
                  );
                  return;
                }

                final total = qty * price;
                final sale = EggSale(
                  id: const Uuid().v4(),
                  flockId: selectedFlockId,
                  date: DateTime.now(),
                  quantity: qty,
                  unitPrice: price,
                  totalAmount: total,
                  buyerName: buyerCtrl.text.trim(),
                  paymentStatus: paymentStatus,
                  amountPaid: paymentStatus == 'paid' ? total : 0.0,
                  notes: notesCtrl.text.trim(),
                  createdAt: DateTime.now(),
                );

                ref.read(eggSalesProvider.notifier).recordSale(sale);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.tr('success_saved'))),
                );
              },
              child: Text(context.tr('save')),
            ),
          ],
        ),
      ),
    );
  }
}

class _EggKpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _EggKpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PremiumCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
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
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
