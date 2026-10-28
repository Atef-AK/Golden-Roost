class Flock {
  final String id;
  final String name;
  final String species;
  final String breed;
  final String purpose;
  final DateTime acquisitionDate;
  final DateTime? hatchDate;
  final int startCount;
  final int currentCount;
  final int startMaleCount;
  final int startFemaleCount;
  final int maleCount;
  final int femaleCount;
  final double purchasePricePerBird;
  final double totalPurchaseCost;
  final String supplier;
  final String housingLocation;
  final String notes;
  final bool isArchived;
  final DateTime createdAt;

  const Flock({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.purpose,
    required this.acquisitionDate,
    this.hatchDate,
    required this.startCount,
    required this.currentCount,
    int? startMaleCount,
    int? startFemaleCount,
    this.maleCount = 0,
    this.femaleCount = 0,
    this.purchasePricePerBird = 0.0,
    this.totalPurchaseCost = 0.0,
    this.supplier = '',
    this.housingLocation = '',
    this.notes = '',
    this.isArchived = false,
    required this.createdAt,
  }) : startMaleCount = startMaleCount ?? maleCount,
       startFemaleCount = startFemaleCount ?? femaleCount;

  DateTime get effectiveBirthDate => hatchDate ?? acquisitionDate;

  int get unknownSexCount =>
      (currentCount - (maleCount + femaleCount)).clamp(0, currentCount);

  /// Females at or past maturity (~18 weeks for chickens, ~6 weeks for quail) capable of laying
  int get eligibleLayingFemales {
    final pur = purpose.toLowerCase().trim();
    if (pur.contains('meat') ||
        pur.contains('broiler') ||
        pur.contains('chair')) {
      return 0;
    }
    final sp = species.toLowerCase().trim();
    final minLayingWeeks = (sp.contains('quail') || sp.contains('caille'))
        ? 6
        : 18;
    if (ageInWeeks < minLayingWeeks) return 0;
    return femaleCount;
  }

  int get ageInDays {
    return DateTime.now().difference(effectiveBirthDate).inDays.clamp(0, 99999);
  }

  int get ageInWeeks {
    return (ageInDays / 7).floor();
  }

  int get ageWeeks => ageInWeeks;

  Flock copyWith({
    String? id,
    String? name,
    String? species,
    String? breed,
    String? purpose,
    DateTime? acquisitionDate,
    DateTime? hatchDate,
    int? startCount,
    int? currentCount,
    int? startMaleCount,
    int? startFemaleCount,
    int? maleCount,
    int? femaleCount,
    double? purchasePricePerBird,
    double? totalPurchaseCost,
    String? supplier,
    String? housingLocation,
    String? notes,
    bool? isArchived,
    DateTime? createdAt,
  }) {
    return Flock(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      purpose: purpose ?? this.purpose,
      acquisitionDate: acquisitionDate ?? this.acquisitionDate,
      hatchDate: hatchDate ?? this.hatchDate,
      startCount: startCount ?? this.startCount,
      currentCount: currentCount ?? this.currentCount,
      startMaleCount: startMaleCount ?? this.startMaleCount,
      startFemaleCount: startFemaleCount ?? this.startFemaleCount,
      maleCount: maleCount ?? this.maleCount,
      femaleCount: femaleCount ?? this.femaleCount,
      purchasePricePerBird: purchasePricePerBird ?? this.purchasePricePerBird,
      totalPurchaseCost: totalPurchaseCost ?? this.totalPurchaseCost,
      supplier: supplier ?? this.supplier,
      housingLocation: housingLocation ?? this.housingLocation,
      notes: notes ?? this.notes,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'purpose': purpose,
      'acquisition_date': acquisitionDate.toIso8601String(),
      'hatch_date': hatchDate?.toIso8601String(),
      'start_count': startCount,
      'current_count': currentCount,
      'start_male_count': startMaleCount,
      'start_female_count': startFemaleCount,
      'male_count': maleCount,
      'female_count': femaleCount,
      'purchase_price_per_bird': purchasePricePerBird,
      'total_purchase_cost': totalPurchaseCost,
      'supplier': supplier,
      'housing_location': housingLocation,
      'notes': notes,
      'is_archived': isArchived ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Flock.fromMap(Map<String, dynamic> map) {
    final male = map['male_count'] as int? ?? 0;
    final female = map['female_count'] as int? ?? 0;
    return Flock(
      id: map['id'] as String,
      name: map['name'] as String,
      species: map['species'] as String,
      breed: map['breed'] as String? ?? '',
      purpose: map['purpose'] as String? ?? 'layers',
      acquisitionDate: DateTime.parse(map['acquisition_date'] as String),
      hatchDate: map['hatch_date'] != null
          ? DateTime.tryParse(map['hatch_date'] as String)
          : null,
      startCount: map['start_count'] as int? ?? 0,
      currentCount: map['current_count'] as int? ?? 0,
      startMaleCount: map['start_male_count'] as int? ?? male,
      startFemaleCount: map['start_female_count'] as int? ?? female,
      maleCount: male,
      femaleCount: female,
      purchasePricePerBird:
          (map['purchase_price_per_bird'] as num?)?.toDouble() ?? 0.0,
      totalPurchaseCost:
          (map['total_purchase_cost'] as num?)?.toDouble() ?? 0.0,
      supplier: map['supplier'] as String? ?? '',
      housingLocation: map['housing_location'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      isArchived: (map['is_archived'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
