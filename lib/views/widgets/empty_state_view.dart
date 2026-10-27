import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class EmptyStateView extends StatelessWidget {
  final IconData? icon;
  final Widget? iconWidget;
  final String title;
  final String description;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateView({
    super.key,
    this.icon,
    this.iconWidget,
    required this.title,
    required this.description,
    this.buttonText,
    this.onButtonPressed,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: (isDark
                    ? AppColors.darkGraphiteCard
                    : AppColors.primaryTealSurface),
                shape: BoxShape.circle,
                border: Border.all(
                  color: (isDark
                      ? AppColors.borderDark
                      : AppColors.borderLight),
                  width: 1,
                ),
              ),
              child: Center(
                child: iconWidget ??
                    Icon(
                      icon ?? Icons.info_outline,
                      size: 30,
                      color: AppColors.primaryTeal,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if ((buttonText != null || actionLabel != null) &&
                (onButtonPressed != null || onAction != null)) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                ),
                onPressed: onButtonPressed ?? onAction,
                icon: const Icon(Icons.add, size: 18),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(buttonText ?? actionLabel!, maxLines: 1),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
