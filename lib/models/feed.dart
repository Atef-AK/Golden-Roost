class FeedItem {
  final String id;
  final String name;
  final String feedType; // starter, grower, layer, breeder, quail, other
  final double currentStockKg;
  final double lowStockThresholdKg;
  final double bagWeightKg;
  final double costPerBag;
  final String notes;
  final DateTime updatedAt;

  const FeedItem({
    required this.id,
    required this.name,
    required this.feedType,
    required this.currentStockKg,
    this.lowStockThresholdKg = 25.0,
    this.bagWeightKg = 50.0,
    this.costPerBag = 0.0,
    this.notes = '',
    required this.updatedAt,
  });

  bool get isLowStock => currentStockKg <= lowStockThresholdKg;

  double get costPerKg => bagWeightKg > 0 ? (costPerBag / bagWeightKg) : 0.0;

  FeedItem copyWith({
    String? id,
    String? name,
    String? feedType,
    double? currentStockKg,
    double? lowStockThresholdKg,
    double? bagWeightKg,
    double? costPerBag,
    String? notes,
    DateTime? updatedAt,
  }) {
    return FeedItem(
      id: id ?? this.id,
      name: name ?? this.name,
      feedType: feedType ?? this.feedType,
      currentStockKg: currentStockKg ?? this.currentStockKg,
      lowStockThresholdKg: lowStockThresholdKg ?? this.lowStockThresholdKg,
      bagWeightKg: bagWeightKg ?? this.bagWeightKg,
      costPerBag: costPerBag ?? this.costPerBag,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'feed_type': feedType,
      'current_stock_kg': currentStockKg,
      'low_stock_threshold_kg': lowStockThresholdKg,
      'bag_weight_kg': bagWeightKg,
      'cost_per_bag': costPerBag,
      'notes': notes,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory FeedItem.fromMap(Map<String, dynamic> map) {
    return FeedItem(
      id: map['id'] as String,
      name: map['name'] as String,
      feedType: map['feed_type'] as String? ?? 'layer',
      currentStockKg: (map['current_stock_kg'] as num?)?.toDouble() ?? 0.0,
      lowStockThresholdKg:
          (map['low_stock_threshold_kg'] as num?)?.toDouble() ?? 25.0,
      bagWeightKg: (map['bag_weight_kg'] as num?)?.toDouble() ?? 50.0,
      costPerBag: (map['cost_per_bag'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes'] as String? ?? '',
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

class FeedTransaction {
  final String id;
  final String feedId;
  final String? flockId;
  final DateTime date;
  final String type; // purchase, consumption, adjustment
  final double quantityKg;
  final double cost;
  final String notes;
  final DateTime createdAt;

  const FeedTransaction({
    required this.id,
    required this.feedId,
    this.flockId,
    required this.date,
    required this.type,
    required this.quantityKg,
    this.cost = 0.0,
    this.notes = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'feed_id': feedId,
      'flock_id': flockId,
      'date': date.toIso8601String(),
      'type': type,
      'quantity_kg': quantityKg,
      'cost': cost,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory FeedTransaction.fromMap(Map<String, dynamic> map) {
    return FeedTransaction(
      id: map['id'] as String,
      feedId: map['feed_id'] as String,
      flockId: map['flock_id'] as String?,
      date: DateTime.parse(map['date'] as String),
      type: map['type'] as String,
      quantityKg: (map['quantity_kg'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  FeedTransaction copyWith({
    String? id,
    String? feedId,
    String? flockId,
    DateTime? date,
    String? type,
    double? quantityKg,
    double? cost,
    String? notes,
    DateTime? createdAt,
  }) {
    return FeedTransaction(
      id: id ?? this.id,
      feedId: feedId ?? this.feedId,
      flockId: flockId ?? this.flockId,
      date: date ?? this.date,
      type: type ?? this.type,
      quantityKg: quantityKg ?? this.quantityKg,
      cost: cost ?? this.cost,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class WaterCareLog {
  final String id;
  final String flockId;
  final DateTime date;
  final double waterConsumedLiters;
  final bool waterCheckCompleted;
  final bool equipmentCleaned;
  final String observations;
  final String notes;
  final DateTime createdAt;

  const WaterCareLog({
    required this.id,
    required this.flockId,
    required this.date,
    this.waterConsumedLiters = 0.0,
    this.waterCheckCompleted = true,
    this.equipmentCleaned = false,
    this.observations = '',
    this.notes = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'flock_id': flockId,
      'date': date.toIso8601String(),
      'water_consumed_liters': waterConsumedLiters,
      'water_check_completed': waterCheckCompleted ? 1 : 0,
      'equipment_cleaned': equipmentCleaned ? 1 : 0,
      'observations': observations,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory WaterCareLog.fromMap(Map<String, dynamic> map) {
    return WaterCareLog(
      id: map['id'] as String,
      flockId: map['flock_id'] as String,
      date: DateTime.parse(map['date'] as String),
      waterConsumedLiters:
          (map['water_consumed_liters'] as num?)?.toDouble() ?? 0.0,
      waterCheckCompleted: (map['water_check_completed'] as int? ?? 1) == 1,
      equipmentCleaned: (map['equipment_cleaned'] as int? ?? 0) == 1,
      observations: map['observations'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
