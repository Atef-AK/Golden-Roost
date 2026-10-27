import 'package:flutter/material.dart';

/// Golden Roost enterprise design tokens.
///
/// Token *names* are kept stable (many screens reference them directly);
/// only their values were refined for a modern, enterprise-grade palette.
class AppColors {
  // Brand Palette - Enterprise Emerald
  static const Color primaryTeal = Color(0xFF0B7A62);
  static const Color primaryTealLight = Color(0xFF14A383);
  static const Color primaryTealDark = Color(0xFF075A49);
  static const Color primaryTealSurface = Color(0xFFE6F4F0);

  // Ink (used for hero surfaces & dark accents)
  static const Color darkGraphite = Color(0xFF0B1324);
  static const Color darkGraphiteCard = Color(0xFF131C2E);
  static const Color darkGraphiteBorder = Color(0xFF243047);

  static const Color limeAccent = Color(0xFFA3D93B);
  static const Color limeAccentMuted = Color(0xFFD4EDA0);
  static const Color limeAccentSurface = Color(0xFFF3FAE6);

  // Light Neutrals (slate scale)
  static const Color pageBackgroundLight = Color(0xFFF5F7FA);
  static const Color cardBackgroundLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE5E8ED);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF5A6478);
  static const Color textTertiaryLight = Color(0xFF97A0B0);

  // Dark Neutrals
  static const Color pageBackgroundDark = Color(0xFF090D14);
  static const Color cardBackgroundDark = Color(0xFF111823);
  static const Color borderDark = Color(0xFF212B38);
  static const Color textPrimaryDark = Color(0xFFF1F4F8);
  static const Color textSecondaryDark = Color(0xFFA0AABA);
  static const Color textTertiaryDark = Color(0xFF6B7687);

  // Functional Semantic Colors
  static const Color success = Color(0xFF119468);
  static const Color successSurface = Color(0xFFE7F6EF);
  static const Color warning = Color(0xFFD97A06);
  static const Color warningSurface = Color(0xFFFDF3E5);
  static const Color error = Color(0xFFE0464B);
  static const Color errorSurface = Color(0xFFFDECEC);
  static const Color info = Color(0xFF2F6FE4);
  static const Color infoSurface = Color(0xFFEAF1FD);

  // Backward-compatible alias helpers
  static const Color primary = primaryTeal;
  static const Color primaryDark = primaryTealDark;
  static const Color primaryLight = primaryTealLight;
  static const Color primarySage = limeAccentMuted;
  static const Color accentWarm = warningSurface;
  static const Color semanticSuccess = success;
  static const Color semanticWarning = warning;
  static const Color semanticError = error;
  static const Color backgroundLight = pageBackgroundLight;
  static const Color surfaceLight = cardBackgroundLight;
  static const Color cardLight = cardBackgroundLight;
  static const Color surfaceBorderLight = borderLight;

  static const Color backgroundDark = pageBackgroundDark;
  static const Color surfaceDark = cardBackgroundDark;
  static const Color cardDark = cardBackgroundDark;
  static const Color surfaceBorderDark = borderDark;

  static const Color accentAmber = warning;
  static const Color accentGold = warning;
  static const Color accentLime = limeAccent;
  static const Color textDark = textPrimaryLight;
  static const Color textMutedLight = textSecondaryLight;
  static const Color textLight = textPrimaryDark;
  static const Color textMutedDark = textSecondaryDark;

  /// Signature brand gradient used on hero surfaces.
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF075A49), Color(0xFF0B7A62), Color(0xFF12957A)],
  );

  /// Deep ink gradient for dark hero surfaces.
  static const LinearGradient inkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B1324), Color(0xFF0F2A2A), Color(0xFF0B5546)],
  );
}

/// Elevation tokens (layered, soft shadows à la modern enterprise products).
class AppShadows {
  static List<BoxShadow> card(bool isDark) => isDark
      ? [
          BoxShadow(
            color: Colors.black.withAlpha(70),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ]
      : [
          BoxShadow(
            color: const Color(0xFF0F172A).withAlpha(8),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
          BoxShadow(
            color: const Color(0xFF0F172A).withAlpha(10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ];

  static List<BoxShadow> raised(Color tint) => [
    BoxShadow(
      color: tint.withAlpha(60),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];
}

class AppTheme {
  static const double cardRadius = 18.0;
  static const double buttonRadius = 12.0;
  static const double inputRadius = 12.0;
  static const String fontFamily = 'PlexSans';

  static ThemeData lightTheme([String font = '']) =>
      _build(Brightness.light, font.isNotEmpty ? font : fontFamily);

  static ThemeData darkTheme([String font = '']) =>
      _build(Brightness.dark, font.isNotEmpty ? font : fontFamily);

  static TextTheme _textTheme(Color primary, Color secondary) {
    return TextTheme(
      displaySmall: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: primary,
      ),
      headlineMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        color: primary,
      ),
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: primary,
      ),
      titleLarge: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: primary,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: primary,
      ),
      titleSmall: TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      bodyLarge: TextStyle(fontSize: 15, height: 1.45, color: primary),
      bodyMedium: TextStyle(fontSize: 14, height: 1.45, color: primary),
      bodySmall: TextStyle(fontSize: 12, height: 1.4, color: secondary),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: primary,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: secondary,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: secondary,
      ),
    );
  }

  static ThemeData _build(Brightness brightness, String font) {
    final isDark = brightness == Brightness.dark;

    final primary = isDark ? AppColors.primaryTealLight : AppColors.primaryTeal;
    final page = isDark
        ? AppColors.pageBackgroundDark
        : AppColors.pageBackgroundLight;
    final surface = isDark
        ? AppColors.cardBackgroundDark
        : AppColors.cardBackgroundLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final textTertiary = isDark
        ? AppColors.textTertiaryDark
        : AppColors.textTertiaryLight;
    final primaryContainer = isDark
        ? const Color(0xFF0E3B33)
        : AppColors.primaryTealSurface;
    final inputFill = isDark ? const Color(0xFF0D131C) : const Color(0xFFF8FAFC);
    final mutedFill = isDark ? const Color(0xFF18212D) : const Color(0xFFF1F4F8);

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primaryContainer,
      onPrimaryContainer: isDark
          ? const Color(0xFF8BF0D6)
          : AppColors.primaryTealDark,
      secondary: isDark ? AppColors.limeAccent : AppColors.darkGraphite,
      onSecondary: isDark ? AppColors.darkGraphite : Colors.white,
      secondaryContainer: mutedFill,
      onSecondaryContainer: textPrimary,
      tertiary: AppColors.limeAccent,
      onTertiary: AppColors.darkGraphite,
      surface: surface,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      surfaceContainerLowest: surface,
      surfaceContainerLow: surface,
      surfaceContainer: surface,
      surfaceContainerHigh: surface,
      surfaceContainerHighest: mutedFill,
      error: AppColors.error,
      onError: Colors.white,
      outline: border,
      outlineVariant: border.withAlpha(140),
      shadow: Colors.black,
    );

    OutlineInputBorder inputBorder(Color c, [double w = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: BorderSide(color: c, width: w),
        );

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(buttonRadius),
    );
    const buttonText = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: font,
      colorScheme: colorScheme,
      primaryColor: primary,
      scaffoldBackgroundColor: page,
      canvasColor: page,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      textTheme: _textTheme(textPrimary, textSecondary),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: page,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary, size: 22),
        actionsIconTheme: IconThemeData(color: textPrimary, size: 22),
        titleTextStyle: TextStyle(
          fontFamily: font,
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(color: border, width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 70,
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: primary.withAlpha(isDark ? 45 : 28),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: font,
            fontSize: 11.5,
            fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
            color: sel ? primary : textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 23,
            color: sel ? primary : textSecondary,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surface,
        selectedIconTheme: IconThemeData(color: primary, size: 24),
        unselectedIconTheme: IconThemeData(color: textSecondary, size: 22),
        selectedLabelTextStyle: TextStyle(
          fontFamily: font,
          color: primary,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        unselectedLabelTextStyle: TextStyle(
          fontFamily: font,
          color: textSecondary,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        indicatorColor: primary.withAlpha(isDark ? 45 : 28),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        labelType: NavigationRailLabelType.all,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: inputBorder(border),
        enabledBorder: inputBorder(border),
        focusedBorder: inputBorder(primary, 1.6),
        errorBorder: inputBorder(AppColors.error),
        focusedErrorBorder: inputBorder(AppColors.error, 1.6),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
        hintStyle: TextStyle(color: textTertiary, fontSize: 14),
        labelStyle: TextStyle(color: textSecondary, fontSize: 14),
        helperStyle: TextStyle(color: textTertiary, fontSize: 12),
        floatingLabelStyle: TextStyle(
          color: primary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: buttonShape,
          textStyle: buttonText,
          elevation: 0,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          backgroundColor: surface,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          side: BorderSide(color: border, width: 1),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: buttonShape,
          textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        highlightElevation: 6,
        focusElevation: 4,
        hoverElevation: 6,
        extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
        extendedTextStyle: TextStyle(
          fontFamily: font,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(buttonShape),
          side: WidgetStatePropertyAll(BorderSide(color: border)),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? primary.withAlpha(isDark ? 50 : 26)
                : surface,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? primary : textSecondary,
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: primary.withAlpha(isDark ? 50 : 26),
        disabledColor: mutedFill,
        checkmarkColor: primary,
        side: BorderSide(color: border, width: 1),
        labelStyle: TextStyle(
          fontFamily: font,
          color: textPrimary,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: TextStyle(
          fontFamily: font,
          color: primary,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: textSecondary,
        dividerColor: border,
        indicatorSize: TabBarIndicatorSize.label,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: primary, width: 3),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
        ),
        labelStyle: TextStyle(
          fontFamily: font,
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: font,
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: textSecondary,
        titleTextStyle: TextStyle(
          fontFamily: font,
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: font,
          fontSize: 12.5,
          color: textSecondary,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.white : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primary : null,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primary : border,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primary : null,
        ),
        side: BorderSide(color: textTertiary, width: 1.5),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primary : textTertiary,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: mutedFill,
        circularTrackColor: mutedFill,
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 12,
        shadowColor: Colors.black.withAlpha(isDark ? 140 : 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: border),
        ),
        titleTextStyle: TextStyle(
          fontFamily: font,
          fontSize: 19,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: textPrimary,
        ),
        contentTextStyle: TextStyle(
          fontFamily: font,
          fontSize: 14,
          height: 1.45,
          color: textSecondary,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: surface,
        elevation: 8,
        showDragHandle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: border),
        ),
        textStyle: TextStyle(
          fontFamily: font,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF1E2836) : AppColors.darkGraphite,
        contentTextStyle: TextStyle(
          fontFamily: font,
          color: Colors.white,
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: AppColors.limeAccent,
        elevation: 6,
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2836) : AppColors.darkGraphite,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(
          fontFamily: font,
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: border),
            ),
          ),
        ),
      ),
    );
  }
}
