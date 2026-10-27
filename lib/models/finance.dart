class FinancialTransaction {
  final String id;
  final String type; // 'expense' or 'income'
  final String category;
  final double amount;
  final DateTime date;
  final String? flockId;
  final String? incubationId;
  final String? equipmentId;
  final bool
  isCapitalInvestment; // e.g. buying an incubator/building vs buying feed
  final String paymentStatus; // 'paid', 'unpaid', 'partial'
  final double amountPaid;
  final String notes;
  final DateTime createdAt;

  const FinancialTransaction({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    this.flockId,
    this.incubationId,
    this.equipmentId,
    this.isCapitalInvestment = false,
    this.paymentStatus = 'paid',
    this.amountPaid = 0.0,
    this.notes = '',
    required this.createdAt,
  });

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';
  double get outstandingAmount => amount - amountPaid;

  FinancialTransaction copyWith({
    String? id,
    String? type,
    String? category,
    double? amount,
    DateTime? date,
    String? flockId,
    String? incubationId,
    String? equipmentId,
    bool? isCapitalInvestment,
    String? paymentStatus,
    double? amountPaid,
    String? notes,
    DateTime? createdAt,
  }) {
    return FinancialTransaction(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      flockId: flockId ?? this.flockId,
      incubationId: incubationId ?? this.incubationId,
      equipmentId: equipmentId ?? this.equipmentId,
      isCapitalInvestment: isCapitalInvestment ?? this.isCapitalInvestment,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      amountPaid: amountPaid ?? this.amountPaid,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'flock_id': flockId,
      'incubation_id': incubationId,
      'equipment_id': equipmentId,
      'is_capital_investment': isCapitalInvestment ? 1 : 0,
      'payment_status': paymentStatus,
      'amount_paid': amountPaid,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory FinancialTransaction.fromMap(Map<String, dynamic> map) {
    final amt = (map['amount'] as num?)?.toDouble() ?? 0.0;
    return FinancialTransaction(
      id: map['id'] as String,
      type: map['type'] as String,
      category: map['category'] as String,
      amount: amt,
      date: DateTime.parse(map['date'] as String),
      flockId: map['flock_id'] as String?,
      incubationId: map['incubation_id'] as String?,
      equipmentId: map['equipment_id'] as String?,
      isCapitalInvestment: (map['is_capital_investment'] as int? ?? 0) == 1,
      paymentStatus: map['payment_status'] as String? ?? 'paid',
      amountPaid: (map['amount_paid'] as num?)?.toDouble() ?? amt,
      notes: map['notes'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
