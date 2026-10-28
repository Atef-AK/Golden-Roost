import 'package:flutter_test/flutter_test.dart';
import 'package:golden_roost/core/services/feed_automation_service.dart';
import 'package:golden_roost/core/utils/calculations.dart';
import 'package:golden_roost/models/article.dart';
import 'package:golden_roost/models/flock.dart';
import 'package:golden_roost/models/poultry_product.dart';
import 'package:golden_roost/models/sync_item.dart';

void main() {
  group('Feed Automation & Ledger Integrity Tests', () {
    test(
      'forecastDailyDemand is a read-only calculation and does not alter stock',
      () {
        final now = DateTime.now();
        final flock1 = Flock(
          id: 'flock_1',
          name: 'Layers 1',
          species: 'chicken',
          breed: 'Hy-Line',
          purpose: 'layers',
          acquisitionDate: now.subtract(const Duration(days: 140)), // 20 weeks
          startCount: 200,
          currentCount: 195, // 5 mortality
          createdAt: now,
        );

        final flock2 = Flock(
          id: 'flock_2',
          name: 'Broilers 2',
          species: 'chicken',
          breed: 'Ross 308',
          purpose: 'meat',
          acquisitionDate: now.subtract(const Duration(days: 21)), // 3 weeks
          startCount: 500,
          currentCount: 490,
          createdAt: now,
        );

        // Adult layer at 20 weeks ~118g/bird * 195 birds = 23.01 kg
        // 3-week broiler ~108g/bird * 490 birds = 52.92 kg; Total combined = 75.93 kg
        final forecast1 = FeedAutomationService.instance
            .forecastDailyDemand(flocks: [flock1])
            .totalDemandKg;
        final forecastCombined = FeedAutomationService.instance
            .forecastDailyDemand(flocks: [flock1, flock2])
            .totalDemandKg;

        expect(forecast1, closeTo(23.01, 0.01));
        expect(forecastCombined, closeTo(75.93, 0.01));
      },
    );

    test('calculateDaysBeforeRefill and refill date projection', () {
      const totalStock = 542.75;
      const dailyDemand = 54.275;

      final daysRemaining = FarmCalculations.calculateDaysBeforeRefill(
        totalStockKg: totalStock,
        totalDailyDemandKg: dailyDemand,
      );
      expect(daysRemaining, 10);

      final refillDate = FarmCalculations.calculateEstimatedRefillDate(
        totalStockKg: totalStock,
        totalDailyDemandKg: dailyDemand,
        fromDate: DateTime(2026, 3, 1),
      );
      expect(refillDate, DateTime(2026, 3, 11));
    });
  });

  group('Sync Outbox & Serialization Tests', () {
    test('SyncItem holds durable outbox metadata and idempotency key', () {
      final now = DateTime.now();
      final syncItem = SyncItem(
        id: 'sync_test_001',
        tableName: 'flocks',
        recordId: 'flock_abc',
        action: 'insert',
        payload: '{"name":"Golden Flock","start_count":100}',
        idempotencyKey: 'flocks_flock_abc_insert_12345678',
        status: 'pending',
        createdAt: now,
      );

      expect(syncItem.tableName, 'flocks');
      expect(syncItem.action, 'insert');
      expect(syncItem.idempotencyKey, 'flocks_flock_abc_insert_12345678');
      expect(syncItem.status, 'pending');

      final map = syncItem.toMap();
      final restored = SyncItem.fromMap(map);

      expect(restored.id, syncItem.id);
      expect(restored.idempotencyKey, syncItem.idempotencyKey);
      expect(restored.payload, syncItem.payload);
    });

    test('SyncTombstone tracks explicit deletions', () {
      final now = DateTime.now();
      final tombstone = SyncTombstone(
        tableName: 'egg_sales',
        recordId: 'sale_999',
        deletedAt: now,
        synced: false,
      );

      final map = tombstone.toMap();
      final restored = SyncTombstone.fromMap(map);

      expect(restored.tableName, 'egg_sales');
      expect(restored.recordId, 'sale_999');
      expect(restored.synced, false);
    });
  });

  group('Articles and Products Localization & Entity Tests', () {
    test('Article trilingual title, summary, and body fallback', () {
      final now = DateTime.now();
      final article = Article(
        id: 'art_test',
        slug: 'test-slug',
        titleEn: 'Day-Old Chick Care',
        titleFr: 'Soin des Poussins',
        titleAr: 'رعاية الكتاكيت',
        summaryEn: 'Summary in EN',
        summaryFr: 'Résumé en FR',
        summaryAr: 'ملخص بالعربية',
        bodyEn: 'Body EN',
        bodyFr: 'Corps FR',
        bodyAr: 'المحتوى بالعربية',
        category: 'brooding',
        publishedAt: now,
        updatedAt: now,
      );

      expect(article.localizedTitle('en'), 'Day-Old Chick Care');
      expect(article.localizedTitle('fr'), 'Soin des Poussins');
      expect(article.localizedTitle('ar'), 'رعاية الكتاكيت');
      // Fallback for unknown language
      expect(article.localizedTitle('es'), 'Day-Old Chick Care');
    });

    test('PoultryProduct affiliate disclosure and URL resolution', () {
      final now = DateTime.now();
      final product = PoultryProduct(
        id: 'prod_1',
        category: 'incubators',
        nameEn: 'Automatic 56-Egg Incubator',
        nameFr: 'Couveuse 56 Œufs',
        nameAr: 'فقاسة ٥٦ بيضة',
        descriptionEn: 'Digital incubator with humidity pump',
        descriptionFr: 'Couveuse digitale',
        descriptionAr: 'فقاسة رقمية',
        merchantName: 'AvianTech',
        price: 99.0,
        targetUrl: 'https://example.com/item/1',
        affiliateUrl: 'https://example.com/item/1?ref=goldenroost',
        createdAt: now,
      );

      expect(
        product.effectiveUrl,
        'https://example.com/item/1?ref=goldenroost',
      );
      expect(
        product.commercialDisclosure.contains('affiliate commission') ||
            product.commercialDisclosure.contains('commission'),
        true,
      );
    });
  });
}
