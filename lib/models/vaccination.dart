class VaccinationSchedule {
  final String id;
  final String flockId;
  final String vaccineName;
  final int targetAgeDays;
  final DateTime targetDate;
  final String
  administrationRoute; // 'drinking_water', 'eye_drop', 'spray', 'subcutaneous_injection', 'intramuscular_injection', 'wing_web'
  final String status; // 'pending', 'completed', 'skipped'
  final DateTime? completedDate;
  final String notes;
  final DateTime createdAt;

  const VaccinationSchedule({
    required this.id,
    required this.flockId,
    required this.vaccineName,
    this.targetAgeDays = 0,
    required this.targetDate,
    this.administrationRoute = 'drinking_water',
    this.status = 'pending',
    this.completedDate,
    this.notes = '',
    required this.createdAt,
  });

  bool get isOverdue {
    if (status == 'completed' || status == 'skipped') return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );
    return targetDay.isBefore(today);
  }

  VaccinationSchedule copyWith({
    String? id,
    String? flockId,
    String? vaccineName,
    int? targetAgeDays,
    DateTime? targetDate,
    String? administrationRoute,
    String? status,
    DateTime? completedDate,
    String? notes,
    DateTime? createdAt,
  }) {
    return VaccinationSchedule(
      id: id ?? this.id,
      flockId: flockId ?? this.flockId,
      vaccineName: vaccineName ?? this.vaccineName,
      targetAgeDays: targetAgeDays ?? this.targetAgeDays,
      targetDate: targetDate ?? this.targetDate,
      administrationRoute: administrationRoute ?? this.administrationRoute,
      status: status ?? this.status,
      completedDate: completedDate ?? this.completedDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'flock_id': flockId,
      'vaccine_name': vaccineName,
      'target_age_days': targetAgeDays,
      'target_date': targetDate.toIso8601String(),
      'administration_route': administrationRoute,
      'status': status,
      'completed_date': completedDate?.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory VaccinationSchedule.fromMap(Map<String, dynamic> map) {
    return VaccinationSchedule(
      id: map['id'] as String,
      flockId: map['flock_id'] as String,
      vaccineName: map['vaccine_name'] as String,
      targetAgeDays: map['target_age_days'] as int? ?? 0,
      targetDate: DateTime.parse(map['target_date'] as String),
      administrationRoute:
          map['administration_route'] as String? ?? 'drinking_water',
      status: map['status'] as String? ?? 'pending',
      completedDate: map['completed_date'] != null
          ? DateTime.parse(map['completed_date'] as String)
          : null,
      notes: map['notes'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
