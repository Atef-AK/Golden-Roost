import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/localization/app_translations.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/responsive.dart';

import 'widgets/chicken_icon.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isWide = !context.isMobile;
    final isDesktop = context.isDesktop;

    final destinations = [
      _NavDestination(
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard_rounded,
        label: context.tr('nav_dashboard'),
      ),
      _NavDestination(
        customWidget: (ctx, isSelected, color) => ChickenIcon(
          size: 21,
          color: color,
          outlined: !isSelected,
        ),
        label: context.tr('nav_flocks'),
      ),
      _NavDestination(
        icon: Icons.wb_incandescent_outlined,
        selectedIcon: Icons.wb_incandescent_rounded,
        label: context.tr('nav_incubator'),
      ),
      _NavDestination(
        icon: Icons.account_balance_wallet_outlined,
        selectedIcon: Icons.account_balance_wallet_rounded,
        label: context.tr('nav_finance'),
      ),
      _NavDestination(
        icon: Icons.grid_view_outlined,
        selectedIcon: Icons.grid_view_rounded,
        label: context.tr('nav_more'),
      ),
    ];

    if (!isWide) {
      // Mobile Layout: Bespoke Enterprise Docked Bar
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0C1322) : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark ? const Color(0xFF1E283D) : const Color(0xFFE2E8F0),
                width: 0.8,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 90 : 10),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 60,
              child: Row(
                children: List.generate(destinations.length, (index) {
                  final d = destinations[index];
                  final isSelected = navigationShell.currentIndex == index;
                  return Expanded(
                    child: InkWell(
                      onTap: () {
                        navigationShell.goBranch(
                          index,
                          initialLocation: index == navigationShell.currentIndex,
                        );
                      },
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark
                                      ? AppColors.primaryTeal.withAlpha(56)
                                      : AppColors.primaryTeal.withAlpha(30))
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: d.customWidget != null
                                ? d.customWidget!(
                                    context,
                                    isSelected,
                                    isSelected
                                        ? (isDark
                                            ? AppColors.primaryTealLight
                                            : AppColors.primaryTeal)
                                        : (isDark
                                            ? const Color(0xFF64748B)
                                            : const Color(0xFF94A3B8)),
                                  )
                                : Icon(
                                    isSelected ? d.selectedIcon! : d.icon!,
                                    size: 21,
                                    color: isSelected
                                        ? (isDark
                                            ? AppColors.primaryTealLight
                                            : AppColors.primaryTeal)
                                        : (isDark
                                            ? const Color(0xFF64748B)
                                            : const Color(0xFF94A3B8)),
                                  ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            d.label,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? (isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight)
                                  : (isDark
                                      ? const Color(0xFF64748B)
                                      : const Color(0xFF94A3B8)),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      );
    }

    // Tablet & Desktop Layout: NavigationRail or Wide Sidebar
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            extended: isDesktop,
            minExtendedWidth: 200,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.agriculture_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  if (isDesktop) ...[
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('app_title'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            letterSpacing: -0.3,
                            color: AppColors.primaryTeal,
                          ),
                        ),
                        Text(
                          'Poultry Manager',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            destinations: destinations
                .map(
                  (d) => NavigationRailDestination(
                    icon: d.customWidget != null
                        ? d.customWidget!(
                            context,
                            false,
                            isDark
                                ? const Color(0xFF64748B)
                                : const Color(0xFF94A3B8),
                          )
                        : Icon(d.icon),
                    selectedIcon: d.customWidget != null
                        ? d.customWidget!(
                            context,
                            true,
                            isDark
                                ? AppColors.primaryTealLight
                                : AppColors.primaryTeal,
                          )
                        : Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
                )
                .toList(),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            child: ResponsiveContainer(maxWidth: 1200, child: navigationShell),
          ),
        ],
      ),
    );
  }
}

class _NavDestination {
  final IconData? icon;
  final IconData? selectedIcon;
  final Widget Function(BuildContext context, bool isSelected, Color color)? customWidget;
  final String label;

  const _NavDestination({
    this.icon,
    this.selectedIcon,
    this.customWidget,
    required this.label,
  });
}
