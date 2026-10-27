import 'package:flutter_test/flutter_test.dart';
import 'package:golden_roost/core/utils/calculations.dart';
import 'package:golden_roost/models/flock.dart';
import 'package:golden_roost/models/feed.dart';
import 'package:golden_roost/models/incubation.dart';

void main() {
  group('FarmCalculations Business Logic Tests', () {
    test(
      'calculateLiveBirds correctly adds purchases/hatches and subtracts mortalities/sales',
      () {
        final liveBirds = FarmCalculations.calculateLiveBirds(
          startCount: 150,
          additions: 20, // e.g. 20 new birds acquired
          reductions: 8, // 5 sold, 3 mortality
        );
        expect(liveBirds, 162);

        // Never goes below 0
        final zeroCount = FarmCalculations.calculateLiveBirds(
          startCount: 10,
          additions: 0,
          reductions: 15,
        );
        expect(zeroCount, 0);
      },
    );

    test('calculateLayingRate computes laying percentage accurately', () {
      // 140 eggs from 147 female birds
      final rate = FarmCalculations.calculateLayingRate(
        eggsCollected: 140,
        femaleBirds: 147,
      );
      expect(rate, closeTo(95.23, 0.05));

      // 0 females or 0 eggs
      expect(
        FarmCalculations.calculateLayingRate(
          eggsCollected: 0,
          femaleBirds: 100,
        ),
        0.0,
      );
      expect(
        FarmCalculations.calculateLayingRate(eggsCollected: 50, femaleBirds: 0),
        0.0,
      );
    });

    test(
      'calculateFeedPerBirdGrams correctly converts kg to daily grams per bird',
      () {
        // 18 kg feed for 150 birds = 120 grams/bird
        final gramsPerBird = FarmCalculations.calculateFeedPerBirdGrams(
          feedKg: 18.0,
          birdCount: 150,
        );
        expect(gramsPerBird, closeTo(120.0, 0.01));

        // Quail feeding: 8.5 kg for 300 quails = 28.33 grams/quail
        final quailGrams = FarmCalculations.calculateFeedPerBirdGrams(
          feedKg: 8.5,
          birdCount: 300,
        );
        expect(quailGrams, closeTo(28.33, 0.05));
      },
    );

    test(
      'calculateDaysFeedRemaining correctly predicts days until feed depletion',
      () {
        // 420 kg stock, 20 kg daily consumption = 21 days
        final days = FarmCalculations.calculateDaysFeedRemaining(
          currentStockKg: 420.0,
          avgDailyConsumptionKg: 20.0,
        );
        expect(days, 21);

        // Empty stock
        expect(
          FarmCalculations.calculateDaysFeedRemaining(
            currentStockKg: 0.0,
            avgDailyConsumptionKg: 15.0,
          ),
          0,
        );
      },
    );

    test(
      'Incubation rates: fertility, hatch from set, and hatch from fertile',
      () {
        // 60 eggs set, 54 fertile, 48 hatched
        final fertility = FarmCalculations.calculateFertilityRate(
          fertileCount: 54,
          eggsSet: 60,
        );
        expect(fertility, closeTo(90.0, 0.01));

        final hatchFromSet = FarmCalculations.calculateHatchRateFromSet(
          hatchedCount: 48,
          eggsSet: 60,
        );
        expect(hatchFromSet, closeTo(80.0, 0.01));

        final hatchFromFertile = FarmCalculations.calculateHatchRateFromFertile(
          hatchedCount: 48,
          fertileCount: 54,
        );
        expect(hatchFromFertile, closeTo(88.88, 0.05));
      },
    );

    test('calculateChickCost computes exact cost per healthy chick', () {
      // Total batch cost: 12 DT eggs + 5 DT electricity/extra = 17 DT for 48 chicks
      final chickCost = FarmCalculations.calculateChickCost(
        totalBatchCost: 17.0,
        hatchedCount: 48,
      );
      expect(chickCost, closeTo(0.354, 0.005));

      // Zero hatched chicks returns 0.0 rather than dividing by zero
      expect(
        FarmCalculations.calculateChickCost(
          totalBatchCost: 20.0,
          hatchedCount: 0,
        ),
        0.0,
      );
    });

    test(
      'calculateNetOperatingResult: Operating Income minus Operating Expenses',
      () {
        final net = FarmCalculations.calculateNetOperatingResult(
          operatingIncome: 1500.0,
          operatingExpenses: 850.0,
        );
        expect(net, 650.0);

        final loss = FarmCalculations.calculateNetOperatingResult(
          operatingIncome: 400.0,
          operatingExpenses: 900.0,
        );
        expect(loss, -500.0);
      },
    );

    test(
      'calculateElectricityCost from equipment wattage, hours and tariff',
      () {
        // 140W incubator running 24h for 21 days at 0.280 TND/kWh
        // Total kWh = (140 * 24 * 21) / 1000 = 70.56 kWh
        // Cost = 70.56 * 0.280 = 19.7568 TND
        final cost = FarmCalculations.calculateElectricityCost(
          wattage: 140.0,
          dailyHours: 24.0,
          days: 21,
          tariffPerKwh: 0.280,
        );
        expect(cost, closeTo(19.756, 0.01));
      },
    );
  });

  group('Data Models Integrity Tests', () {
    test('Flock age calculation in days and weeks', () {
      final now = DateTime.now();
      final flock = Flock(
        id: 'test_1',
        name: 'Test Flock',
        species: 'chicken',
        breed: 'Leghorn',
        purpose: 'layers',
        acquisitionDate: now.subtract(const Duration(days: 49)),
        startCount: 100,
        currentCount: 100,
        createdAt: now.subtract(const Duration(days: 49)),
      );

      expect(flock.ageInDays, closeTo(49, 1));
      expect(flock.ageInWeeks, 7);
    });

    test('Flock hatchDate overrides acquisitionDate for age calibration', () {
      final now = DateTime.now();
      // Flock acquired yesterday, but born 70 days ago (10 weeks)
      final flock = Flock(
        id: 'test_birthday',
        name: 'Hatchery Pullets',
        species: 'chicken',
        breed: 'Hy-Line',
        purpose: 'layers',
        acquisitionDate: now.subtract(const Duration(days: 1)),
        hatchDate: now.subtract(const Duration(days: 70)),
        startCount: 200,
        currentCount: 200,
        createdAt: now.subtract(const Duration(days: 1)),
      );

      expect(flock.effectiveBirthDate, flock.hatchDate);
      expect(flock.ageInDays, closeTo(70, 1));
      expect(flock.ageInWeeks, 10);
    });

    test('FeedItem low stock trigger', () {
      final feedNormal = FeedItem(
        id: 'f1',
        name: 'Layer Mash',
        feedType: 'layer',
        currentStockKg: 50.0,
        lowStockThresholdKg: 20.0,
        updatedAt: DateTime.now(),
      );
      expect(feedNormal.isLowStock, false);

      final feedLow = feedNormal.copyWith(currentStockKg: 15.0);
      expect(feedLow.isLowStock, true);
    });

    test('IncubationBatch days countdown', () {
      final now = DateTime.now();
      final batch = IncubationBatch(
        id: 'b1',
        species: 'quail',
        incubatorName: 'Auto 1',
        setDate: now.subtract(const Duration(days: 12)),
        eggsSetCount: 50,
        expectedHatchDate: now.add(const Duration(days: 5)),
        durationDays: 17,
        createdAt: now.subtract(const Duration(days: 12)),
      );

      expect(batch.daysSinceSet, closeTo(12, 1));
      expect(batch.daysUntilHatch, closeTo(5, 1));
    });
  });
}
