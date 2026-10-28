import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../models/farm_settings.dart';
import '../../models/flock.dart';
import '../../models/bird_movement.dart';
import '../../models/feed.dart';
import '../../models/egg_record.dart';
import '../../models/incubation.dart';
import '../../models/task_item.dart';
import '../../models/vaccination.dart';
import '../../models/health_record.dart';
import '../../models/finance.dart';
import '../../models/electricity.dart';
import '../../models/article.dart';
import '../../models/poultry_product.dart';
import '../../models/sync_item.dart';
import '../../models/notification_campaign.dart';

class InsufficientFeedStockException implements Exception {
  final double availableStockKg;
  final double requestedKg;
  final String feedName;

  const InsufficientFeedStockException({
    required this.availableStockKg,
    required this.requestedKg,
    required this.feedName,
  });

  @override
  String toString() =>
      'Insufficient feed stock for "$feedName": Available ${availableStockKg.toStringAsFixed(2)} kg, requested ${requestedKg.toStringAsFixed(2)} kg.';
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('golden_roost.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // If running on desktop platforms (Windows/Linux/macOS), initialize FFI
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path;
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      final appDir = await getApplicationSupportDirectory();
      path = join(appDir.path, filePath);

      // Check if previous flockmate.db exists and migrate to golden_roost.db if needed
      final legacyPath = join(appDir.path, 'flockmate.db');
      if (!File(path).existsSync() && File(legacyPath).existsSync()) {
        try {
          File(legacyPath).copySync(path);
        } catch (_) {}
      }
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, filePath);

      // Check if previous flockmate.db exists and migrate to golden_roost.db if needed
      final legacyPath = join(dbPath, 'flockmate.db');
      if (!File(path).existsSync() && File(legacyPath).existsSync()) {
        try {
          File(legacyPath).copySync(path);
        } catch (_) {}
      }
    }

    final db = await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          try {
            await db.execute(
              "ALTER TABLE farm_settings ADD COLUMN theme_mode TEXT NOT NULL DEFAULT 'system';",
            );
          } catch (_) {}
        }
        if (oldVersion < 3) {
          try {
            await db.execute("ALTER TABLE flocks ADD COLUMN hatch_date TEXT;");
          } catch (_) {}
        }
        if (oldVersion < 4) {
          try {
            await db.execute(
              "ALTER TABLE farm_settings ADD COLUMN auto_feed_deduction INTEGER NOT NULL DEFAULT 0;",
            );
          } catch (_) {}
          try {
            await db.execute(
              "ALTER TABLE farm_settings ADD COLUMN article_notifications_enabled INTEGER NOT NULL DEFAULT 1;",
            );
          } catch (_) {}
          try {
            await db.execute(
              "ALTER TABLE farm_settings ADD COLUMN marketing_notifications_enabled INTEGER NOT NULL DEFAULT 0;",
            );
          } catch (_) {}
          try {
            await db.execute(
              "ALTER TABLE farm_settings ADD COLUMN ads_enabled INTEGER NOT NULL DEFAULT 1;",
            );
          } catch (_) {}
          try {
            await db.execute(
              "ALTER TABLE farm_settings ADD COLUMN cloud_sync_enabled INTEGER NOT NULL DEFAULT 0;",
            );
          } catch (_) {}
          try {
            await db.execute(
              "ALTER TABLE farm_settings ADD COLUMN last_sync_timestamp TEXT;",
            );
          } catch (_) {}
          try {
            await db.execute(
              "ALTER TABLE flocks ADD COLUMN start_male_count INTEGER NOT NULL DEFAULT 0;",
            );
          } catch (_) {}
          try {
            await db.execute(
              "ALTER TABLE flocks ADD COLUMN start_female_count INTEGER NOT NULL DEFAULT 0;",
            );
          } catch (_) {}
          try {
            await db.execute(
              "ALTER TABLE incubation_batches ADD COLUMN is_transferred INTEGER NOT NULL DEFAULT 0;",
            );
          } catch (_) {}
          try {
            await db.execute(
              "ALTER TABLE incubation_batches ADD COLUMN transferred_flock_id TEXT;",
            );
          } catch (_) {}

          await _createSyncAndContentTables(db);
        }
      },
    );

    // Safeguard column existence
    try {
      await db.execute("ALTER TABLE flocks ADD COLUMN hatch_date TEXT;");
    } catch (_) {}
    try {
      await db.execute(
        "ALTER TABLE farm_settings ADD COLUMN auto_feed_deduction INTEGER NOT NULL DEFAULT 0;",
      );
    } catch (_) {}
    try {
      await db.execute(
        "ALTER TABLE farm_settings ADD COLUMN article_notifications_enabled INTEGER NOT NULL DEFAULT 1;",
      );
    } catch (_) {}
    try {
      await db.execute(
        "ALTER TABLE farm_settings ADD COLUMN marketing_notifications_enabled INTEGER NOT NULL DEFAULT 0;",
      );
    } catch (_) {}
    try {
      await db.execute(
        "ALTER TABLE farm_settings ADD COLUMN ads_enabled INTEGER NOT NULL DEFAULT 1;",
      );
    } catch (_) {}
    try {
      await db.execute(
        "ALTER TABLE farm_settings ADD COLUMN cloud_sync_enabled INTEGER NOT NULL DEFAULT 0;",
      );
    } catch (_) {}
    try {
      await db.execute(
        "ALTER TABLE farm_settings ADD COLUMN last_sync_timestamp TEXT;",
      );
    } catch (_) {}
    try {
      await db.execute(
        "ALTER TABLE flocks ADD COLUMN start_male_count INTEGER NOT NULL DEFAULT 0;",
      );
    } catch (_) {}
    try {
      await db.execute(
        "ALTER TABLE flocks ADD COLUMN start_female_count INTEGER NOT NULL DEFAULT 0;",
      );
    } catch (_) {}
    try {
      await db.execute(
        "ALTER TABLE incubation_batches ADD COLUMN is_transferred INTEGER NOT NULL DEFAULT 0;",
      );
    } catch (_) {}
    try {
      await db.execute(
        "ALTER TABLE incubation_batches ADD COLUMN transferred_flock_id TEXT;",
      );
    } catch (_) {}

    await _createSyncAndContentTables(db);

    return db;
  }

  Future<void> _createDB(Database db, int version) async {
    // Settings Table
    await db.execute('''
      CREATE TABLE farm_settings (
        id INTEGER PRIMARY KEY,
        farm_name TEXT NOT NULL,
        currency TEXT NOT NULL,
        weight_unit TEXT NOT NULL,
        language TEXT NOT NULL,
        timezone TEXT NOT NULL,
        electricity_kwh_rate REAL NOT NULL,
        reminders_enabled INTEGER NOT NULL,
        reminder_time TEXT NOT NULL,
        theme_mode TEXT NOT NULL DEFAULT 'system',
        auto_feed_deduction INTEGER NOT NULL DEFAULT 0,
        article_notifications_enabled INTEGER NOT NULL DEFAULT 1,
        marketing_notifications_enabled INTEGER NOT NULL DEFAULT 0,
        ads_enabled INTEGER NOT NULL DEFAULT 1,
        cloud_sync_enabled INTEGER NOT NULL DEFAULT 0,
        last_sync_timestamp TEXT
      )
    ''');

    // Default settings
    await db.insert('farm_settings', const FarmSettings().toMap());

    // Flocks Table
    await db.execute('''
      CREATE TABLE flocks (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        species TEXT NOT NULL,
        breed TEXT NOT NULL,
        purpose TEXT NOT NULL,
        acquisition_date TEXT NOT NULL,
        hatch_date TEXT,
        start_count INTEGER NOT NULL,
        current_count INTEGER NOT NULL,
        male_count INTEGER NOT NULL,
        female_count INTEGER NOT NULL,
        start_male_count INTEGER NOT NULL DEFAULT 0,
        start_female_count INTEGER NOT NULL DEFAULT 0,
        purchase_price_per_bird REAL NOT NULL,
        total_purchase_cost REAL NOT NULL,
        supplier TEXT NOT NULL,
        housing_location TEXT NOT NULL,
        notes TEXT NOT NULL,
        is_archived INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Bird Movements Table
    await db.execute('''
      CREATE TABLE bird_movements (
        id TEXT PRIMARY KEY,
        flock_id TEXT NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        count INTEGER NOT NULL,
        male_count INTEGER NOT NULL,
        female_count INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        total_amount REAL NOT NULL,
        reason_or_buyer TEXT NOT NULL,
        notes TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (flock_id) REFERENCES flocks (id) ON DELETE CASCADE
      )
    ''');

    // Feed Inventory Table
    await db.execute('''
      CREATE TABLE feed_inventory (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        feed_type TEXT NOT NULL,
        current_stock_kg REAL NOT NULL,
        low_stock_threshold_kg REAL NOT NULL,
        bag_weight_kg REAL NOT NULL,
        cost_per_bag REAL NOT NULL,
        notes TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Feed Transactions Table
    await db.execute('''
      CREATE TABLE feed_transactions (
        id TEXT PRIMARY KEY,
        feed_id TEXT NOT NULL,
        flock_id TEXT,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        quantity_kg REAL NOT NULL,
        cost REAL NOT NULL,
        notes TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (feed_id) REFERENCES feed_inventory (id) ON DELETE CASCADE
      )
    ''');

    // Water & Care Logs Table
    await db.execute('''
      CREATE TABLE water_care_logs (
        id TEXT PRIMARY KEY,
        flock_id TEXT NOT NULL,
        date TEXT NOT NULL,
        water_consumed_liters REAL NOT NULL,
        water_check_completed INTEGER NOT NULL,
        equipment_cleaned INTEGER NOT NULL,
        observations TEXT NOT NULL,
        notes TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (flock_id) REFERENCES flocks (id) ON DELETE CASCADE
      )
    ''');

    // Tasks Table
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        flock_id TEXT,
        incubation_id TEXT,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        due_date TEXT NOT NULL,
        due_time TEXT,
        is_completed INTEGER NOT NULL,
        completed_at TEXT,
        recurrence TEXT NOT NULL,
        reminder_minutes_before INTEGER NOT NULL,
        notes TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Vaccination Schedules Table
    await db.execute('''
      CREATE TABLE vaccination_schedules (
        id TEXT PRIMARY KEY,
        flock_id TEXT NOT NULL,
        vaccine_name TEXT NOT NULL,
        target_age_days INTEGER NOT NULL,
        target_date TEXT NOT NULL,
        administration_route TEXT NOT NULL,
        status TEXT NOT NULL,
        completed_date TEXT,
        notes TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (flock_id) REFERENCES flocks (id) ON DELETE CASCADE
      )
    ''');

    // Health Records Table
    await db.execute('''
      CREATE TABLE health_records (
        id TEXT PRIMARY KEY,
        flock_id TEXT NOT NULL,
        date TEXT NOT NULL,
        symptom_or_diagnosis TEXT NOT NULL,
        birds_affected INTEGER NOT NULL,
        mortality_count INTEGER NOT NULL,
        treatment_administered TEXT NOT NULL,
        vet_name TEXT NOT NULL,
        cost REAL NOT NULL,
        notes TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (flock_id) REFERENCES flocks (id) ON DELETE CASCADE
      )
    ''');

    // Egg Logs Table
    await db.execute('''
      CREATE TABLE egg_logs (
        id TEXT PRIMARY KEY,
        flock_id TEXT NOT NULL,
        date TEXT NOT NULL,
        collection_time TEXT NOT NULL,
        total_eggs INTEGER NOT NULL,
        cracked_eggs INTEGER NOT NULL,
        dirty_eggs INTEGER NOT NULL,
        usable_eggs INTEGER NOT NULL,
        kept_for_incubation INTEGER NOT NULL,
        notes TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (flock_id) REFERENCES flocks (id) ON DELETE CASCADE
      )
    ''');

    // Egg Sales Table
    await db.execute('''
      CREATE TABLE egg_sales (
        id TEXT PRIMARY KEY,
        flock_id TEXT,
        date TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        total_amount REAL NOT NULL,
        buyer_name TEXT NOT NULL,
        payment_status TEXT NOT NULL,
        amount_paid REAL NOT NULL,
        notes TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Incubation Batches Table
    await db.execute('''
      CREATE TABLE incubation_batches (
        id TEXT PRIMARY KEY,
        flock_id TEXT,
        species TEXT NOT NULL,
        incubator_name TEXT NOT NULL,
        set_date TEXT NOT NULL,
        eggs_set_count INTEGER NOT NULL,
        egg_unit_cost REAL NOT NULL,
        total_egg_cost REAL NOT NULL,
        expected_hatch_date TEXT NOT NULL,
        candling_date TEXT,
        fertile_eggs_count INTEGER NOT NULL,
        hatched_count INTEGER NOT NULL,
        dead_in_shell_count INTEGER NOT NULL,
        culled_chicks_count INTEGER NOT NULL,
        duration_days INTEGER NOT NULL,
        status TEXT NOT NULL,
        extra_costs REAL NOT NULL,
        notes TEXT NOT NULL,
        is_transferred INTEGER NOT NULL DEFAULT 0,
        transferred_flock_id TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Incubation Readings Table
    await db.execute('''
      CREATE TABLE incubation_readings (
        id TEXT PRIMARY KEY,
        batch_id TEXT NOT NULL,
        date_time TEXT NOT NULL,
        temperature_c REAL NOT NULL,
        humidity_percent REAL NOT NULL,
        turned INTEGER NOT NULL,
        notes TEXT NOT NULL,
        FOREIGN KEY (batch_id) REFERENCES incubation_batches (id) ON DELETE CASCADE
      )
    ''');

    // Financial Transactions Table
    await db.execute('''
      CREATE TABLE finances (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        flock_id TEXT,
        incubation_id TEXT,
        equipment_id TEXT,
        is_capital_investment INTEGER NOT NULL,
        payment_status TEXT NOT NULL,
        amount_paid REAL NOT NULL,
        notes TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Equipment Table
    await db.execute('''
      CREATE TABLE equipment (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        purchase_date TEXT NOT NULL,
        purchase_cost REAL NOT NULL,
        wattage REAL NOT NULL,
        daily_operating_hours REAL NOT NULL,
        notes TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Electricity Readings Table
    await db.execute('''
      CREATE TABLE electricity_readings (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        meter_reading_kwh REAL NOT NULL,
        kwh_consumed REAL NOT NULL,
        tariff_per_kwh REAL NOT NULL,
        total_cost REAL NOT NULL,
        notes TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // ==================== Farm Settings ====================
  Future<FarmSettings> getSettings() async {
    final db = await database;
    final maps = await db.query(
      'farm_settings',
      where: 'id = ?',
      whereArgs: [1],
    );
    if (maps.isNotEmpty) {
      return FarmSettings.fromMap(maps.first);
    }
    const defaultSettings = FarmSettings();
    await db.insert('farm_settings', defaultSettings.toMap());
    return defaultSettings;
  }

  Future<void> updateSettings(FarmSettings settings) async {
    final db = await database;
    try {
      await db.update(
        'farm_settings',
        settings.toMap(),
        where: 'id = ?',
        whereArgs: [settings.id],
      );
    } catch (_) {
      try {
        await db.execute(
          "ALTER TABLE farm_settings ADD COLUMN theme_mode TEXT NOT NULL DEFAULT 'system';",
        );
        await db.update(
          'farm_settings',
          settings.toMap(),
          where: 'id = ?',
          whereArgs: [settings.id],
        );
      } catch (_) {}
    }
  }

  Future<bool> isOnboardingCompleted() async {
    final db = await database;
    try {
      final res = await db.rawQuery(
        "SELECT value FROM app_kv WHERE key = 'onboarding_completed'",
      );
      if (res.isNotEmpty) {
        return res.first['value'] == 'true';
      }
    } catch (_) {
      try {
        await db.execute(
          'CREATE TABLE IF NOT EXISTS app_kv (key TEXT PRIMARY KEY, value TEXT)',
        );
      } catch (_) {}
    }
    return false;
  }

  Future<void> setOnboardingCompleted() async {
    final db = await database;
    try {
      await db.execute(
        'CREATE TABLE IF NOT EXISTS app_kv (key TEXT PRIMARY KEY, value TEXT)',
      );
      await db.rawInsert(
        "INSERT OR REPLACE INTO app_kv (key, value) VALUES ('onboarding_completed', 'true')",
      );
    } catch (_) {}
  }

  // ==================== Flocks ====================
  Future<List<Flock>> getFlocks({bool includeArchived = false}) async {
    final db = await database;
    final where = includeArchived ? null : 'is_archived = 0';
    final result = await db.query(
      'flocks',
      where: where,
      orderBy: 'acquisition_date DESC',
    );
    return result.map((e) => Flock.fromMap(e)).toList();
  }

  Future<Flock?> getFlockById(String id) async {
    final db = await database;
    final result = await db.query('flocks', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) return Flock.fromMap(result.first);
    return null;
  }

  Future<void> insertFlock(Flock flock) async {
    final db = await database;
    await db.insert(
      'flocks',
      flock.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateFlock(Flock flock) async {
    final db = await database;
    await db.update(
      'flocks',
      flock.toMap(),
      where: 'id = ?',
      whereArgs: [flock.id],
    );
  }

  Future<void> deleteFlock(String id) async {
    final db = await database;
    await db.delete('flocks', where: 'id = ?', whereArgs: [id]);
  }

  // Recalculates live bird count deterministically based on starting counts and all bird movements
  Future<int> recalculateFlockCount(String flockId) async {
    final flock = await getFlockById(flockId);
    if (flock == null) return 0;

    final movements = await getBirdMovements(flockId);
    int count = flock.startCount;
    int males = flock.startMaleCount;
    int females = flock.startFemaleCount;

    for (final m in movements) {
      if (m.isAddition) {
        count += m.count;
        males += m.maleCount;
        females += m.femaleCount;
      } else if (m.isReduction) {
        count -= m.count;
        males -= m.maleCount;
        females -= m.femaleCount;
      }
    }

    if (count < 0) count = 0;
    if (males < 0) males = 0;
    if (females < 0) females = 0;
    if (males > count) males = count;
    if (females > count) females = count;
    if (males + females > count) {
      females = (count - males).clamp(0, count);
    }

    final updated = flock.copyWith(
      currentCount: count,
      maleCount: males,
      femaleCount: females,
    );
    await updateFlock(updated);
    return count;
  }

  // ==================== Bird Movements ====================
  Future<List<BirdMovement>> getBirdMovements(String flockId) async {
    final db = await database;
    final result = await db.query(
      'bird_movements',
      where: 'flock_id = ?',
      whereArgs: [flockId],
      orderBy: 'date DESC',
    );
    return result.map((e) => BirdMovement.fromMap(e)).toList();
  }

  Future<void> insertBirdMovement(BirdMovement movement) async {
    final db = await database;
    await db.insert('bird_movements', movement.toMap());
    await recalculateFlockCount(movement.flockId);

    // If movement is a sale, also record income in finances
    if (movement.type == 'sale' && movement.totalAmount > 0) {
      await insertFinance(
        FinancialTransaction(
          id: 'fin_bird_sale_${movement.id}',
          type: 'income',
          category: 'sales_birds',
          amount: movement.totalAmount,
          date: movement.date,
          flockId: movement.flockId,
          paymentStatus: 'paid',
          amountPaid: movement.totalAmount,
          notes:
              'Bird sale: ${movement.count} birds (${movement.reasonOrBuyer})',
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> deleteBirdMovement(String id, String flockId) async {
    final db = await database;
    await db.delete('bird_movements', where: 'id = ?', whereArgs: [id]);
    await recalculateFlockCount(flockId);
  }

  // ==================== Feed ====================
  Future<List<FeedItem>> getFeedInventory() async {
    final db = await database;
    final result = await db.query('feed_inventory', orderBy: 'name ASC');
    return result.map((e) => FeedItem.fromMap(e)).toList();
  }

  Future<void> insertFeedItem(FeedItem item) async {
    final db = await database;
    await db.insert(
      'feed_inventory',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateFeedItem(FeedItem item) async {
    final db = await database;
    await db.update(
      'feed_inventory',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteFeedItem(String id) async {
    final db = await database;
    await db.delete('feed_inventory', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<FeedTransaction>> getFeedTransactions({
    String? feedId,
    String? flockId,
  }) async {
    final db = await database;
    String? where;
    List<dynamic>? whereArgs;

    if (feedId != null && flockId != null) {
      where = 'feed_id = ? AND flock_id = ?';
      whereArgs = [feedId, flockId];
    } else if (feedId != null) {
      where = 'feed_id = ?';
      whereArgs = [feedId];
    } else if (flockId != null) {
      where = 'flock_id = ?';
      whereArgs = [flockId];
    }

    final result = await db.query(
      'feed_transactions',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );
    return result.map((e) => FeedTransaction.fromMap(e)).toList();
  }

  Future<void> recordFeedTransaction(FeedTransaction tx) async {
    final db = await database;
    await db.transaction((txn) async {
      // Idempotency check: If transaction ID already exists, do not re-apply stock changes
      final existingTx = await txn.query(
        'feed_transactions',
        where: 'id = ?',
        whereArgs: [tx.id],
        limit: 1,
      );
      if (existingTx.isNotEmpty) {
        return;
      }

      // Check stock in feed_inventory
      final items = await txn.query(
        'feed_inventory',
        where: 'id = ?',
        whereArgs: [tx.feedId],
      );
      if (items.isNotEmpty) {
        final item = FeedItem.fromMap(items.first);
        double newStock = item.currentStockKg;
        if (tx.type == 'purchase') {
          newStock += tx.quantityKg;
        } else if (tx.type == 'consumption') {
          if (newStock < tx.quantityKg) {
            throw InsufficientFeedStockException(
              availableStockKg: newStock,
              requestedKg: tx.quantityKg,
              feedName: item.name,
            );
          }
          newStock -= tx.quantityKg;
        } else if (tx.type == 'adjustment') {
          newStock = tx.quantityKg;
        }

        await txn.update(
          'feed_inventory',
          item
              .copyWith(currentStockKg: newStock, updatedAt: DateTime.now())
              .toMap(),
          where: 'id = ?',
          whereArgs: [item.id],
        );
      }

      await txn.insert(
        'feed_transactions',
        tx.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // If purchase and cost > 0, record expense
      if (tx.type == 'purchase' && tx.cost > 0) {
        final finance = FinancialTransaction(
          id: 'fin_feed_${tx.id}',
          type: 'expense',
          category: 'feed',
          amount: tx.cost,
          date: tx.date,
          flockId: tx.flockId,
          paymentStatus: 'paid',
          amountPaid: tx.cost,
          notes: 'Feed restock: ${tx.quantityKg} kg',
          createdAt: DateTime.now(),
        );
        await txn.insert(
          'finances',
          finance.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> deleteFeedTransaction(String txId) async {
    final db = await database;
    await db.transaction((txn) async {
      final results = await txn.query(
        'feed_transactions',
        where: 'id = ?',
        whereArgs: [txId],
      );
      if (results.isEmpty) return;

      final tx = FeedTransaction.fromMap(results.first);

      // Reverse stock in feed_inventory
      final items = await txn.query(
        'feed_inventory',
        where: 'id = ?',
        whereArgs: [tx.feedId],
      );
      if (items.isNotEmpty) {
        final item = FeedItem.fromMap(items.first);
        double newStock = item.currentStockKg;
        if (tx.type == 'purchase') {
          newStock -= tx.quantityKg;
          if (newStock < 0) newStock = 0;
        } else if (tx.type == 'consumption') {
          newStock += tx.quantityKg;
        }
        await txn.update(
          'feed_inventory',
          item
              .copyWith(currentStockKg: newStock, updatedAt: DateTime.now())
              .toMap(),
          where: 'id = ?',
          whereArgs: [item.id],
        );
      }

      // Delete associated financial expense if purchase
      await txn.delete(
        'finances',
        where: 'id = ?',
        whereArgs: ['fin_feed_$txId'],
      );

      // Delete from feed_transactions
      await txn.delete('feed_transactions', where: 'id = ?', whereArgs: [txId]);
    });
  }

  Future<void> updateFeedTransaction(
    FeedTransaction tx,
    double oldQuantityKg,
    double oldCost,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        'feed_transactions',
        tx.toMap(),
        where: 'id = ?',
        whereArgs: [tx.id],
      );

      // Adjust stock in feed_inventory
      final items = await txn.query(
        'feed_inventory',
        where: 'id = ?',
        whereArgs: [tx.feedId],
      );
      if (items.isNotEmpty) {
        final item = FeedItem.fromMap(items.first);
        double newStock = item.currentStockKg;
        if (tx.type == 'purchase') {
          newStock = (newStock - oldQuantityKg) + tx.quantityKg;
          if (newStock < 0) newStock = 0;
        } else if (tx.type == 'consumption') {
          final available = newStock + oldQuantityKg;
          if (available < tx.quantityKg) {
            throw InsufficientFeedStockException(
              availableStockKg: available,
              requestedKg: tx.quantityKg,
              feedName: item.name,
            );
          }
          newStock = available - tx.quantityKg;
        }
        await txn.update(
          'feed_inventory',
          item
              .copyWith(currentStockKg: newStock, updatedAt: DateTime.now())
              .toMap(),
          where: 'id = ?',
          whereArgs: [item.id],
        );
      }

      // Update associated finance if purchase
      if (tx.type == 'purchase') {
        if (tx.cost > 0) {
          final finance = FinancialTransaction(
            id: 'fin_feed_${tx.id}',
            type: 'expense',
            category: 'feed',
            amount: tx.cost,
            date: tx.date,
            flockId: tx.flockId,
            paymentStatus: 'paid',
            amountPaid: tx.cost,
            notes: 'Feed restock: ${tx.quantityKg} kg',
            createdAt: DateTime.now(),
          );
          await txn.insert(
            'finances',
            finance.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        } else {
          await txn.delete(
            'finances',
            where: 'id = ?',
            whereArgs: ['fin_feed_${tx.id}'],
          );
        }
      }
    });
  }

  // Water & Care Logs
  Future<List<WaterCareLog>> getWaterCareLogs(String flockId) async {
    final db = await database;
    final result = await db.query(
      'water_care_logs',
      where: 'flock_id = ?',
      whereArgs: [flockId],
      orderBy: 'date DESC',
    );
    return result.map((e) => WaterCareLog.fromMap(e)).toList();
  }

  Future<void> insertWaterCareLog(WaterCareLog log) async {
    final db = await database;
    await db.insert(
      'water_care_logs',
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ==================== Egg Logs & Sales ====================
  Future<List<EggLog>> getEggLogs({
    String? flockId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    String? where;
    List<dynamic> whereArgs = [];

    if (flockId != null) {
      where = 'flock_id = ?';
      whereArgs.add(flockId);
    }

    final result = await db.query(
      'egg_logs',
      where: where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'date DESC',
    );

    var list = result.map((e) => EggLog.fromMap(e)).toList();
    if (startDate != null) {
      list = list
          .where(
            (e) =>
                e.date.isAfter(startDate.subtract(const Duration(seconds: 1))),
          )
          .toList();
    }
    if (endDate != null) {
      list = list
          .where((e) => e.date.isBefore(endDate.add(const Duration(days: 1))))
          .toList();
    }
    return list;
  }

  Future<void> insertEggLog(EggLog log) async {
    final db = await database;
    await db.insert('egg_logs', log.toMap());
  }

  Future<void> updateEggLog(EggLog log) async {
    final db = await database;
    await db.update(
      'egg_logs',
      log.toMap(),
      where: 'id = ?',
      whereArgs: [log.id],
    );
  }

  Future<void> deleteEggLog(String id) async {
    final db = await database;
    await db.delete('egg_logs', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<EggSale>> getEggSales() async {
    final db = await database;
    final result = await db.query('egg_sales', orderBy: 'date DESC');
    return result.map((e) => EggSale.fromMap(e)).toList();
  }

  Future<void> insertEggSale(EggSale sale) async {
    final db = await database;
    await db.insert('egg_sales', sale.toMap());

    // Also record income in finances
    await insertFinance(
      FinancialTransaction(
        id: 'fin_egg_sale_${sale.id}',
        type: 'income',
        category: 'sales_eggs',
        amount: sale.totalAmount,
        date: sale.date,
        flockId: sale.flockId,
        paymentStatus: sale.paymentStatus,
        amountPaid: sale.amountPaid,
        notes: 'Egg sale: ${sale.quantity} eggs to ${sale.buyerName}',
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> deleteEggSale(String id) async {
    final db = await database;
    await db.delete('egg_sales', where: 'id = ?', whereArgs: [id]);
    await db.delete(
      'finances',
      where: 'id = ?',
      whereArgs: ['fin_egg_sale_$id'],
    );
  }

  // ==================== Incubator ====================
  Future<List<IncubationBatch>> getIncubationBatches({
    bool activeOnly = false,
  }) async {
    final db = await database;
    final where = activeOnly ? "status = 'incubating'" : null;
    final result = await db.query(
      'incubation_batches',
      where: where,
      orderBy: 'set_date DESC',
    );
    return result.map((e) => IncubationBatch.fromMap(e)).toList();
  }

  Future<IncubationBatch?> getIncubationBatchById(String id) async {
    final db = await database;
    final result = await db.query(
      'incubation_batches',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) return IncubationBatch.fromMap(result.first);
    return null;
  }

  Future<void> insertIncubationBatch(IncubationBatch batch) async {
    final db = await database;
    await db.insert('incubation_batches', batch.toMap());

    // Record expense for eggs set if cost > 0
    if (batch.totalEggCost > 0) {
      await insertFinance(
        FinancialTransaction(
          id: 'fin_inc_batch_${batch.id}',
          type: 'expense',
          category: 'incubators',
          amount: batch.totalEggCost,
          date: batch.setDate,
          incubationId: batch.id,
          paymentStatus: 'paid',
          amountPaid: batch.totalEggCost,
          notes:
              'Incubation eggs: ${batch.eggsSetCount} eggs (${batch.species})',
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> updateIncubationBatch(IncubationBatch batch) async {
    final db = await database;
    await db.update(
      'incubation_batches',
      batch.toMap(),
      where: 'id = ?',
      whereArgs: [batch.id],
    );
  }

  Future<void> deleteIncubationBatch(String id) async {
    final db = await database;
    await db.delete('incubation_batches', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<IncubationReading>> getIncubationReadings(String batchId) async {
    final db = await database;
    final result = await db.query(
      'incubation_readings',
      where: 'batch_id = ?',
      whereArgs: [batchId],
      orderBy: 'date_time DESC',
    );
    return result.map((e) => IncubationReading.fromMap(e)).toList();
  }

  Future<void> insertIncubationReading(IncubationReading reading) async {
    final db = await database;
    await db.insert('incubation_readings', reading.toMap());
  }

  // ==================== Tasks & Calendar ====================
  Future<List<TaskItem>> getTasks({
    DateTime? start,
    DateTime? end,
    bool? isCompleted,
  }) async {
    final db = await database;
    String? where;
    List<dynamic> whereArgs = [];

    if (isCompleted != null) {
      where = 'is_completed = ?';
      whereArgs.add(isCompleted ? 1 : 0);
    }

    final result = await db.query(
      'tasks',
      where: where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'due_date ASC',
    );

    var list = result.map((e) => TaskItem.fromMap(e)).toList();
    if (start != null) {
      list = list.where((t) => !t.dueDate.isBefore(start)).toList();
    }
    if (end != null) {
      list = list.where((t) => !t.dueDate.isAfter(end)).toList();
    }
    return list;
  }

  Future<void> insertTask(TaskItem task) async {
    final db = await database;
    await db.insert('tasks', task.toMap());
  }

  Future<void> updateTask(TaskItem task) async {
    final db = await database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== Vaccinations & Health ====================
  Future<List<VaccinationSchedule>> getVaccinations({String? flockId}) async {
    final db = await database;
    final result = await db.query(
      'vaccination_schedules',
      where: flockId != null ? 'flock_id = ?' : null,
      whereArgs: flockId != null ? [flockId] : null,
      orderBy: 'target_date ASC',
    );
    return result.map((e) => VaccinationSchedule.fromMap(e)).toList();
  }

  Future<void> insertVaccination(VaccinationSchedule vax) async {
    final db = await database;
    await db.insert('vaccination_schedules', vax.toMap());
  }

  Future<void> updateVaccination(VaccinationSchedule vax) async {
    final db = await database;
    await db.update(
      'vaccination_schedules',
      vax.toMap(),
      where: 'id = ?',
      whereArgs: [vax.id],
    );
  }

  Future<void> deleteVaccination(String id) async {
    final db = await database;
    await db.delete('vaccination_schedules', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<HealthRecord>> getHealthRecords({String? flockId}) async {
    final db = await database;
    final result = await db.query(
      'health_records',
      where: flockId != null ? 'flock_id = ?' : null,
      whereArgs: flockId != null ? [flockId] : null,
      orderBy: 'date DESC',
    );
    return result.map((e) => HealthRecord.fromMap(e)).toList();
  }

  Future<void> insertHealthRecord(HealthRecord record) async {
    final db = await database;
    await db.insert('health_records', record.toMap());

    // If cost > 0, record health expense
    if (record.cost > 0) {
      await insertFinance(
        FinancialTransaction(
          id: 'fin_health_${record.id}',
          type: 'expense',
          category: 'medicines',
          amount: record.cost,
          date: record.date,
          flockId: record.flockId,
          paymentStatus: 'paid',
          amountPaid: record.cost,
          notes:
              'Health treatment: ${record.symptomOrDiagnosis} (${record.treatmentAdministered})',
          createdAt: DateTime.now(),
        ),
      );
    }

    // If mortality occurred in health record, record bird movement
    if (record.mortalityCount > 0) {
      await insertBirdMovement(
        BirdMovement(
          id: 'mov_health_${record.id}',
          flockId: record.flockId,
          date: record.date,
          type: 'mortality',
          count: record.mortalityCount,
          reasonOrBuyer: record.symptomOrDiagnosis,
          notes: 'Health incident mortality: ${record.treatmentAdministered}',
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  // ==================== Finances ====================
  Future<List<FinancialTransaction>> getFinances({
    String? flockId,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    String? where;
    List<dynamic> whereArgs = [];

    if (flockId != null) {
      where = 'flock_id = ?';
      whereArgs.add(flockId);
    }
    if (type != null) {
      where = (where == null) ? 'type = ?' : '$where AND type = ?';
      whereArgs.add(type);
    }

    final result = await db.query(
      'finances',
      where: where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'date DESC',
    );

    var list = result.map((e) => FinancialTransaction.fromMap(e)).toList();
    if (startDate != null) {
      list = list.where((f) => !f.date.isBefore(startDate)).toList();
    }
    if (endDate != null) {
      list = list.where((f) => !f.date.isAfter(endDate)).toList();
    }
    return list;
  }

  Future<void> insertFinance(FinancialTransaction tx) async {
    final db = await database;
    await db.insert(
      'finances',
      tx.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateFinance(FinancialTransaction tx) async {
    final db = await database;
    await db.update(
      'finances',
      tx.toMap(),
      where: 'id = ?',
      whereArgs: [tx.id],
    );
  }

  Future<void> deleteFinance(String id) async {
    final db = await database;
    await db.delete('finances', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== Electricity & Equipment ====================
  Future<List<ElectricityReading>> getElectricityReadings() async {
    final db = await database;
    final result = await db.query('electricity_readings', orderBy: 'date DESC');
    return result.map((e) => ElectricityReading.fromMap(e)).toList();
  }

  Future<void> insertElectricityReading(ElectricityReading reading) async {
    final db = await database;
    await db.insert('electricity_readings', reading.toMap());

    // Also record electricity cost in finances
    if (reading.totalCost > 0) {
      await insertFinance(
        FinancialTransaction(
          id: 'fin_elec_${reading.id}',
          type: 'expense',
          category: 'electricity',
          amount: reading.totalCost,
          date: reading.date,
          paymentStatus: 'paid',
          amountPaid: reading.totalCost,
          notes:
              'Electricity bill: ${reading.kwhConsumed.toStringAsFixed(1)} kWh',
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  Future<List<EquipmentItem>> getEquipment() async {
    final db = await database;
    final result = await db.query('equipment', orderBy: 'purchase_date DESC');
    return result.map((e) => EquipmentItem.fromMap(e)).toList();
  }

  Future<void> insertEquipment(EquipmentItem item) async {
    final db = await database;
    await db.insert('equipment', item.toMap());

    // Record capital investment expense
    if (item.purchaseCost > 0) {
      await insertFinance(
        FinancialTransaction(
          id: 'fin_equip_${item.id}',
          type: 'expense',
          category: 'equipment',
          amount: item.purchaseCost,
          date: item.purchaseDate,
          equipmentId: item.id,
          isCapitalInvestment: true,
          paymentStatus: 'paid',
          amountPaid: item.purchaseCost,
          notes: 'Equipment purchase: ${item.name}',
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  // ==================== Backup & Restore ====================
  Future<Map<String, dynamic>> exportAllDataAsJson() async {
    final db = await database;
    return {
      'exported_at': DateTime.now().toIso8601String(),
      'version': 1,
      'farm_settings': await db.query('farm_settings'),
      'flocks': await db.query('flocks'),
      'bird_movements': await db.query('bird_movements'),
      'feed_inventory': await db.query('feed_inventory'),
      'feed_transactions': await db.query('feed_transactions'),
      'water_care_logs': await db.query('water_care_logs'),
      'tasks': await db.query('tasks'),
      'vaccination_schedules': await db.query('vaccination_schedules'),
      'health_records': await db.query('health_records'),
      'egg_logs': await db.query('egg_logs'),
      'egg_sales': await db.query('egg_sales'),
      'incubation_batches': await db.query('incubation_batches'),
      'incubation_readings': await db.query('incubation_readings'),
      'finances': await db.query('finances'),
      'equipment': await db.query('equipment'),
      'electricity_readings': await db.query('electricity_readings'),
    };
  }

  Future<void> restoreFromJson(Map<String, dynamic> json) async {
    final db = await database;
    await db.transaction((txn) async {
      final tables = [
        'electricity_readings',
        'equipment',
        'finances',
        'incubation_readings',
        'incubation_batches',
        'egg_sales',
        'egg_logs',
        'health_records',
        'vaccination_schedules',
        'tasks',
        'water_care_logs',
        'feed_transactions',
        'feed_inventory',
        'bird_movements',
        'flocks',
        'farm_settings',
      ];

      for (final table in tables) {
        if (json.containsKey(table) && json[table] is List) {
          await txn.delete(table);
          for (final row in json[table]) {
            await txn.insert(table, Map<String, dynamic>.from(row as Map));
          }
        }
      }
    });
  }

  // ==================== Clear Sample Data ====================
  Future<void> clearSampleData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        'electricity_readings',
        where: 'id LIKE ?',
        whereArgs: ['sample_%'],
      );
      await txn.delete(
        'equipment',
        where: 'id LIKE ?',
        whereArgs: ['sample_%'],
      );
      await txn.delete('finances', where: 'id LIKE ?', whereArgs: ['sample_%']);
      await txn.delete(
        'incubation_readings',
        where: 'id LIKE ?',
        whereArgs: ['sample_%'],
      );
      await txn.delete(
        'incubation_batches',
        where: 'id LIKE ?',
        whereArgs: ['sample_%'],
      );
      await txn.delete(
        'egg_sales',
        where: 'id LIKE ?',
        whereArgs: ['sample_%'],
      );
      await txn.delete('egg_logs', where: 'id LIKE ?', whereArgs: ['sample_%']);
      await txn.delete(
        'health_records',
        where: 'id LIKE ?',
        whereArgs: ['sample_%'],
      );
      await txn.delete(
        'vaccination_schedules',
        where: 'id LIKE ?',
        whereArgs: ['sample_%'],
      );
      await txn.delete('tasks', where: 'id LIKE ?', whereArgs: ['sample_%']);
      await txn.delete(
        'water_care_logs',
        where: 'id LIKE ?',
        whereArgs: ['sample_%'],
      );
      await txn.delete(
        'feed_transactions',
        where: 'id LIKE ?',
        whereArgs: ['sample_%'],
      );
      await txn.delete(
        'feed_inventory',
        where: 'id LIKE ?',
        whereArgs: ['sample_%'],
      );
      await txn.delete(
        'bird_movements',
        where: 'id LIKE ?',
        whereArgs: ['sample_%'],
      );
      await txn.delete('flocks', where: 'id LIKE ?', whereArgs: ['sample_%']);
    });
  }

  // ==================== Clear All Farm Data (Clean State) ====================
  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('electricity_readings');
      await txn.delete('equipment');
      await txn.delete('finances');
      await txn.delete('incubation_readings');
      await txn.delete('incubation_batches');
      await txn.delete('egg_sales');
      await txn.delete('egg_logs');
      await txn.delete('health_records');
      await txn.delete('vaccination_schedules');
      await txn.delete('tasks');
      await txn.delete('water_care_logs');
      await txn.delete('feed_transactions');
      await txn.delete('feed_inventory');
      await txn.delete('bird_movements');
      await txn.delete('flocks');
      await txn.delete('sync_outbox');
      await txn.delete('sync_tombstones');
    });
  }

  // ==================== Sync and Content Tables ====================
  Future<void> _createSyncAndContentTables(DatabaseExecutor db) async {
    // Sync Outbox Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_outbox (
        id TEXT PRIMARY KEY,
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        action TEXT NOT NULL,
        payload TEXT NOT NULL,
        idempotency_key TEXT UNIQUE NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        attempts INTEGER NOT NULL DEFAULT 0,
        last_attempt TEXT,
        error_message TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Sync Tombstones Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_tombstones (
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        deleted_at TEXT NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (table_name, record_id)
      )
    ''');

    // Articles Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS articles (
        id TEXT PRIMARY KEY,
        slug TEXT UNIQUE NOT NULL,
        title_en TEXT NOT NULL,
        title_fr TEXT NOT NULL,
        title_ar TEXT NOT NULL,
        summary_en TEXT NOT NULL,
        summary_fr TEXT NOT NULL,
        summary_ar TEXT NOT NULL,
        body_en TEXT NOT NULL,
        body_fr TEXT NOT NULL,
        body_ar TEXT NOT NULL,
        category TEXT NOT NULL,
        tags TEXT NOT NULL DEFAULT '',
        image_url TEXT,
        author TEXT NOT NULL,
        reviewer TEXT,
        reading_time_minutes INTEGER NOT NULL DEFAULT 5,
        references_text TEXT,
        disclaimer TEXT,
        is_published INTEGER NOT NULL DEFAULT 1,
        is_featured INTEGER NOT NULL DEFAULT 0,
        published_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Poultry Products Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS poultry_products (
        id TEXT PRIMARY KEY,
        category TEXT NOT NULL,
        name_en TEXT NOT NULL,
        name_fr TEXT NOT NULL,
        name_ar TEXT NOT NULL,
        description_en TEXT NOT NULL,
        description_fr TEXT NOT NULL,
        description_ar TEXT NOT NULL,
        image_url TEXT,
        merchant_name TEXT NOT NULL,
        price REAL NOT NULL DEFAULT 0.0,
        currency TEXT NOT NULL DEFAULT 'USD',
        price_verified_date TEXT,
        target_url TEXT NOT NULL,
        affiliate_url TEXT,
        commercial_disclosure TEXT NOT NULL,
        is_featured INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        display_order INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Notification Campaigns Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS notification_campaigns (
        id TEXT PRIMARY KEY,
        title_en TEXT NOT NULL,
        title_fr TEXT NOT NULL,
        title_ar TEXT NOT NULL,
        body_en TEXT NOT NULL,
        body_fr TEXT NOT NULL,
        body_ar TEXT NOT NULL,
        campaign_type TEXT NOT NULL,
        destination_type TEXT NOT NULL,
        destination_id TEXT,
        audience_filter TEXT NOT NULL DEFAULT 'all',
        status TEXT NOT NULL DEFAULT 'draft',
        sent_count INTEGER NOT NULL DEFAULT 0,
        scheduled_at TEXT,
        sent_at TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Admin Audit Logs Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS admin_audit_logs (
        id TEXT PRIMARY KEY,
        action TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        performed_by TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        details TEXT
      )
    ''');
  }

  // ==================== Articles CRUD ====================
  Future<List<Article>> getArticles({
    String? category,
    bool? onlyPublished,
  }) async {
    final db = await database;
    String? where;
    List<dynamic>? whereArgs;

    if (category != null && onlyPublished == true) {
      where = 'category = ? AND is_published = 1';
      whereArgs = [category];
    } else if (category != null) {
      where = 'category = ?';
      whereArgs = [category];
    } else if (onlyPublished == true) {
      where = 'is_published = 1';
    }

    final maps = await db.query(
      'articles',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'is_featured DESC, published_at DESC',
    );
    return maps.map((m) => Article.fromMap(m)).toList();
  }

  Future<Article?> getArticleById(String id) async {
    final db = await database;
    final maps = await db.query('articles', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Article.fromMap(maps.first);
  }

  Future<Article?> getArticleBySlug(String slug) async {
    final db = await database;
    final maps = await db.query(
      'articles',
      where: 'slug = ?',
      whereArgs: [slug],
    );
    if (maps.isEmpty) return null;
    return Article.fromMap(maps.first);
  }

  Future<void> insertArticle(Article article) async {
    final db = await database;
    await db.insert(
      'articles',
      article.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateArticle(Article article) async {
    final db = await database;
    await db.update(
      'articles',
      article.toMap(),
      where: 'id = ?',
      whereArgs: [article.id],
    );
  }

  Future<void> deleteArticle(String id) async {
    final db = await database;
    await db.delete('articles', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== Poultry Products CRUD ====================
  Future<List<PoultryProduct>> getPoultryProducts({
    String? category,
    bool? onlyActive,
  }) async {
    final db = await database;
    String? where;
    List<dynamic>? whereArgs;

    if (category != null && onlyActive == true) {
      where = 'category = ? AND is_active = 1';
      whereArgs = [category];
    } else if (category != null) {
      where = 'category = ?';
      whereArgs = [category];
    } else if (onlyActive == true) {
      where = 'is_active = 1';
    }

    final maps = await db.query(
      'poultry_products',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'is_featured DESC, display_order ASC, created_at DESC',
    );
    return maps.map((m) => PoultryProduct.fromMap(m)).toList();
  }

  Future<PoultryProduct?> getPoultryProductById(String id) async {
    final db = await database;
    final maps = await db.query(
      'poultry_products',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return PoultryProduct.fromMap(maps.first);
  }

  Future<void> insertPoultryProduct(PoultryProduct product) async {
    final db = await database;
    await db.insert(
      'poultry_products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updatePoultryProduct(PoultryProduct product) async {
    final db = await database;
    await db.update(
      'poultry_products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<void> deletePoultryProduct(String id) async {
    final db = await database;
    await db.delete('poultry_products', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== Sync Outbox & Tombstones ====================
  Future<List<SyncItem>> getPendingSyncItems() async {
    final db = await database;
    final maps = await db.query(
      'sync_outbox',
      where: "status = 'pending' OR status = 'failed'",
      orderBy: 'created_at ASC',
    );
    return maps.map((m) => SyncItem.fromMap(m)).toList();
  }

  Future<void> queueSyncItem(SyncItem item) async {
    final db = await database;
    await db.insert(
      'sync_outbox',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateSyncItem(SyncItem item) async {
    final db = await database;
    await db.update(
      'sync_outbox',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteSyncItem(String id) async {
    final db = await database;
    await db.delete('sync_outbox', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> recordTombstone(SyncTombstone tombstone) async {
    final db = await database;
    await db.insert(
      'sync_tombstones',
      tombstone.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SyncTombstone>> getPendingTombstones() async {
    final db = await database;
    final maps = await db.query(
      'sync_tombstones',
      where: 'synced = 0',
      orderBy: 'deleted_at ASC',
    );
    return maps.map((m) => SyncTombstone.fromMap(m)).toList();
  }

  Future<void> markTombstoneSynced(String tableName, String recordId) async {
    final db = await database;
    await db.update(
      'sync_tombstones',
      {'synced': 1},
      where: 'table_name = ? AND record_id = ?',
      whereArgs: [tableName, recordId],
    );
  }

  // ==================== Notification Campaigns CRUD ====================
  Future<List<NotificationCampaign>> getNotificationCampaigns() async {
    final db = await database;
    final maps = await db.query(
      'notification_campaigns',
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => NotificationCampaign.fromMap(m)).toList();
  }

  Future<NotificationCampaign?> getNotificationCampaignById(String id) async {
    final db = await database;
    final maps = await db.query(
      'notification_campaigns',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return NotificationCampaign.fromMap(maps.first);
  }

  Future<void> insertNotificationCampaign(NotificationCampaign campaign) async {
    final db = await database;
    await db.insert(
      'notification_campaigns',
      campaign.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateNotificationCampaign(NotificationCampaign campaign) async {
    final db = await database;
    await db.update(
      'notification_campaigns',
      campaign.toMap(),
      where: 'id = ?',
      whereArgs: [campaign.id],
    );
  }

  Future<void> deleteNotificationCampaign(String id) async {
    final db = await database;
    await db.delete('notification_campaigns', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== Admin Audit Logs ====================
  Future<void> insertAuditLog({
    required String action,
    required String entityType,
    required String entityId,
    required String performedBy,
    String? details,
  }) async {
    final db = await database;
    await db.insert('admin_audit_logs', {
      'id':
          'audit_${DateTime.now().millisecondsSinceEpoch}_${entityId.hashCode}',
      'action': action,
      'entity_type': entityType,
      'entity_id': entityId,
      'performed_by': performedBy,
      'timestamp': DateTime.now().toIso8601String(),
      'details': details,
    });
  }

  Future<List<Map<String, dynamic>>> getAuditLogs({int limit = 100}) async {
    final db = await database;
    return await db.query(
      'admin_audit_logs',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
  }
}
