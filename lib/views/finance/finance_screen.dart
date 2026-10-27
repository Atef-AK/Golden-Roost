import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/app_translations.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/responsive.dart';
import '../../core/utils/formatters.dart';
import '../../providers/finance_provider.dart';
import '../../providers/settings_provider.dart';
import '../widgets/empty_state_view.dart';
import 'finance_form_dialog.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> {
  String _filterType = 'all'; // 'all', 'income', 'expense', 'capital'
  final String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final finances = ref.watch(financesProvider);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.watch(financesProvider.notifier);
    final currency = settings.currency;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final income = notifier.totalOperatingIncome;
    final expenses = notifier.totalOperatingExpenses;
    final netProfit = notifier.netOperatingResult;
    final capitalInvestments = notifier.totalCapitalInvestments;
    final unpaid = notifier.totalUnpaidReceivables;

    final filteredList = finances.where((tx) {
      if (_filterType == 'income' && !tx.isIncome) {
        return false;
      }
      if (_filterType == 'expense' &&
          (!tx.isExpense || tx.isCapitalInvestment)) {
        return false;
      }
      if (_filterType == 'capital' && !tx.isCapitalInvestment) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        return tx.category.toLowerCase().contains(_searchQuery) ||
            tx.notes.toLowerCase().contains(_searchQuery);
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('finance_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.bolt),
            tooltip: context.tr('finance_electricity'),
            onPressed: () => context.push('/finance/electricity'),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: context.tr('finance_add_expense'),
            onPressed: () => FinanceFormDialog.show(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_finance',
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(context.tr('finance_add_transaction')),
        onPressed: () => FinanceFormDialog.show(context),
      ),
      body: ResponsiveContainer(
        maxWidth: 1100,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            // Net Operating Result Clean Hero Card
            Padding(
              padding: const EdgeInsets.all(16),
              child: PremiumCard(
                borderColor: netProfit >= 0
                    ? AppColors.primaryTeal.withAlpha(50)
                    : AppColors.semanticError.withAlpha(50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            context.tr('finance_net_profit').toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
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
                          label: netProfit >= 0
                              ? context.tr('finance_profitable')
                              : context.tr('finance_net_loss'),
                          variant: netProfit >= 0
                              ? BadgeVariant.success
                              : BadgeVariant.error,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppFormatters.formatCurrency(netProfit, currency),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: netProfit >= 0
                              ? (isDark
                                    ? const Color(0xFF4ADE80)
                                    : AppColors.semanticSuccess)
                              : (isDark
                                    ? const Color(0xFFF87171)
                                    : AppColors.semanticError),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Divider(
                      height: 1,
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                    const SizedBox(height: 16),

                    // Metrics row / grid
                    LayoutBuilder(
                      builder: (ctx, constraints) {
                        final isNarrow = constraints.maxWidth < 420;
                        if (isNarrow) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _PnlMetric(
                                      label: context.tr('finance_income'),
                                      amount:
                                          '+${AppFormatters.formatCurrency(income, currency)}',
                                      color: isDark
                                          ? const Color(0xFF4ADE80)
                                          : AppColors.semanticSuccess,
                                      icon: Icons.south_west,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _PnlMetric(
                                      label: context.tr('finance_expenses'),
                                      amount:
                                          '-${AppFormatters.formatCurrency(expenses, currency)}',
                                      color: isDark
                                          ? const Color(0xFFF87171)
                                          : AppColors.semanticError,
                                      icon: Icons.north_east,
                                    ),
                                  ),
                                ],
                              ),
                              if (capitalInvestments > 0 || unpaid > 0) ...[
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    if (capitalInvestments > 0)
                                      Expanded(
                                        child: _PnlMetric(
                                          label: context.tr('finance_capital_assets'),
                                          amount: AppFormatters.formatCurrency(
                                            capitalInvestments,
                                            currency,
                                          ),
                                          color: AppColors.primaryTeal,
                                          icon: Icons.account_balance,
                                        ),
                                      ),
                                    if (capitalInvestments > 0 && unpaid > 0)
                                      const SizedBox(width: 12),
                                    if (unpaid > 0)
                                      Expanded(
                                        child: _PnlMetric(
                                          label: context.tr('finance_unpaid_receivables'),
                                          amount: AppFormatters.formatCurrency(
                                            unpaid,
                                            currency,
                                          ),
                                          color: AppColors.semanticWarning,
                                          icon: Icons.pending_actions,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          );
                        }

                        // Wide layout: 2 or 4 side-by-side
                        return Row(
                          children: [
                            Expanded(
                              child: _PnlMetric(
                                label: context.tr('finance_income'),
                                amount:
                                    '+${AppFormatters.formatCurrency(income, currency)}',
                                color: isDark
                                    ? const Color(0xFF4ADE80)
                                    : AppColors.semanticSuccess,
                                icon: Icons.south_west,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _PnlMetric(
                                label: context.tr('finance_expenses'),
                                amount:
                                    '-${AppFormatters.formatCurrency(expenses, currency)}',
                                color: isDark
                                    ? const Color(0xFFF87171)
                                    : AppColors.semanticError,
                                icon: Icons.north_east,
                              ),
                            ),
                            if (capitalInvestments > 0) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: _PnlMetric(
                                  label: context.tr('finance_capital_assets'),
                                  amount: AppFormatters.formatCurrency(
                                    capitalInvestments,
                                    currency,
                                  ),
                                  color: AppColors.primaryTeal,
                                  icon: Icons.account_balance,
                                ),
                              ),
                            ],
                            if (unpaid > 0) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: _PnlMetric(
                                  label: context.tr('finance_unpaid_receivables'),
                                  amount: AppFormatters.formatCurrency(
                                    unpaid,
                                    currency,
                                  ),
                                  color: AppColors.semanticWarning,
                                  icon: Icons.pending_actions,
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Electricity & Wattage Shortcut Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PremiumCard(
                onTap: () => context.push('/finance/electricity'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
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
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('finance_electricity'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${context.tr('electricity_tariff_label')}: ${settings.electricityKwhRate.toStringAsFixed(3)} $currency/kWh • ${context.tr('electricity_meter_and_wattage')}',
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
                    Icon(
                      Icons.chevron_right,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFilterChip('all', context.tr('finance_all_entries')),
                  const SizedBox(width: 8),
                  _buildFilterChip('income', context.tr('finance_revenues')),
                  const SizedBox(width: 8),
                  _buildFilterChip('expense', context.tr('finance_operating_costs')),
                  const SizedBox(width: 8),
                  _buildFilterChip('capital', context.tr('finance_capital_filter')),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Transactions List
            if (filteredList.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: EmptyStateView(
                  icon: Icons.account_balance_wallet_outlined,
                  title: context.tr('finance_no_tx'),
                  description: context.tr('finance_no_tx_desc'),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: filteredList.map((tx) {
                    final isIncome = tx.isIncome;
                    final (catIcon, catColor) = AppIcons.getFinanceCategoryVisual(tx.category);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: PremiumCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: catColor.withAlpha(24),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: catColor.withAlpha(50),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    catIcon,
                                    color: catColor,
                                    size: 22,
                                  ),
                                ),
                                Positioned(
                                  bottom: -2,
                                  right: -2,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: isIncome
                                          ? AppColors.semanticSuccess
                                          : (tx.isCapitalInvestment
                                              ? AppColors.primaryTeal
                                              : AppColors.semanticError),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isIncome
                                          ? Icons.arrow_downward_rounded
                                          : Icons.arrow_upward_rounded,
                                      size: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
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
                                          context.trFinanceCategory(tx.category),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        '${isIncome ? "+" : "-"}${AppFormatters.formatCurrency(tx.amount, currency)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          color: isIncome
                                              ? (isDark
                                                    ? const Color(0xFF4ADE80)
                                                    : AppColors.semanticSuccess)
                                              : (isDark
                                                    ? const Color(0xFFF87171)
                                                    : AppColors.semanticError),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        AppFormatters.formatShortDate(tx.date),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark
                                              ? AppColors.textMutedDark
                                              : AppColors.textMutedLight,
                                        ),
                                      ),
                                      if (tx.notes.isNotEmpty) ...[
                                        Expanded(
                                          child: Text(
                                            ' • ${tx.notes}',
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
                                      ] else
                                        const Spacer(),
                                      const SizedBox(width: 4),
                                      if (tx.isCapitalInvestment)
                                        StatusBadge(
                                          label: context.tr('finance_capital_badge'),
                                          variant: BadgeVariant.primary,
                                        )
                                      else if (tx.paymentStatus != 'paid')
                                        StatusBadge(
                                          label: tx.paymentStatus.toUpperCase(),
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
                              onPressed: () => FinanceFormDialog.show(
                                context,
                                initialTransaction: tx,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18),
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                              onPressed: () => _confirmDelete(context, tx.id),
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

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _filterType == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected
              ? Colors.white
              : (isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight),
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primaryTeal,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      side: BorderSide(
        color: isSelected
            ? AppColors.primaryTeal
            : (isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (sel) {
        if (sel) setState(() => _filterType = value);
      },
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('finance_delete_tx_title')),
        content: Text(context.tr('finance_delete_tx_confirm')),
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
              ref.read(financesProvider.notifier).deleteTransaction(id);
              Navigator.pop(ctx);
            },
            child: Text(context.tr('delete')),
          ),
        ],
      ),
    );
  }
}

class _PnlMetric extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  final IconData icon;

  const _PnlMetric({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(isDark ? 20 : 15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: color),
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
              amount,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
