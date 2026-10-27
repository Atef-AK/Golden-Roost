class BirdMovement {
  final String id;
  final String flockId;
  final DateTime date;
  final String
  type; // 'purchase', 'hatch_transfer', 'mortality', 'cull', 'sale', 'transfer_out'
  final int count;
  final int maleCount;
  final int femaleCount;
  final double unitPrice;
  final double totalAmount;
  final String reasonOrBuyer;
  final String notes;
  final DateTime createdAt;

  const BirdMovement({
    required this.id,
    required this.flockId,
    required this.date,
    required this.type,
    required this.count,
    this.maleCount = 0,
    this.femaleCount = 0,
    this.unitPrice = 0.0,
    this.totalAmount = 0.0,
    this.reasonOrBuyer = '',
    this.notes = '',
    required this.createdAt,
  });

  bool get isReduction =>
      type == 'mortality' ||
      type == 'cull' ||
      type == 'sale' ||
      type == 'transfer_out';

  bool get isAddition =>
      type == 'purchase' ||
      type == 'hatch_transfer' ||
      type == 'birth' ||
      type == 'transfer_in';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'flock_id': flockId,
      'date': date.toIso8601String(),
      'type': type,
      'count': count,
      'male_count': maleCount,
      'female_count': femaleCount,
      'unit_price': unitPrice,
      'total_amount': totalAmount,
      'reason_or_buyer': reasonOrBuyer,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory BirdMovement.fromMap(Map<String, dynamic> map) {
    return BirdMovement(
      id: map['id'] as String,
      flockId: map['flock_id'] as String,
      date: DateTime.parse(map['date'] as String),
      type: map['type'] as String,
      count: map['count'] as int? ?? 0,
      maleCount: map['male_count'] as int? ?? 0,
      femaleCount: map['female_count'] as int? ?? 0,
      unitPrice: (map['unit_price'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0.0,
      reasonOrBuyer: map['reason_or_buyer'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
