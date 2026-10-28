import 'package:flutter/material.dart';
import 'app_theme.dart';

class ResponsiveBreakpoints {
  static const double mobile = 600.0;
  static const double tablet = 1024.0;
}

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  bool get isMobile => screenWidth < ResponsiveBreakpoints.mobile;
  bool get isTablet =>
      screenWidth >= ResponsiveBreakpoints.mobile &&
      screenWidth < ResponsiveBreakpoints.tablet;
  bool get isDesktop => screenWidth >= ResponsiveBreakpoints.tablet;

  T responsiveValue<T>({required T mobile, T? tablet, T? desktop}) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }
}

/// A wrapper that constrains wide content cleanly on tablet and desktop monitors.
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 1100,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
      ),
    );
  }
}

/// An enterprise surface card: hairline border, layered soft shadow,
/// hover lift (desktop/web) and press feedback (touch).
class PremiumCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final double radius;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.color,
    this.borderColor,
    this.radius = AppTheme.cardRadius,
  });

  @override
  State<PremiumCard> createState() => _PremiumCardState();
}

class _PremiumCardState extends State<PremiumCard> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final interactive = widget.onTap != null;

    final resolvedColor =
        widget.color ??
        (isDark ? AppColors.cardBackgroundDark : AppColors.cardBackgroundLight);
    final baseBorder =
        widget.borderColor ??
        (isDark ? AppColors.borderDark : AppColors.borderLight);
    final resolvedBorderColor = (interactive && _isHovered)
        ? theme.colorScheme.primary.withAlpha(90)
        : baseBorder;

    final cardContent = AnimatedScale(
      scale: (_isPressed && interactive) ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        margin: widget.margin,
        transform: Matrix4.translationValues(
          0,
          (interactive && _isHovered && !_isPressed) ? -2 : 0,
          0,
        ),
        decoration: BoxDecoration(
          color: resolvedColor,
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(color: resolvedBorderColor, width: 1),
          boxShadow: AppShadows.card(isDark),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.radius - 1),
          child: Padding(
            padding: widget.padding ?? EdgeInsets.zero,
            child: widget.child,
          ),
        ),
      ),
    );

    if (!interactive) return cardContent;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: cardContent,
      ),
    );
  }
}

/// Rounded icon tile used across lists and headers for consistent iconography.
class IconTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;

  const IconTile({
    super.key,
    required this.icon,
    required this.color,
    this.size = 40,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withAlpha(isDark ? 60 : 36),
            color.withAlpha(isDark ? 26 : 14),
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.32),
        border: Border.all(color: color.withAlpha(isDark ? 70 : 40)),
      ),
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}

enum BadgeVariant { primary, success, warning, error, info, neutral }

/// A pill-shaped semantic badge with a leading status dot (or icon).
class StatusBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final BadgeVariant? variant;
  final Color? textColor;
  final IconData? icon;
  final bool isFilled;

  const StatusBadge({
    super.key,
    required this.label,
    this.color,
    this.variant,
    this.textColor,
    this.icon,
    this.isFilled = false,
  });

  factory StatusBadge.success(String label, {IconData? icon}) => StatusBadge(
    label: label,
    color: AppColors.success,
    textColor: AppColors.success,
    icon: icon,
  );

  factory StatusBadge.warning(String label, {IconData? icon}) => StatusBadge(
    label: label,
    color: AppColors.warning,
    textColor: AppColors.warning,
    icon: icon,
  );

  factory StatusBadge.error(String label, {IconData? icon}) => StatusBadge(
    label: label,
    color: AppColors.error,
    textColor: AppColors.error,
    icon: icon,
  );

  factory StatusBadge.info(String label, {IconData? icon}) => StatusBadge(
    label: label,
    color: AppColors.primaryTeal,
    textColor: AppColors.primaryTeal,
    icon: icon,
  );

  factory StatusBadge.neutral(String label, {IconData? icon}) => StatusBadge(
    label: label,
    color: AppColors.textSecondaryLight,
    textColor: AppColors.textSecondaryLight,
    icon: icon,
  );

  Color _resolveColor() {
    if (color != null) return color!;
    switch (variant) {
      case BadgeVariant.success:
        return AppColors.success;
      case BadgeVariant.warning:
        return AppColors.warning;
      case BadgeVariant.error:
        return AppColors.error;
      case BadgeVariant.info:
        return AppColors.info;
      case BadgeVariant.neutral:
        return AppColors.textSecondaryLight;
      case BadgeVariant.primary:
      default:
        return AppColors.primaryTeal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveColor = _resolveColor();
    // Lift contrast of brand-dark tones on dark surfaces.
    final displayColor = (isDark && !isFilled)
        ? Color.lerp(effectiveColor, Colors.white, 0.25)!
        : effectiveColor;
    final effectiveTextColor = textColor != null
        ? (isDark ? Color.lerp(textColor, Colors.white, 0.25)! : textColor!)
        : displayColor;
    final fg = isFilled ? Colors.white : effectiveTextColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: isFilled
            ? effectiveColor
            : effectiveColor.withAlpha(isDark ? 40 : 20),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isFilled
              ? effectiveColor
              : effectiveColor.withAlpha(isDark ? 80 : 50),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, size: 11, color: fg)
          else
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: fg,
                letterSpacing: 0.2,
                height: 1.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Section header with an accent bar, title/subtitle and a chevron action.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.fromLTRB(16, 18, 16, 8),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    Widget? actionWidget = trailing;
    if (actionWidget == null && actionLabel != null && onAction != null) {
      actionWidget = TextButton(
        style: TextButton.styleFrom(
          visualDensity: VisualDensity.compact,
          minimumSize: const Size(0, 34),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          backgroundColor: primary.withAlpha(isDark ? 36 : 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        onPressed: onAction,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              actionLabel!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: primary,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
              size: 16,
              color: primary,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 4,
            height: subtitle != null ? 34 : 18,
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
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
              ],
            ),
          ),
          if (actionWidget != null) ...[const SizedBox(width: 8), actionWidget],
        ],
      ),
    );
  }
}
