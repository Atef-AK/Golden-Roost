class EggLog {
  final String id;
  final String flockId;
  final DateTime date;
  final String collectionTime; // 'morning', 'afternoon', 'evening', 'total'
  final int totalEggs;
  final int crackedEggs;
  final int dirtyEggs;
  final int usableEggs;
  final int keptForIncubation;
  final String notes;
  final DateTime createdAt;

  const EggLog({
    required this.id,
    required this.flockId,
    required this.date,
    this.collectionTime = 'total',
    required this.totalEggs,
    this.crackedEggs = 0,
    this.dirtyEggs = 0,
    required this.usableEggs,
    this.keptForIncubation = 0,
    this.notes = '',
    required this.createdAt,
  });

  int get damagedEggs => crackedEggs + dirtyEggs;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'flock_id': flockId,
      'date': date.toIso8601String(),
      'collection_time': collectionTime,
      'total_eggs': totalEggs,
      'cracked_eggs': crackedEggs,
      'dirty_eggs': dirtyEggs,
      'usable_eggs': usableEggs,
      'kept_for_incubation': keptForIncubation,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory EggLog.fromMap(Map<String, dynamic> map) {
    return EggLog(
      id: map['id'] as String,
      flockId: map['flock_id'] as String,
      date: DateTime.parse(map['date'] as String),
      collectionTime: map['collection_time'] as String? ?? 'total',
      totalEggs: map['total_eggs'] as int? ?? 0,
      crackedEggs: map['cracked_eggs'] as int? ?? 0,
      dirtyEggs: map['dirty_eggs'] as int? ?? 0,
      usableEggs: map['usable_eggs'] as int? ?? 0,
      keptForIncubation: map['kept_for_incubation'] as int? ?? 0,
      notes: map['notes'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class EggSale {
  final String id;
  final String? flockId;
  final DateTime date;
  final int quantity;
  final double unitPrice; // price per egg
  final double totalAmount;
  final String buyerName;
  final String paymentStatus; // paid, pending, partial
  final double amountPaid;
  final String notes;
  final DateTime createdAt;

  const EggSale({
    required this.id,
    this.flockId,
    required this.date,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    this.buyerName = '',
    this.paymentStatus = 'paid',
    this.amountPaid = 0.0,
    this.notes = '',
    required this.createdAt,
  });

  double get outstandingAmount => totalAmount - amountPaid;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'flock_id': flockId,
      'date': date.toIso8601String(),
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_amount': totalAmount,
      'buyer_name': buyerName,
      'payment_status': paymentStatus,
      'amount_paid': amountPaid,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory EggSale.fromMap(Map<String, dynamic> map) {
    final total = (map['total_amount'] as num?)?.toDouble() ?? 0.0;
    return EggSale(
      id: map['id'] as String,
      flockId: map['flock_id'] as String?,
      date: DateTime.parse(map['date'] as String),
      quantity: map['quantity'] as int? ?? 0,
      unitPrice: (map['unit_price'] as num?)?.toDouble() ?? 0.0,
      totalAmount: total,
      buyerName: map['buyer_name'] as String? ?? '',
      paymentStatus: map['payment_status'] as String? ?? 'paid',
      amountPaid: (map['amount_paid'] as num?)?.toDouble() ?? total,
      notes: map['notes'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
