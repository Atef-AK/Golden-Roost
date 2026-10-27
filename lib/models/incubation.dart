class IncubationBatch {
  final String id;
  final String? flockId;
  final String species; // chicken, quail, duck, etc.
  final String incubatorName;
  final DateTime setDate;
  final int eggsSetCount;
  final double eggUnitCost;
  final double totalEggCost;
  final DateTime expectedHatchDate;
  final DateTime? candlingDate;
  final int fertileEggsCount;
  final int hatchedCount;
  final int deadInShellCount;
  final int culledChicksCount;
  final int durationDays;
  final String status; // 'incubating', 'completed', 'cancelled'
  final double extraCosts; // electricity, sanitation, supplies
  final String notes;
  final DateTime createdAt;

  const IncubationBatch({
    required this.id,
    this.flockId,
    required this.species,
    required this.incubatorName,
    required this.setDate,
    required this.eggsSetCount,
    this.eggUnitCost = 0.0,
    this.totalEggCost = 0.0,
    required this.expectedHatchDate,
    this.candlingDate,
    this.fertileEggsCount = 0,
    this.hatchedCount = 0,
    this.deadInShellCount = 0,
    this.culledChicksCount = 0,
    this.durationDays = 21,
    this.status = 'incubating',
    this.extraCosts = 0.0,
    this.notes = '',
    required this.createdAt,
  });

  int get daysSinceSet {
    final diff = DateTime.now().difference(setDate).inDays;
    return diff < 0 ? 0 : diff;
  }

  int get daysUntilHatch {
    final diff = expectedHatchDate.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  double get fertilityRate {
    if (eggsSetCount <= 0 || fertileEggsCount <= 0) return 0.0;
    return (fertileEggsCount / eggsSetCount) * 100.0;
  }

  double get hatchRateFromSet {
    if (eggsSetCount <= 0 || hatchedCount <= 0) return 0.0;
    return (hatchedCount / eggsSetCount) * 100.0;
  }

  double get hatchRateFromFertile {
    if (fertileEggsCount <= 0 || hatchedCount <= 0) return 0.0;
    return (hatchedCount / fertileEggsCount) * 100.0;
  }

  double get totalBatchCost => totalEggCost + extraCosts;

  double get costPerChick {
    if (hatchedCount <= 0) return 0.0;
    return totalBatchCost / hatchedCount;
  }

  IncubationBatch copyWith({
    String? id,
    String? flockId,
    String? species,
    String? incubatorName,
    DateTime? setDate,
    int? eggsSetCount,
    double? eggUnitCost,
    double? totalEggCost,
    DateTime? expectedHatchDate,
    DateTime? candlingDate,
    int? fertileEggsCount,
    int? hatchedCount,
    int? deadInShellCount,
    int? culledChicksCount,
    int? durationDays,
    String? status,
    double? extraCosts,
    String? notes,
    DateTime? createdAt,
  }) {
    return IncubationBatch(
      id: id ?? this.id,
      flockId: flockId ?? this.flockId,
      species: species ?? this.species,
      incubatorName: incubatorName ?? this.incubatorName,
      setDate: setDate ?? this.setDate,
      eggsSetCount: eggsSetCount ?? this.eggsSetCount,
      eggUnitCost: eggUnitCost ?? this.eggUnitCost,
      totalEggCost: totalEggCost ?? this.totalEggCost,
      expectedHatchDate: expectedHatchDate ?? this.expectedHatchDate,
      candlingDate: candlingDate ?? this.candlingDate,
      fertileEggsCount: fertileEggsCount ?? this.fertileEggsCount,
      hatchedCount: hatchedCount ?? this.hatchedCount,
      deadInShellCount: deadInShellCount ?? this.deadInShellCount,
      culledChicksCount: culledChicksCount ?? this.culledChicksCount,
      durationDays: durationDays ?? this.durationDays,
      status: status ?? this.status,
      extraCosts: extraCosts ?? this.extraCosts,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'flock_id': flockId,
      'species': species,
      'incubator_name': incubatorName,
      'set_date': setDate.toIso8601String(),
      'eggs_set_count': eggsSetCount,
      'egg_unit_cost': eggUnitCost,
      'total_egg_cost': totalEggCost,
      'expected_hatch_date': expectedHatchDate.toIso8601String(),
      'candling_date': candlingDate?.toIso8601String(),
      'fertile_eggs_count': fertileEggsCount,
      'hatched_count': hatchedCount,
      'dead_in_shell_count': deadInShellCount,
      'culled_chicks_count': culledChicksCount,
      'duration_days': durationDays,
      'status': status,
      'extra_costs': extraCosts,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory IncubationBatch.fromMap(Map<String, dynamic> map) {
    return IncubationBatch(
      id: map['id'] as String,
      flockId: map['flock_id'] as String?,
      species: map['species'] as String,
      incubatorName: map['incubator_name'] as String? ?? 'Incubator 1',
      setDate: DateTime.parse(map['set_date'] as String),
      eggsSetCount: map['eggs_set_count'] as int? ?? 0,
      eggUnitCost: (map['egg_unit_cost'] as num?)?.toDouble() ?? 0.0,
      totalEggCost: (map['total_egg_cost'] as num?)?.toDouble() ?? 0.0,
      expectedHatchDate: DateTime.parse(map['expected_hatch_date'] as String),
      candlingDate: map['candling_date'] != null
          ? DateTime.parse(map['candling_date'] as String)
          : null,
      fertileEggsCount: map['fertile_eggs_count'] as int? ?? 0,
      hatchedCount: map['hatched_count'] as int? ?? 0,
      deadInShellCount: map['dead_in_shell_count'] as int? ?? 0,
      culledChicksCount: map['culled_chicks_count'] as int? ?? 0,
      durationDays: map['duration_days'] as int? ?? 21,
      status: map['status'] as String? ?? 'incubating',
      extraCosts: (map['extra_costs'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class IncubationReading {
  final String id;
  final String batchId;
  final DateTime dateTime;
  final double temperatureC;
  final double humidityPercent;
  final bool turned;
  final String notes;

  const IncubationReading({
    required this.id,
    required this.batchId,
    required this.dateTime,
    required this.temperatureC,
    required this.humidityPercent,
    this.turned = true,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'batch_id': batchId,
      'date_time': dateTime.toIso8601String(),
      'temperature_c': temperatureC,
      'humidity_percent': humidityPercent,
      'turned': turned ? 1 : 0,
      'notes': notes,
    };
  }

  factory IncubationReading.fromMap(Map<String, dynamic> map) {
    return IncubationReading(
      id: map['id'] as String,
      batchId: map['batch_id'] as String,
      dateTime: DateTime.parse(map['date_time'] as String),
      temperatureC: (map['temperature_c'] as num?)?.toDouble() ?? 37.5,
      humidityPercent: (map['humidity_percent'] as num?)?.toDouble() ?? 55.0,
      turned: (map['turned'] as int? ?? 1) == 1,
      notes: map['notes'] as String? ?? '',
    );
  }
}
