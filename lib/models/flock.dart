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
    this.maleCount = 0,
    this.femaleCount = 0,
    this.purchasePricePerBird = 0.0,
    this.totalPurchaseCost = 0.0,
    this.supplier = '',
    this.housingLocation = '',
    this.notes = '',
    this.isArchived = false,
    required this.createdAt,
  });

  DateTime get effectiveBirthDate => hatchDate ?? acquisitionDate;

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
      maleCount: map['male_count'] as int? ?? 0,
      femaleCount: map['female_count'] as int? ?? 0,
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
