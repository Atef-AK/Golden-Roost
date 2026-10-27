class ElectricityReading {
  final String id;
  final DateTime date;
  final double meterReadingKwh;
  final double kwhConsumed;
  final double tariffPerKwh;
  final double totalCost;
  final String notes;
  final DateTime createdAt;

  const ElectricityReading({
    required this.id,
    required this.date,
    required this.meterReadingKwh,
    required this.kwhConsumed,
    required this.tariffPerKwh,
    required this.totalCost,
    this.notes = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'meter_reading_kwh': meterReadingKwh,
      'kwh_consumed': kwhConsumed,
      'tariff_per_kwh': tariffPerKwh,
      'total_cost': totalCost,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ElectricityReading.fromMap(Map<String, dynamic> map) {
    return ElectricityReading(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      meterReadingKwh: (map['meter_reading_kwh'] as num?)?.toDouble() ?? 0.0,
      kwhConsumed: (map['kwh_consumed'] as num?)?.toDouble() ?? 0.0,
      tariffPerKwh: (map['tariff_per_kwh'] as num?)?.toDouble() ?? 0.280,
      totalCost: (map['total_cost'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class EquipmentItem {
  final String id;
  final String name;
  final String
  category; // 'incubator', 'brooder_heater', 'lighting', 'ventilation', 'feeder', 'other'
  final DateTime purchaseDate;
  final double purchaseCost;
  final double wattage; // Watts
  final double dailyOperatingHours;
  final String notes;
  final DateTime createdAt;

  const EquipmentItem({
    required this.id,
    required this.name,
    required this.category,
    required this.purchaseDate,
    required this.purchaseCost,
    this.wattage = 100.0,
    this.dailyOperatingHours = 24.0,
    this.notes = '',
    required this.createdAt,
  });

  // Daily kWh consumption = (Watts * hours) / 1000
  double get dailyKwh => (wattage * dailyOperatingHours) / 1000.0;

  double monthlyCost(double tariff) => dailyKwh * 30.0 * tariff;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'purchase_date': purchaseDate.toIso8601String(),
      'purchase_cost': purchaseCost,
      'wattage': wattage,
      'daily_operating_hours': dailyOperatingHours,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory EquipmentItem.fromMap(Map<String, dynamic> map) {
    return EquipmentItem(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String? ?? 'other',
      purchaseDate: DateTime.parse(map['purchase_date'] as String),
      purchaseCost: (map['purchase_cost'] as num?)?.toDouble() ?? 0.0,
      wattage: (map['wattage'] as num?)?.toDouble() ?? 100.0,
      dailyOperatingHours:
          (map['daily_operating_hours'] as num?)?.toDouble() ?? 24.0,
      notes: map['notes'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
