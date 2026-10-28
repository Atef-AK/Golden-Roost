import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/ads/ad_service.dart';
import 'core/localization/western_arabic_localizations.dart';
import 'core/notifications/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'providers/settings_provider.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize background notifications
  await NotificationService.instance.init();

  // Initialize Mobile Ads SDK safely (never crashes if offline)
  await AdService.instance.initialize();

  runApp(const ProviderScope(child: GoldenRoostApp()));
}

class GoldenRoostApp extends ConsumerWidget {
  const GoldenRoostApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final themeMode = switch (settings.themeMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    return MaterialApp.router(
      title: 'Golden Roost',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(''),
      darkTheme: AppTheme.darkTheme(''),
      themeMode: themeMode,
      routerConfig: appRouter,
      locale: Locale(settings.language),
      supportedLocales: const [
        Locale('en', ''),
        Locale('fr', ''),
        Locale('ar', ''),
        Locale('es', ''),
      ],
      localizationsDelegates: const [
        WesternArabicMaterialLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
