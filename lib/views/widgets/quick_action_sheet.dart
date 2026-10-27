import 'package:flutter/material.dart';
import '../../core/localization/app_translations.dart';
import '../../core/theme/app_theme.dart';

class QuickActionSheet extends StatelessWidget {
  final VoidCallback onLogFeed;
  final VoidCallback onLogWater;
  final VoidCallback onCollectEggs;
  final VoidCallback onRecordMortality;
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
    required VoidCallback onAddExpense,
    required VoidCallback onAddIncome,
    required VoidCallback onAddVaccineOrTask,
    required VoidCallback onNewIncubation,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QuickActionSheet(
        onLogFeed: onLogFeed,
        onLogWater: onLogWater,
        onCollectEggs: onCollectEggs,
        onRecordMortality: onRecordMortality,
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
        color: AppColors.primaryTeal,
        onTap: () {
          Navigator.pop(context);
          onLogFeed();
        },
      ),
      _QuickActionItem(
        title: context.tr('eggs_collect'),
        subtitle: context.tr('dash_quick_eggs'),
        icon: Icons.egg_outlined,
        color: AppColors.warning,
        onTap: () {
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
          Navigator.pop(context);
          onRecordMortality();
        },
      ),
      _QuickActionItem(
        title: context.tr('finance_add_expense'),
        subtitle: context.tr('finance_operating_costs'),
        icon: Icons.receipt_long_outlined,
        color: const Color(0xFFC0403B),
        onTap: () {
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
          Navigator.pop(context);
          onAddIncome();
        },
      ),
      _QuickActionItem(
        title: context.tr('tasks_new_title'),
        subtitle: context.tr('dash_todays_tasks'),
        icon: Icons.calendar_today_outlined,
        color: const Color(0xFF6366F1),
        onTap: () {
          Navigator.pop(context);
          onAddVaccineOrTask();
        },
      ),
      _QuickActionItem(
        title: context.tr('incubator_new_batch'),
        subtitle: context.tr('incubator_title'),
        icon: Icons.wb_incandescent_outlined,
        color: AppColors.warning,
        onTap: () {
          Navigator.pop(context);
          onNewIncubation();
        },
      ),
    ];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardBackgroundDark
            : AppColors.cardBackgroundLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('dash_quick_action'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          context.tr('dash_quick_action_sub'),
                          style: TextStyle(
                            fontSize: 12,
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
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Flexible(
                child: SingleChildScrollView(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 500;
                      final crossAxisCount = isWide ? 4 : 2;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: isWide ? 1.4 : 1.18,
                        ),
                        itemCount: actions.length,
                        itemBuilder: (context, i) {
                          final a = actions[i];
                          return InkWell(
                            onTap: a.onTap,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.pageBackgroundDark
                                    : const Color(0xFFF8FAFB),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.borderDark
                                      : AppColors.borderLight,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: a.color.withAlpha(24),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      a.icon,
                                      color: a.color,
                                      size: 18,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        a.title,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? AppColors.textPrimaryDark
                                              : AppColors.textPrimaryLight,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        a.subtitle,
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          color: isDark
                                              ? AppColors.textTertiaryDark
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
