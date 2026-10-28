import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_roost/core/localization/app_translations.dart';
import 'package:golden_roost/core/theme/app_theme.dart';
import 'package:golden_roost/core/theme/responsive.dart';

void main() {
  group('Responsive System and Design Components Tests', () {
    testWidgets('ResponsiveContainer caps max width on wide screens', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveContainer(
              maxWidth: 1100,
              child: Container(key: const Key('inner_box')),
            ),
          ),
        ),
      );

      final boxFinder = find.byKey(const Key('inner_box'));
      expect(boxFinder, findsOneWidget);
      final size = tester.getSize(boxFinder);
      expect(size.width, lessThanOrEqualTo(1100));
    });

    testWidgets('PremiumCard renders with correct borders and radius', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PremiumCard(child: Text('Card Content'))),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
      expect(find.byType(PremiumCard), findsOneWidget);
    });

    testWidgets('StatusBadge renders across semantic variants', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                StatusBadge(label: 'SUCCESS', variant: BadgeVariant.success),
                StatusBadge(label: 'WARNING', variant: BadgeVariant.warning),
                StatusBadge(label: 'ERROR', variant: BadgeVariant.error),
                StatusBadge(label: 'PRIMARY', variant: BadgeVariant.primary),
              ],
            ),
          ),
        ),
      );

      expect(find.text('SUCCESS'), findsOneWidget);
      expect(find.text('WARNING'), findsOneWidget);
      expect(find.text('ERROR'), findsOneWidget);
      expect(find.text('PRIMARY'), findsOneWidget);
    });

    testWidgets('Arabic RTL Directionality support test', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              appBar: AppBar(title: const Text('لوحة التحكم')),
              body: SectionHeader(
                title: 'إدارة القطيع',
                actionLabel: 'إضافة',
                onAction: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('لوحة التحكم'), findsOneWidget);
      expect(find.text('إدارة القطيع'), findsOneWidget);
      expect(find.text('إضافة'), findsOneWidget);
    });

    testWidgets('Narrow mobile screen layout (320px) test', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme(),
          home: const Scaffold(
            body: ResponsiveContainer(
              child: Column(
                children: [
                  StatusBadge(
                    label: 'ACTIVE BATCH',
                    variant: BadgeVariant.primary,
                  ),
                  SizedBox(height: 10),
                  Text('320px viewport without overflow'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('ACTIVE BATCH'), findsOneWidget);
      expect(find.text('320px viewport without overflow'), findsOneWidget);
    });

    test('Four-language system (EN, FR, AR, ES) resolves correctly', () {
      // English
      expect(AppTranslations.get('nav_flocks', AppLanguage.en), 'Flocks');
      expect(
        AppTranslations.get('dash_eggs_today', AppLanguage.en),
        'Eggs Today',
      );

      // French
      expect(AppTranslations.get('nav_flocks', AppLanguage.fr), 'Troupeaux');
      expect(
        AppTranslations.get('dash_eggs_today', AppLanguage.fr),
        'Œufs du Jour',
      );

      // Arabic
      expect(AppTranslations.get('nav_flocks', AppLanguage.ar), 'القطعان');
      expect(
        AppTranslations.get('dash_eggs_today', AppLanguage.ar),
        'بيض اليوم',
      );

      // Spanish (New in Golden Roost 2.0)
      expect(AppTranslations.get('nav_flocks', AppLanguage.es), 'Lotes');
      expect(
        AppTranslations.get('dash_eggs_today', AppLanguage.es),
        'Huevos de Hoy',
      );
      expect(
        AppTranslations.get('feed_title', AppLanguage.es),
        'Alimento e Inventario',
      );
    });

    test('Golden Roost 2.0 design tokens match specification', () {
      expect(AppColors.forestEmerald, const Color(0xFF176B4D));
      expect(AppColors.deepForest, const Color(0xFF104735));
      expect(AppColors.freshLeaf, const Color(0xFF79B85A));
      expect(AppColors.goldenHarvest, const Color(0xFFE4AF49));
      expect(AppColors.warmIvory, const Color(0xFFF8F7F1));
    });
  });
}
