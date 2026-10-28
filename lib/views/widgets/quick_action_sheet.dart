import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/localization/app_translations.dart';
import '../../core/theme/app_theme.dart';

class QuickActionSheet extends StatelessWidget {
  final VoidCallback onLogFeed;
  final VoidCallback onLogWater;
  final VoidCallback onCollectEggs;
  final VoidCallback onRecordMortality;
  final VoidCallback? onRecordSale;
  final VoidCallback onAddExpense;
  final VoidCallback onAddIncome;
  final VoidCallback onAddVaccineOrTask;
  final VoidCallback onNewIncubation;

  const QuickActionSheet({
    super.key,
    required this.onLogFeed,
    required this.onLogWater,
    required this.onCollectEggs,
    required this.onRecordMortality,
    this.onRecordSale,
    required this.onAddExpense,
    required this.onAddIncome,
    required this.onAddVaccineOrTask,
    required this.onNewIncubation,
  });

  static void show(
    BuildContext context, {
    required VoidCallback onLogFeed,
    required VoidCallback onLogWater,
    required VoidCallback onCollectEggs,
    required VoidCallback onRecordMortality,
    VoidCallback? onRecordSale,
    required VoidCallback onAddExpense,
    required VoidCallback onAddIncome,
    required VoidCallback onAddVaccineOrTask,
    required VoidCallback onNewIncubation,
  }) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QuickActionSheet(
        onLogFeed: onLogFeed,
        onLogWater: onLogWater,
        onCollectEggs: onCollectEggs,
        onRecordMortality: onRecordMortality,
        onRecordSale: onRecordSale,
        onAddExpense: onAddExpense,
        onAddIncome: onAddIncome,
        onAddVaccineOrTask: onAddVaccineOrTask,
        onNewIncubation: onNewIncubation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final actions = [
      _QuickActionItem(
        title: context.tr('feed_log_consumption'),
        subtitle: context.tr('dash_quick_feed'),
        icon: Icons.grain_rounded,
        color: AppColors.forestEmerald,
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
          onLogFeed();
        },
      ),
      _QuickActionItem(
        title: context.tr('eggs_collect'),
        subtitle: context.tr('dash_quick_eggs'),
        icon: Icons.egg_outlined,
        color: AppColors.goldenHarvest,
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
          onCollectEggs();
        },
      ),
      _QuickActionItem(
        title: context.tr('dash_quick_water'),
        subtitle: context.tr('tasks_cat_watering'),
        icon: Icons.water_drop_outlined,
        color: AppColors.info,
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
          onLogWater();
        },
      ),
      _QuickActionItem(
        title: context.tr('flocks_record_mortality'),
        subtitle: context.tr('dash_quick_mortality'),
        icon: Icons.heart_broken_outlined,
        color: AppColors.error,
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
          onRecordMortality();
        },
      ),
      if (onRecordSale != null)
        _QuickActionItem(
          title: context.tr('dash_quick_sale'),
          subtitle: context.tr('flocks_movement_sale'),
          icon: Icons.sell_outlined,
          color: AppColors.freshLeaf,
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
            onRecordSale!();
          },
        ),
      _QuickActionItem(
        title: context.tr('finance_add_expense'),
        subtitle: context.tr('finance_operating_costs'),
        icon: Icons.receipt_long_outlined,
        color: const Color(0xFFC0403B),
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
          onAddExpense();
        },
      ),
      _QuickActionItem(
        title: context.tr('finance_add_income'),
        subtitle: context.tr('finance_revenues'),
        icon: Icons.trending_up_rounded,
        color: AppColors.success,
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
          onAddIncome();
        },
      ),
      _QuickActionItem(
        title: context.tr('tasks_new_title'),
        subtitle: context.tr('dash_todays_tasks'),
        icon: Icons.event_note_outlined,
        color: const Color(0xFF5B67CA),
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
          onAddVaccineOrTask();
        },
      ),
      _QuickActionItem(
        title: context.tr('incubator_new_batch'),
        subtitle: context.tr('incubator_title'),
        icon: Icons.wb_incandescent_outlined,
        color: AppColors.goldenHarvest,
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
          onNewIncubation();
        },
      ),
    ];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 90 : 25),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 42,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2C3930)
                        : const Color(0xFFD6DDD4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.forestEmerald.withAlpha(
                            isDark ? 50 : 22,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.bolt_rounded,
                          color: AppColors.forestEmerald,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('dash_quick_action'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          Text(
                            context.tr('dash_quick_actions_subtitle'),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFF1E2721)
                          : const Color(0xFFF0F4EF),
                    ),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 550;
                      final crossAxisCount = isWide ? 3 : 2;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: isWide ? 1.6 : 1.32,
                        ),
                        itemCount: actions.length,
                        itemBuilder: (context, i) {
                          final a = actions[i];
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: a.onTap,
                              borderRadius: BorderRadius.circular(16),
                              child: Ink(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF16201B)
                                      : const Color(0xFFFAFAF7),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF26332A)
                                        : const Color(0xFFE5EAE3),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: a.color.withAlpha(
                                          isDark ? 45 : 24,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        a.icon,
                                        color: a.color,
                                        size: 20,
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          a.title,
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
                                        const SizedBox(height: 2),
                                        Text(
                                          a.subtitle,
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
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
