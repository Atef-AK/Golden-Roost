import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        customWidget: (ctx, isSelected, color) =>
            ChickenIcon(size: 22, color: color, outlined: !isSelected),
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
      // Mobile Layout: Premium Golden Roost 2.0 Docked Navigation Bar
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.pageBackgroundDark : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark
                    ? const Color(0xFF1E2822)
                    : const Color(0xFFE4E9E1),
                width: 1.0,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 80 : 12),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 64,
              child: Row(
                children: List.generate(destinations.length, (index) {
                  final d = destinations[index];
                  final isSelected = navigationShell.currentIndex == index;
                  return Expanded(
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        navigationShell.goBranch(
                          index,
                          initialLocation:
                              index == navigationShell.currentIndex,
                        );
                      },
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark
                                        ? AppColors.forestEmerald.withAlpha(55)
                                        : AppColors.forestEmerald.withAlpha(22))
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: d.customWidget != null
                                ? d.customWidget!(
                                    context,
                                    isSelected,
                                    isSelected
                                        ? (isDark
                                              ? AppColors.freshLeaf
                                              : AppColors.forestEmerald)
                                        : (isDark
                                              ? const Color(0xFF6B7C72)
                                              : AppColors.secondaryText),
                                  )
                                : Icon(
                                    isSelected ? d.selectedIcon! : d.icon!,
                                    size: 22,
                                    color: isSelected
                                        ? (isDark
                                              ? AppColors.freshLeaf
                                              : AppColors.forestEmerald)
                                        : (isDark
                                              ? const Color(0xFF6B7C72)
                                              : AppColors.secondaryText),
                                  ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            d.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                              letterSpacing: isSelected ? -0.1 : 0,
                              color: isSelected
                                  ? (isDark
                                        ? Colors.white
                                        : AppColors.forestEmerald)
                                  : (isDark
                                        ? const Color(0xFF6B7C72)
                                        : AppColors.secondaryText),
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

    // Tablet & Desktop Layout: NavigationRail with Brand Header
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) {
              HapticFeedback.selectionClick();
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            extended: isDesktop,
            minExtendedWidth: 220,
            backgroundColor: isDark
                ? AppColors.pageBackgroundDark
                : Colors.white,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/brand/app_icon_golden_roost.jpg',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.forestEmerald,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.agriculture_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  if (isDesktop) ...[
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('app_title'),
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            letterSpacing: -0.3,
                            color: isDark
                                ? Colors.white
                                : AppColors.forestEmerald,
                          ),
                        ),
                        Text(
                          'Golden Roost 2.0',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.goldenHarvest,
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
                                ? const Color(0xFF6B7C72)
                                : AppColors.secondaryText,
                          )
                        : Icon(d.icon),
                    selectedIcon: d.customWidget != null
                        ? d.customWidget!(
                            context,
                            true,
                            isDark
                                ? AppColors.freshLeaf
                                : AppColors.forestEmerald,
                          )
                        : Icon(d.selectedIcon),
                    label: Text(
                      d.label,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                )
                .toList(),
          ),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: isDark ? const Color(0xFF1E2822) : const Color(0xFFE4E9E1),
          ),
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
  final Widget Function(BuildContext context, bool isSelected, Color color)?
  customWidget;
  final String label;

  const _NavDestination({
    this.icon,
    this.selectedIcon,
    this.customWidget,
    required this.label,
  });
}
