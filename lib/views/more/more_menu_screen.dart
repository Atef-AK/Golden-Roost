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

    final productionItems = [
      _MoreTile(
        title: context.tr('tasks_title'),
        subtitle: context.tr('more_tasks_sub'),
        icon: Icons.calendar_month_outlined,
        color: AppColors.forestEmerald,
        route: '/tasks',
      ),
      _MoreTile(
        title: context.tr('eggs_title'),
        subtitle: context.tr('more_eggs_sub'),
        icon: Icons.egg_outlined,
        color: AppColors.goldenHarvest,
        route: '/eggs',
      ),
      _MoreTile(
        title: context.tr('feed_title'),
        subtitle: context.tr('more_feed_sub'),
        icon: Icons.grain_rounded,
        color: AppColors.freshLeaf,
        route: '/feed',
      ),
      _MoreTile(
        title: context.tr('finance_electricity'),
        subtitle: context.tr('more_electricity_sub'),
        icon: Icons.bolt_rounded,
        color: AppColors.goldenHarvest,
        route: '/finance/electricity',
      ),
    ];

    final discoverItems = [
      _MoreTile(
        title: context.tr('articles_title'),
        subtitle: context.tr('articles_search'),
        icon: Icons.menu_book_outlined,
        color: AppColors.forestEmerald,
        route: '/articles',
      ),
      _MoreTile(
        title: context.tr('products_title'),
        subtitle: context.tr('products_view_merchant'),
        icon: Icons.storefront_outlined,
        color: AppColors.goldenHarvest,
        route: '/products',
      ),
    ];

    final systemItems = [
      _MoreTile(
        title: context.tr('reports_title'),
        subtitle: context.tr('more_reports_sub'),
        icon: Icons.bar_chart_outlined,
        color: AppColors.info,
        route: '/reports',
      ),
      _MoreTile(
        title: context.tr('settings_title'),
        subtitle: context.tr('more_settings_sub'),
        icon: Icons.settings_outlined,
        color: isDark ? const Color(0xFF8BA093) : AppColors.secondaryText,
        route: '/settings',
      ),
      _MoreTile(
        title: 'Admin Portal',
        subtitle: 'Content & Push Campaigns',
        icon: Icons.admin_panel_settings_outlined,
        color: AppColors.warning,
        route: '/admin',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('nav_more'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
      ),
      body: ResponsiveContainer(
        maxWidth: 900,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            // Header farm banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 50 : 8),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.forestEmerald, AppColors.deepForest],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.forestEmerald.withAlpha(60),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: ChickenIcon(color: Colors.white, size: 28),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                settings.farmName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 17,
                                  letterSpacing: -0.3,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.mainInk,
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
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.secondaryText,
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
            const SizedBox(height: 22),

            // 1. Operations & Resources
            _buildSectionHeader('OPERATIONS & LOGISTICS', isDark),
            const SizedBox(height: 8),
            _buildGridOrList(productionItems, isDark),
            const SizedBox(height: 20),

            // 2. Discover & Knowledge
            _buildSectionHeader('KNOWLEDGE & EQUIPMENT', isDark),
            const SizedBox(height: 8),
            _buildGridOrList(discoverItems, isDark),
            const SizedBox(height: 20),

            // 3. System & Settings
            _buildSectionHeader('SYSTEM & ADMINISTRATION', isDark),
            const SizedBox(height: 8),
            _buildGridOrList(systemItems, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
          color: isDark ? const Color(0xFF7A8D81) : const Color(0xFF6A7B70),
        ),
      ),
    );
  }

  Widget _buildGridOrList(List<_MoreTile> items, bool isDark) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final isWide = constraints.maxWidth >= 600;
        if (isWide) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 82,
            ),
            itemCount: items.length,
            itemBuilder: (ctx, i) => _buildMenuItem(items[i], isDark),
          );
        }
        return Column(
          children: items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildMenuItem(item, isDark),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildMenuItem(_MoreTile item, bool isDark) {
    return Builder(
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1.0,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push(item.route),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: item.color.withAlpha(isDark ? 36 : 22),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon, color: item.color, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.5,
                              letterSpacing: -0.2,
                              color: isDark ? Colors.white : AppColors.mainInk,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.subtitle,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.secondaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 15,
                      color: isDark
                          ? const Color(0xFF56695E)
                          : const Color(0xFFB5C1B8),
                    ),
                  ],
                ),
              ),
            ),
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
