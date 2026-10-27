class HealthRecord {
  final String id;
  final String flockId;
  final DateTime date;
  final String symptomOrDiagnosis;
  final int birdsAffected;
  final int mortalityCount;
  final String treatmentAdministered;
  final String vetName;
  final double cost;
  final String notes;
  final DateTime createdAt;

  const HealthRecord({
    required this.id,
    required this.flockId,
    required this.date,
    required this.symptomOrDiagnosis,
    this.birdsAffected = 0,
    this.mortalityCount = 0,
    this.treatmentAdministered = '',
    this.vetName = '',
    this.cost = 0.0,
    this.notes = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'flock_id': flockId,
      'date': date.toIso8601String(),
      'symptom_or_diagnosis': symptomOrDiagnosis,
      'birds_affected': birdsAffected,
      'mortality_count': mortalityCount,
      'treatment_administered': treatmentAdministered,
      'vet_name': vetName,
      'cost': cost,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    return HealthRecord(
      id: map['id'] as String,
      flockId: map['flock_id'] as String,
      date: DateTime.parse(map['date'] as String),
      symptomOrDiagnosis: map['symptom_or_diagnosis'] as String,
      birdsAffected: map['birds_affected'] as int? ?? 0,
      mortalityCount: map['mortality_count'] as int? ?? 0,
      treatmentAdministered: map['treatment_administered'] as String? ?? '',
      vetName: map['vet_name'] as String? ?? '',
      cost: (map['cost'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
