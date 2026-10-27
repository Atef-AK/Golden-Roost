import '../../models/flock.dart';
import '../../models/bird_movement.dart';
import '../../models/feed.dart';
import '../../models/egg_record.dart';
import '../../models/incubation.dart';
import '../../models/task_item.dart';
import '../../models/vaccination.dart';
import '../../models/finance.dart';
import '../../models/electricity.dart';
import 'database_helper.dart';

class SampleDataGenerator {
  static Future<void> loadSampleData() async {
    final db = DatabaseHelper.instance;
    final now = DateTime.now();

    // 1. Settings - Preserve user's current language, theme, and currency choices
    final currentSettings = await db.getSettings();
    await db.updateSettings(
      currentSettings.copyWith(
        farmName: currentSettings.farmName == 'My Poultry Farm' || currentSettings.farmName.isEmpty
            ? (currentSettings.language == 'ar' ? 'مزرعة البركة للدواجن' : 'El-Baraka Poultry Farm')
            : currentSettings.farmName,
        electricityKwhRate: currentSettings.electricityKwhRate > 0 ? currentSettings.electricityKwhRate : 0.280,
      ),
    );

    // 2. Flocks
    final flock1 = Flock(
      id: 'sample_flock_lohmann',
      name: 'Lohmann Brown Layers',
      species: 'chicken',
      breed: 'Lohmann Brown Classic',
      purpose: 'layers',
      acquisitionDate: now.subtract(const Duration(days: 60)),
      startCount: 155,
      currentCount: 152,
      maleCount: 5,
      femaleCount: 147,
      purchasePricePerBird: 18.5,
      totalPurchaseCost: 2867.5,
      supplier: 'Sidi Thabet Hatchery',
      housingLocation: 'Coop A (Layers Shed)',
      notes: 'Pullets delivered at 16 weeks old. Peak laying expected soon.',
      createdAt: now.subtract(const Duration(days: 60)),
    );

    final flock2 = Flock(
      id: 'sample_flock_quails',
      name: 'Coturnix Quails Alpha',
      species: 'quail',
      breed: 'Japanese Coturnix',
      purpose: 'breeders',
      acquisitionDate: now.subtract(const Duration(days: 35)),
      startCount: 300,
      currentCount: 294,
      maleCount: 60,
      femaleCount: 234,
      purchasePricePerBird: 3.2,
      totalPurchaseCost: 960.0,
      supplier: 'Bizerte Avian Center',
      housingLocation: 'Cage Battery Row 1',
      notes: 'Good egg size, breeding group with 1:4 ratio.',
      createdAt: now.subtract(const Duration(days: 35)),
    );

    await db.insertFlock(flock1);
    await db.insertFlock(flock2);

    // Initial flock purchase finances
    await db.insertFinance(
      FinancialTransaction(
        id: 'sample_fin_purchase_f1',
        type: 'expense',
        category: 'adult_birds',
        amount: 2867.5,
        date: now.subtract(const Duration(days: 60)),
        flockId: flock1.id,
        notes: '155 Lohmann Brown pullets purchase',
        createdAt: now.subtract(const Duration(days: 60)),
      ),
    );

    await db.insertFinance(
      FinancialTransaction(
        id: 'sample_fin_purchase_f2',
        type: 'expense',
        category: 'adult_birds',
        amount: 960.0,
        date: now.subtract(const Duration(days: 35)),
        flockId: flock2.id,
        notes: '300 Coturnix quails purchase',
        createdAt: now.subtract(const Duration(days: 35)),
      ),
    );

    // 3. Bird Movements (Mortality / Culls)
    await db.insertBirdMovement(
      BirdMovement(
        id: 'sample_mov_1',
        flockId: flock1.id,
        date: now.subtract(const Duration(days: 42)),
        type: 'mortality',
        count: 2,
        maleCount: 0,
        femaleCount: 2,
        reasonOrBuyer: 'Heat stress during initial week',
        notes: 'Added electrolytes to drinking water afterwards',
        createdAt: now.subtract(const Duration(days: 42)),
      ),
    );

    await db.insertBirdMovement(
      BirdMovement(
        id: 'sample_mov_2',
        flockId: flock1.id,
        date: now.subtract(const Duration(days: 15)),
        type: 'cull',
        count: 1,
        maleCount: 0,
        femaleCount: 1,
        reasonOrBuyer: 'Leg injury non-recovery',
        createdAt: now.subtract(const Duration(days: 15)),
      ),
    );

    await db.insertBirdMovement(
      BirdMovement(
        id: 'sample_mov_3',
        flockId: flock2.id,
        date: now.subtract(const Duration(days: 18)),
        type: 'mortality',
        count: 6,
        maleCount: 1,
        femaleCount: 5,
        reasonOrBuyer: 'Natural attrition during acclimation',
        createdAt: now.subtract(const Duration(days: 18)),
      ),
    );

    // 4. Feed Inventory
    final feed1 = FeedItem(
      id: 'sample_feed_layer',
      name: 'Layer Mash 17% Protein',
      feedType: 'layer',
      currentStockKg: 420.0,
      lowStockThresholdKg: 100.0,
      bagWeightKg: 50.0,
      costPerBag: 68.0,
      notes: 'Fortified with calcium and vitamins for laying hens.',
      updatedAt: now,
    );

    final feed2 = FeedItem(
      id: 'sample_feed_quail',
      name: 'Quail Breeder Crumble 20%',
      feedType: 'quail',
      currentStockKg: 140.0,
      lowStockThresholdKg: 40.0,
      bagWeightKg: 25.0,
      costPerBag: 42.0,
      notes: 'High protein crumble for maximum quail egg fertility.',
      updatedAt: now,
    );

    final feed3 = FeedItem(
      id: 'sample_feed_starter',
      name: 'Chick Starter 21% Medicated',
      feedType: 'starter',
      currentStockKg: 35.0,
      lowStockThresholdKg: 50.0, // Low stock on purpose to demonstrate alert
      bagWeightKg: 25.0,
      costPerBag: 46.0,
      notes: 'For newly hatched chicks from upcoming incubation.',
      updatedAt: now,
    );

    await db.insertFeedItem(feed1);
    await db.insertFeedItem(feed2);
    await db.insertFeedItem(feed3);

    // Feed purchase transactions
    await db.recordFeedTransaction(
      FeedTransaction(
        id: 'sample_feed_tx_p1',
        feedId: feed1.id,
        flockId: flock1.id,
        date: now.subtract(const Duration(days: 20)),
        type: 'purchase',
        quantityKg: 500.0,
        cost: 680.0,
        notes: 'Bought 10 bags of 50kg Layer Mash',
        createdAt: now.subtract(const Duration(days: 20)),
      ),
    );

    await db.recordFeedTransaction(
      FeedTransaction(
        id: 'sample_feed_tx_p2',
        feedId: feed2.id,
        flockId: flock2.id,
        date: now.subtract(const Duration(days: 15)),
        type: 'purchase',
        quantityKg: 200.0,
        cost: 336.0,
        notes: 'Bought 8 bags of 25kg Quail Breeder',
        createdAt: now.subtract(const Duration(days: 15)),
      ),
    );

    // Feed consumption records for past 5 days
    for (int i = 0; i < 5; i++) {
      final date = now.subtract(Duration(days: i));
      await db.recordFeedTransaction(
        FeedTransaction(
          id: 'sample_feed_tx_c1_$i',
          feedId: feed1.id,
          flockId: flock1.id,
          date: date,
          type: 'consumption',
          quantityKg: 18.0, // ~120g per hen
          notes: 'Daily layer feeding 120g/hen',
          createdAt: date,
        ),
      );

      await db.recordFeedTransaction(
        FeedTransaction(
          id: 'sample_feed_tx_c2_$i',
          feedId: feed2.id,
          flockId: flock2.id,
          date: date,
          type: 'consumption',
          quantityKg: 8.5, // ~28g per quail
          notes: 'Daily quail feeding 28g/quail',
          createdAt: date,
        ),
      );
    }

    // 5. Egg Production & Sales
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      // Chicken eggs (~135-142 eggs from 147 hens = ~92-96% laying rate!)
      final chickenTotal = 138 + (i % 5);
      final chickenCracked = (i % 2 == 0) ? 2 : 1;
      final chickenDirty = (i % 3 == 0) ? 3 : 1;
      final chickenUsable = chickenTotal - chickenCracked - chickenDirty;

      await db.insertEggLog(
        EggLog(
          id: 'sample_egg_log_chick_$i',
          flockId: flock1.id,
          date: date,
          collectionTime: 'morning',
          totalEggs: chickenTotal,
          crackedEggs: chickenCracked,
          dirtyEggs: chickenDirty,
          usableEggs: chickenUsable,
          keptForIncubation: 0,
          notes: 'Morning collection. Good shell hardness.',
          createdAt: date,
        ),
      );

      // Quail eggs (~200-215 eggs from 234 females)
      final quailTotal = 205 + (i % 7);
      final quailCracked = 3;
      final quailDirty = 4;
      final quailUsable = quailTotal - quailCracked - quailDirty;
      final quailIncubation = (i == 3) ? 60 : 0; // 60 kept for incubator batch

      await db.insertEggLog(
        EggLog(
          id: 'sample_egg_log_quail_$i',
          flockId: flock2.id,
          date: date,
          collectionTime: 'afternoon',
          totalEggs: quailTotal,
          crackedEggs: quailCracked,
          dirtyEggs: quailDirty,
          usableEggs: quailUsable - quailIncubation,
          keptForIncubation: quailIncubation,
          notes: 'Afternoon collection.',
          createdAt: date,
        ),
      );
    }

    // Egg Sales
    await db.insertEggSale(
      EggSale(
        id: 'sample_egg_sale_1',
        flockId: flock1.id,
        date: now.subtract(const Duration(days: 3)),
        quantity: 600, // 20 trays of 30 eggs
        unitPrice: 0.380, // DT per egg
        totalAmount: 228.0,
        buyerName: 'Supermarché Azur Mornag',
        paymentStatus: 'paid',
        amountPaid: 228.0,
        notes: 'Delivered in standard 30-egg trays.',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    );

    await db.insertEggSale(
      EggSale(
        id: 'sample_egg_sale_2',
        flockId: flock2.id,
        date: now.subtract(const Duration(days: 1)),
        quantity: 500,
        unitPrice: 0.200, // DT per quail egg
        totalAmount: 100.0,
        buyerName: 'Patisserie Les Délices',
        paymentStatus: 'paid',
        amountPaid: 100.0,
        notes: 'Packed in 18-pack quail egg cartons.',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    );

    // 6. Incubation Batch
    final incBatch = IncubationBatch(
      id: 'sample_inc_batch_1',
      flockId: flock2.id,
      species: 'quail',
      incubatorName: 'Covatutto 54 Automatic',
      setDate: now.subtract(const Duration(days: 14)),
      eggsSetCount: 60,
      eggUnitCost: 0.200,
      totalEggCost: 12.0,
      expectedHatchDate: now.add(
        const Duration(days: 3),
      ), // Day 17 of 17 (3 days remaining!)
      candlingDate: now.subtract(const Duration(days: 7)),
      fertileEggsCount: 54, // 90% fertility!
      durationDays: 17,
      status: 'incubating',
      extraCosts: 5.0, // electricity & disinfectant
      notes: 'Selected clean, standard-weight Coturnix eggs.',
      createdAt: now.subtract(const Duration(days: 14)),
    );
    await db.insertIncubationBatch(incBatch);

    await db.insertIncubationReading(
      IncubationReading(
        id: 'sample_inc_read_1',
        batchId: incBatch.id,
        dateTime: now.subtract(const Duration(hours: 4)),
        temperatureC: 37.6,
        humidityPercent: 55.0,
        turned: true,
        notes: 'Morning inspection - optimal temp & humidity.',
      ),
    );

    // 7. Vaccinations & Tasks
    await db.insertVaccination(
      VaccinationSchedule(
        id: 'sample_vax_1',
        flockId: flock1.id,
        vaccineName: 'Newcastle Disease (Clone 30) + IB',
        targetAgeDays: 70,
        targetDate: now.subtract(const Duration(days: 10)),
        administrationRoute: 'drinking_water',
        status: 'completed',
        completedDate: now.subtract(const Duration(days: 10)),
        notes: 'Administered with skim milk stabilizer in fresh water.',
        createdAt: now.subtract(const Duration(days: 30)),
      ),
    );

    await db.insertVaccination(
      VaccinationSchedule(
        id: 'sample_vax_2',
        flockId: flock1.id,
        vaccineName: 'Infectious Bursal Disease (Gumboro)',
        targetAgeDays: 90,
        targetDate: now.add(const Duration(days: 5)),
        administrationRoute: 'drinking_water',
        status: 'pending',
        notes: 'Prepare fresh clean water tanks 2 hours prior.',
        createdAt: now.subtract(const Duration(days: 30)),
      ),
    );

    // Daily Tasks
    await db.insertTask(
      TaskItem(
        id: 'sample_task_1',
        flockId: flock1.id,
        title: 'Morning Egg Collection & Shell Check',
        category: 'feeding',
        dueDate: now,
        dueTime: '09:00',
        isCompleted: true,
        completedAt: now.subtract(const Duration(hours: 3)),
        notes: 'Record cracked and dirty eggs separately.',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    );

    await db.insertTask(
      TaskItem(
        id: 'sample_task_2',
        flockId: flock2.id,
        title: 'Quail Drinker Bell Cleaning & Sanitation',
        category: 'cleaning',
        dueDate: now,
        dueTime: '14:30',
        isCompleted: false,
        notes: 'Clean algae and refill with fresh water.',
        createdAt: now,
      ),
    );

    await db.insertTask(
      TaskItem(
        id: 'sample_task_3',
        incubationId: incBatch.id,
        title: 'Stop Egg Turner & Increase Humidity to 70% (Lockdown)',
        category: 'incubation',
        dueDate: now.add(const Duration(days: 1)),
        dueTime: '10:00',
        isCompleted: false,
        notes:
            'Day 15 lockdown for quail eggs: remove turner grid and add water to both reservoir channels.',
        createdAt: now,
      ),
    );

    // 8. Equipment & Electricity
    await db.insertEquipment(
      EquipmentItem(
        id: 'sample_equip_incubator',
        name: 'Covatutto 54 Automatic Incubator',
        category: 'incubator',
        purchaseDate: now.subtract(const Duration(days: 120)),
        purchaseCost: 450.0,
        wattage: 140.0,
        dailyOperatingHours: 24.0,
        notes:
            'Equipped with digital temperature display and automatic turning motor.',
        createdAt: now.subtract(const Duration(days: 120)),
      ),
    );

    await db.insertEquipment(
      EquipmentItem(
        id: 'sample_equip_heater',
        name: 'Ceramic Heat Emitter 150W',
        category: 'brooder_heater',
        purchaseDate: now.subtract(const Duration(days: 80)),
        purchaseCost: 65.0,
        wattage: 150.0,
        dailyOperatingHours: 18.0,
        notes: 'For brooder heating during early chick growth.',
        createdAt: now.subtract(const Duration(days: 80)),
      ),
    );

    // Electricity reading
    await db.insertElectricityReading(
      ElectricityReading(
        id: 'sample_elec_1',
        date: now.subtract(const Duration(days: 10)),
        meterReadingKwh: 4850.0,
        kwhConsumed: 320.0,
        tariffPerKwh: 0.280,
        totalCost: 89.6,
        notes: 'STEG monthly power bill for coop lighting and incubators.',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
    );
  }
}
