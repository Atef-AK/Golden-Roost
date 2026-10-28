import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../core/localization/app_translations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/responsive.dart';
import '../../core/utils/formatters.dart';
import '../../models/feed.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/feed_provider.dart';
import '../../providers/flock_provider.dart';
import '../../providers/settings_provider.dart';
import '../widgets/empty_state_view.dart';
import 'feed_log_dialog.dart';

class FeedInventoryScreen extends ConsumerStatefulWidget {
  const FeedInventoryScreen({super.key});

  @override
  ConsumerState<FeedInventoryScreen> createState() =>
      _FeedInventoryScreenState();
}

class _FeedInventoryScreenState extends ConsumerState<FeedInventoryScreen>
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
    final feeds = ref.watch(feedInventoryProvider);
    final dashStats = ref.watch(dashboardProvider);
    final settings = ref.watch(settingsProvider);
    final currency = settings.currency;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final totalStock = feeds.fold(0.0, (sum, f) => sum + f.currentStockKg);
    final hasLowStock = feeds.any((f) => f.isLowStock);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('feed_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: context.tr('feed_add_type'),
            onPressed: () => _addFeedTypeDialog(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '${context.tr('feed_types_tab')} (${feeds.length})'),
            Tab(text: context.tr('feed_restock_history')),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_feed',
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.shopping_bag_outlined),
        label: Text(context.tr('feed_restock_btn')),
        onPressed: () => _restockDialog(context),
      ),
      body: ResponsiveContainer(
        maxWidth: 1000,
        child: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Feed Types & Storage
            ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                // Total Feed Overview Hero
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: PremiumCard(
                    borderColor: hasLowStock
                        ? AppColors.semanticWarning.withAlpha(50)
                        : AppColors.primaryTeal.withAlpha(40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      (hasLowStock
                                              ? AppColors.semanticWarning
                                              : AppColors.primaryTeal)
                                          .withAlpha(20),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  hasLowStock
                                      ? Icons.warning_amber
                                      : Icons.inventory,
                                  color: hasLowStock
                                      ? AppColors.semanticWarning
                                      : AppColors.primaryTeal,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.tr('feed_stock_levels'),
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
                                        AppFormatters.formatWeight(totalStock),
                                        style: TextStyle(
                                          fontSize: 22,
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
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryTeal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 10,
                            ),
                          ),
                          icon: const Icon(Icons.restaurant, size: 16),
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              context.tr('feed_log_btn'),
                              maxLines: 1,
                            ),
                          ),
                          onPressed: () => FeedLogDialog.show(context),
                        ),
                      ],
                    ),
                  ),
                ),

                // Feed Depletion & Refilement Forecaster
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E283D)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            (dashStats.feedDaysRemaining <= 3 &&
                                dashStats.totalFeedStockKg > 0)
                            ? AppColors.error.withAlpha(70)
                            : (isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                Icons.hourglass_top_rounded,
                                size: 16,
                                color: AppColors.primaryTeal,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                context.tr('feed_refill_forecaster'),
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            if (dashStats.feedDaysRemaining > 0 &&
                                dashStats.totalFeedStockKg > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: dashStats.feedDaysRemaining <= 3
                                      ? AppColors.error.withAlpha(25)
                                      : AppColors.primaryTeal.withAlpha(25),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '~${dashStats.feedDaysRemaining} ${context.tr('flocks_days')}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: dashStats.feedDaysRemaining <= 3
                                        ? AppColors.error
                                        : AppColors.primaryTeal,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.tr('feed_daily_burn'),
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    dashStats.dailyFeedDemandKg > 0
                                        ? '${dashStats.dailyFeedDemandKg.toStringAsFixed(2)} kg/day'
                                        : '--',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.tr('feed_refill_date'),
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    dashStats.estimatedRefillDate != null
                                        ? DateFormat('dd/MM/yyyy').format(
                                            dashStats.estimatedRefillDate!,
                                          )
                                        : '--',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.tr('dash_total_flocks_fed'),
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${dashStats.totalLiveBirds} ${context.tr('birds')}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SectionHeader(
                    title: context.tr('feed_in_storage'),
                    actionLabel: context.tr('feed_add_type'),
                    onAction: () => _addFeedTypeDialog(context),
                  ),
                ),
                const SizedBox(height: 8),

                if (feeds.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: EmptyStateView(
                      icon: Icons.inventory_2_outlined,
                      title: context.tr('feed_no_types'),
                      description: context.tr('feed_no_types_desc'),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: LayoutBuilder(
                      builder: (ctx, constraints) {
                        final isWide = constraints.maxWidth >= 600;
                        if (isWide) {
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  mainAxisExtent: 185,
                                ),
                            itemCount: feeds.length,
                            itemBuilder: (ctx, i) =>
                                _buildFeedCard(feeds[i], currency, isDark),
                          );
                        }
                        return Column(
                          children: feeds
                              .map(
                                (f) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _buildFeedCard(f, currency, isDark),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ),
              ],
            ),

            // Tab 2: Restocks & Transaction History
            _buildTransactionsTab(currency, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsTab(String currency, bool isDark) {
    final txsAsync = ref.watch(feedTransactionsProvider(null));
    final feeds = ref.watch(feedInventoryProvider);
    final flocks = ref.watch(flocksProvider);

    return txsAsync.when(
      data: (txs) {
        if (txs.isEmpty) {
          return Center(
            child: EmptyStateView(
              icon: Icons.history,
              title: context.tr('feed_no_types'),
              description: context.tr('feed_empty_hint'),
              actionLabel: context.tr('feed_restock_btn'),
              onAction: () => _restockDialog(context),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          itemCount: txs.length,
          itemBuilder: (ctx, index) {
            final tx = txs[index];
            final feed = feeds.cast<FeedItem?>().firstWhere(
              (f) => f?.id == tx.feedId,
              orElse: () => null,
            );
            final feedName = feed?.name ?? 'Feed Item';
            final flock = flocks.cast<dynamic>().firstWhere(
              (f) => f.id == tx.flockId,
              orElse: () => null,
            );
            final flockName = flock != null ? 'Flock: ${flock.name}' : null;
            final isPurchase = tx.type == 'purchase';

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PremiumCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            (isPurchase
                                    ? AppColors.semanticSuccess
                                    : AppColors.primaryTeal)
                                .withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isPurchase
                            ? Icons.shopping_bag_outlined
                            : Icons.restaurant,
                        color: isPurchase
                            ? AppColors.semanticSuccess
                            : AppColors.primaryTeal,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  isPurchase
                                      ? '${context.tr('feed_restock_prefix')}: $feedName'
                                      : '${context.tr('feed_log_consumption')}: $feedName',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              StatusBadge(
                                label: isPurchase
                                    ? context
                                          .tr('feed_restock_btn')
                                          .toUpperCase()
                                    : context.tr('feed_log_btn').toUpperCase(),
                                variant: isPurchase
                                    ? BadgeVariant.success
                                    : BadgeVariant.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${tx.quantityKg.toStringAsFixed(1)} kg${isPurchase && tx.cost > 0 ? " • ${AppFormatters.formatCurrency(tx.cost, currency)}" : ""}${flockName != null ? " • $flockName" : ""}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${AppFormatters.formatShortDate(tx.date)}${tx.notes.isNotEmpty ? " • ${tx.notes}" : ""}',
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
                    const SizedBox(width: 4),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 20),
                      onSelected: (val) {
                        if (val == 'edit') {
                          _editTransactionDialog(context, tx, feed);
                        } else if (val == 'delete') {
                          _confirmDeleteTransaction(context, tx);
                        }
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(Icons.edit_outlined, size: 18),
                              const SizedBox(width: 8),
                              Text(context.tr('edit')),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: AppColors.semanticError,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                context.tr('delete'),
                                style: const TextStyle(
                                  color: AppColors.semanticError,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading transactions: $e')),
    );
  }

  Widget _buildFeedCard(FeedItem feed, String currency, bool isDark) {
    final isLow = feed.isLowStock;
    final stockRatio = feed.lowStockThresholdKg > 0
        ? (feed.currentStockKg / (feed.lowStockThresholdKg * 3)).clamp(0.0, 1.0)
        : 1.0;

    return PremiumCard(
      borderColor: isLow ? AppColors.semanticWarning.withAlpha(50) : null,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feed.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${context.tr('finance_category')}: ${feed.feedType.toUpperCase()} • ${feed.bagWeightKg} ${context.tr('feed_bag_weight_unit')}',
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
              const SizedBox(width: 6),
              StatusBadge(
                label: isLow
                    ? context.tr('feed_low_stock')
                    : context.tr('feed_in_stock'),
                variant: isLow ? BadgeVariant.warning : BadgeVariant.success,
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (val) {
                  if (val == 'edit') {
                    _editFeedTypeDialog(context, feed);
                  } else if (val == 'delete') {
                    _confirmDeleteFeedItem(context, feed);
                  } else if (val == 'restock') {
                    _restockSingleFeed(context, feed);
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'restock',
                    child: Row(
                      children: [
                        const Icon(Icons.add_shopping_cart, size: 18),
                        const SizedBox(width: 8),
                        Text(context.tr('feed_restock_btn')),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(context.tr('edit')),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: AppColors.semanticError,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.tr('delete'),
                          style: const TextStyle(
                            color: AppColors.semanticError,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Stock Progress Line
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${feed.currentStockKg.toStringAsFixed(1)} kg ${context.tr('feed_remaining')}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isLow
                            ? AppColors.semanticWarning
                            : AppColors.primaryTeal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${context.tr('feed_alert_threshold')}: <${feed.lowStockThresholdKg.toStringAsFixed(0)} kg',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: stockRatio,
                  minHeight: 6,
                  backgroundColor: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isLow ? AppColors.semanticWarning : AppColors.primaryTeal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${AppFormatters.formatCurrency(feed.costPerBag, currency)} / ${context.tr('feed_bag')}',
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
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                ),
                icon: const Icon(Icons.add_shopping_cart, size: 14),
                label: Text(context.tr('feed_restock_btn')),
                onPressed: () => _restockSingleFeed(context, feed),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addFeedTypeDialog(BuildContext context) {
    final currency = ref.read(settingsProvider).currency;
    final nameCtrl = TextEditingController();
    final bagWeightCtrl = TextEditingController(text: '50');
    final bagPriceCtrl = TextEditingController(text: '65');
    final initialStockCtrl = TextEditingController(text: '100');
    final lowStockThresholdCtrl = TextEditingController(text: '25');
    String feedType = 'layer';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: Text(context.tr('feed_add_type')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: context.tr('feed_name'),
                    hintText: context.tr('feed_mash_hint'),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: feedType,
                  decoration: InputDecoration(
                    labelText: context.tr('feed_type'),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'starter',
                      child: Text(context.tr('feed_type_starter')),
                    ),
                    DropdownMenuItem(
                      value: 'grower',
                      child: Text(context.tr('feed_type_grower')),
                    ),
                    DropdownMenuItem(
                      value: 'layer',
                      child: Text(context.tr('feed_type_layer')),
                    ),
                    DropdownMenuItem(
                      value: 'breeder',
                      child: Text(context.tr('feed_type_breeder')),
                    ),
                    DropdownMenuItem(
                      value: 'quail',
                      child: Text(context.tr('feed_type_quail')),
                    ),
                    DropdownMenuItem(
                      value: 'other',
                      child: Text(context.tr('feed_type_other')),
                    ),
                  ],
                  onChanged: (val) => setDState(() => feedType = val!),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: bagWeightCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: context.tr('feed_bag_weight'),
                          suffixText: 'kg',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: bagPriceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: context.tr('feed_price_bag'),
                          suffixText: currency,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: initialStockCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: context.tr('feed_initial_stock'),
                          suffixText: 'kg',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: lowStockThresholdCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: context.tr('feed_low_alert_at'),
                          suffixText: 'kg',
                        ),
                      ),
                    ),
                  ],
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
                final bagWeight = double.tryParse(bagWeightCtrl.text) ?? 50.0;
                final bagPrice = double.tryParse(bagPriceCtrl.text) ?? 0.0;
                final initStock = double.tryParse(initialStockCtrl.text) ?? 0.0;
                final lowThresh =
                    double.tryParse(lowStockThresholdCtrl.text) ?? 25.0;

                final item = FeedItem(
                  id: const Uuid().v4(),
                  name: name,
                  feedType: feedType,
                  currentStockKg: initStock,
                  lowStockThresholdKg: lowThresh,
                  bagWeightKg: bagWeight,
                  costPerBag: bagPrice,
                  updatedAt: DateTime.now(),
                );

                ref.read(feedInventoryProvider.notifier).addFeedItem(item);
                Navigator.pop(ctx);
              },
              child: Text(context.tr('save')),
            ),
          ],
        ),
      ),
    );
  }

  void _editFeedTypeDialog(BuildContext context, FeedItem feed) {
    final nameCtrl = TextEditingController(text: feed.name);
    final bagWeightCtrl = TextEditingController(
      text: feed.bagWeightKg.toString(),
    );
    final bagPriceCtrl = TextEditingController(
      text: feed.costPerBag.toString(),
    );
    final stockCtrl = TextEditingController(
      text: feed.currentStockKg.toString(),
    );
    final lowStockThresholdCtrl = TextEditingController(
      text: feed.lowStockThresholdKg.toString(),
    );
    final currency = ref.read(settingsProvider).currency;
    String feedType = feed.feedType;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: Text('${context.tr('edit')}: ${feed.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: context.tr('feed_name'),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: feedType,
                  decoration: InputDecoration(
                    labelText: context.tr('feed_type'),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'starter',
                      child: Text(context.tr('feed_type_starter')),
                    ),
                    DropdownMenuItem(
                      value: 'grower',
                      child: Text(context.tr('feed_type_grower')),
                    ),
                    DropdownMenuItem(
                      value: 'layer',
                      child: Text(context.tr('feed_type_layer')),
                    ),
                    DropdownMenuItem(
                      value: 'breeder',
                      child: Text(context.tr('feed_type_breeder')),
                    ),
                    DropdownMenuItem(
                      value: 'quail',
                      child: Text(context.tr('feed_type_quail')),
                    ),
                    DropdownMenuItem(
                      value: 'other',
                      child: Text(context.tr('feed_type_other')),
                    ),
                  ],
                  onChanged: (val) => setDState(() => feedType = val!),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: bagWeightCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: context.tr('feed_bag_weight'),
                          suffixText: 'kg',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: bagPriceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: context.tr('feed_price_bag'),
                          suffixText: currency,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: stockCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: context.tr('feed_current_stock'),
                          suffixText: 'kg',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: lowStockThresholdCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: context.tr('feed_low_alert_at'),
                          suffixText: 'kg',
                        ),
                      ),
                    ),
                  ],
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
                final bagWeight =
                    double.tryParse(bagWeightCtrl.text) ?? feed.bagWeightKg;
                final bagPrice =
                    double.tryParse(bagPriceCtrl.text) ?? feed.costPerBag;
                final currentStock =
                    double.tryParse(stockCtrl.text) ?? feed.currentStockKg;
                final lowThresh =
                    double.tryParse(lowStockThresholdCtrl.text) ??
                    feed.lowStockThresholdKg;

                final updated = feed.copyWith(
                  name: name,
                  feedType: feedType,
                  currentStockKg: currentStock,
                  lowStockThresholdKg: lowThresh,
                  bagWeightKg: bagWeight,
                  costPerBag: bagPrice,
                  updatedAt: DateTime.now(),
                );

                ref
                    .read(feedInventoryProvider.notifier)
                    .updateFeedItem(updated);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.tr('feed_type_updated'))),
                );
              },
              child: Text(context.tr('save')),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteFeedItem(BuildContext context, FeedItem feed) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${context.tr('delete')} ${context.tr('feed_type')}'),
        content: Text(context.tr('feed_delete_type_confirm')),
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
              ref.read(feedInventoryProvider.notifier).deleteFeedItem(feed.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${context.tr('delete')}: ${feed.name}'),
                ),
              );
            },
            child: Text(context.tr('delete')),
          ),
        ],
      ),
    );
  }

  void _editTransactionDialog(
    BuildContext context,
    FeedTransaction tx,
    FeedItem? feed,
  ) {
    final currency = ref.read(settingsProvider).currency;
    final qtyCtrl = TextEditingController(text: tx.quantityKg.toString());
    final costCtrl = TextEditingController(text: tx.cost.toString());
    final notesCtrl = TextEditingController(text: tx.notes);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          tx.type == 'purchase'
              ? context.tr('feed_edit_restock')
              : context.tr('feed_edit_consumption'),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: qtyCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: context.tr('feed_quantity_kg'),
                  suffixText: 'kg',
                ),
              ),
              if (tx.type == 'purchase') ...[
                const SizedBox(height: 12),
                TextField(
                  controller: costCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: context.tr('finance_total_cost'),
                    suffixText: currency,
                  ),
                ),
              ],
              const SizedBox(height: 12),
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
              final newQty = double.tryParse(qtyCtrl.text) ?? tx.quantityKg;
              final newCost = double.tryParse(costCtrl.text) ?? tx.cost;
              final newNotes = notesCtrl.text.trim();

              final updated = FeedTransaction(
                id: tx.id,
                feedId: tx.feedId,
                flockId: tx.flockId,
                date: tx.date,
                type: tx.type,
                quantityKg: newQty,
                cost: newCost,
                notes: newNotes,
                createdAt: tx.createdAt,
              );

              ref
                  .read(feedInventoryProvider.notifier)
                  .updateTransaction(updated, tx.quantityKg, tx.cost);
              ref.invalidate(feedTransactionsProvider);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.tr('feed_tx_updated'))),
              );
            },
            child: Text(context.tr('save')),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteTransaction(BuildContext context, FeedTransaction tx) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          '${context.tr('delete')} ${context.tr('finance_transaction')}',
        ),
        content: Text(context.tr('feed_delete_tx_confirm')),
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
              ref.read(feedInventoryProvider.notifier).deleteTransaction(tx.id);
              ref.invalidate(feedTransactionsProvider);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.tr('feed_tx_deleted'))),
              );
            },
            child: Text(context.tr('delete')),
          ),
        ],
      ),
    );
  }

  void _restockSingleFeed(BuildContext context, FeedItem feed) {
    final currency = ref.read(settingsProvider).currency;
    final bagsCtrl = TextEditingController(text: '1');
    final costCtrl = TextEditingController(text: feed.costPerBag.toString());
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: Text('${context.tr('feed_restock_prefix')}: ${feed.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: bagsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText:
                        '${context.tr('feed_num_bags')} (${feed.bagWeightKg} kg)',
                    suffixIcon: const Icon(Icons.shopping_bag),
                  ),
                  onChanged: (val) {
                    final bags = int.tryParse(val) ?? 0;
                    setDState(() {
                      costCtrl.text = (bags * feed.costPerBag).toStringAsFixed(
                        2,
                      );
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
                    labelText:
                        '${context.tr('finance_total_cost')} ($currency)',
                    suffixText: currency,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  decoration: InputDecoration(
                    labelText: context.tr('feed_supplier_notes'),
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
                final bags = int.tryParse(bagsCtrl.text) ?? 0;
                if (bags <= 0) return;
                final totalKg = bags * feed.bagWeightKg;
                final totalCost =
                    double.tryParse(costCtrl.text) ?? (bags * feed.costPerBag);

                final tx = FeedTransaction(
                  id: const Uuid().v4(),
                  feedId: feed.id,
                  date: DateTime.now(),
                  type: 'purchase',
                  quantityKg: totalKg,
                  cost: totalCost,
                  notes: notesCtrl.text.trim().isNotEmpty
                      ? notesCtrl.text.trim()
                      : 'Purchased $bags bags (${feed.bagWeightKg}kg)',
                  createdAt: DateTime.now(),
                );

                ref.read(feedInventoryProvider.notifier).recordTransaction(tx);
                ref.invalidate(feedTransactionsProvider);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.tr('feed_restock_confirm'))),
                );
              },
              child: Text(context.tr('feed_restock_confirm')),
            ),
          ],
        ),
      ),
    );
  }

  void _restockDialog(BuildContext context) {
    final feeds = ref.read(feedInventoryProvider);
    if (feeds.isEmpty) {
      _addFeedTypeDialog(context);
    } else {
      _restockSingleFeed(context, feeds.first);
    }
  }
}
