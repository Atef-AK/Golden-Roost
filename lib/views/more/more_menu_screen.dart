import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/app_translations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/responsive.dart';
import '../../providers/settings_provider.dart';
import '../widgets/chicken_icon.dart';

class MoreMenuScreen extends ConsumerWidget {
  const MoreMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final menuItems = [
      _MoreTile(
        title: context.tr('tasks_title'),
        subtitle: context.tr('more_tasks_sub'),
        icon: Icons.calendar_month_outlined,
        color: AppColors.primaryTeal,
        route: '/tasks',
      ),
      _MoreTile(
        title: context.tr('eggs_title'),
        subtitle: context.tr('more_eggs_sub'),
        icon: Icons.egg_outlined,
        color: AppColors.primaryTeal,
        route: '/eggs',
      ),
      _MoreTile(
        title: context.tr('feed_title'),
        subtitle: context.tr('more_feed_sub'),
        icon: Icons.restaurant,
        color: AppColors.semanticSuccess,
        route: '/feed',
      ),
      _MoreTile(
        title: context.tr('reports_title'),
        subtitle: context.tr('more_reports_sub'),
        icon: Icons.bar_chart_outlined,
        color: AppColors.primaryTeal,
        route: '/reports',
      ),
      _MoreTile(
        title: context.tr('finance_electricity'),
        subtitle: context.tr('more_electricity_sub'),
        icon: Icons.bolt,
        color: AppColors.semanticWarning,
        route: '/finance/electricity',
      ),
      _MoreTile(
        title: context.tr('settings_title'),
        subtitle: context.tr('more_settings_sub'),
        icon: Icons.settings_outlined,
        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
        route: '/settings',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('nav_more'))),
      body: ResponsiveContainer(
        maxWidth: 900,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            // Header farm banner
            PremiumCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: ChickenIcon(
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                settings.farmName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            StatusBadge(
                              label: context.tr('more_offline_db'),
                              variant: BadgeVariant.success,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${context.tr('more_sqlite_info')} • ${settings.currency} • ${settings.language.toUpperCase()}',
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
                ],
              ),
            ),
            const SizedBox(height: 16),

            LayoutBuilder(
              builder: (ctx, constraints) {
                final isWide = constraints.maxWidth >= 600;
                if (isWide) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          mainAxisExtent: 80,
                        ),
                    itemCount: menuItems.length,
                    itemBuilder: (ctx, i) =>
                        _buildMenuItem(menuItems[i], isDark),
                  );
                }
                return Column(
                  children: menuItems
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildMenuItem(item, isDark),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(_MoreTile item, bool isDark) {
    return Builder(
      builder: (context) {
        return PremiumCard(
          onTap: () => context.push(item.route),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: item.color.withAlpha(isDark ? 25 : 20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: item.color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
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
              Icon(
                Icons.chevron_right,
                size: 20,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MoreTile {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  _MoreTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}
