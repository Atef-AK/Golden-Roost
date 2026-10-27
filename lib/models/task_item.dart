class TaskItem {
  final String id;
  final String? flockId;
  final String? incubationId;
  final String title;
  final String
  category; // vaccination, feeding, watering, cleaning, weighing, maintenance, incubation, general
  final DateTime dueDate;
  final String? dueTime; // "08:30"
  final bool isCompleted;
  final DateTime? completedAt;
  final String recurrence; // 'none', 'daily', 'weekly', 'biweekly', 'monthly'
  final int reminderMinutesBefore;
  final String notes;
  final DateTime createdAt;

  const TaskItem({
    required this.id,
    this.flockId,
    this.incubationId,
    required this.title,
    this.category = 'general',
    required this.dueDate,
    this.dueTime,
    this.isCompleted = false,
    this.completedAt,
    this.recurrence = 'none',
    this.reminderMinutesBefore = 30,
    this.notes = '',
    required this.createdAt,
  });

  bool get isOverdue {
    if (isCompleted) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return taskDay.isBefore(today);
  }

  bool get isDueToday {
    final now = DateTime.now();
    return dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
  }

  TaskItem copyWith({
    String? id,
    String? flockId,
    String? incubationId,
    String? title,
    String? category,
    DateTime? dueDate,
    String? dueTime,
    bool? isCompleted,
    DateTime? completedAt,
    String? recurrence,
    int? reminderMinutesBefore,
    String? notes,
    DateTime? createdAt,
  }) {
    return TaskItem(
      id: id ?? this.id,
      flockId: flockId ?? this.flockId,
      incubationId: incubationId ?? this.incubationId,
      title: title ?? this.title,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      recurrence: recurrence ?? this.recurrence,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'flock_id': flockId,
      'incubation_id': incubationId,
      'title': title,
      'category': category,
      'due_date': dueDate.toIso8601String(),
      'due_time': dueTime,
      'is_completed': isCompleted ? 1 : 0,
      'completed_at': completedAt?.toIso8601String(),
      'recurrence': recurrence,
      'reminder_minutes_before': reminderMinutesBefore,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TaskItem.fromMap(Map<String, dynamic> map) {
    return TaskItem(
      id: map['id'] as String,
      flockId: map['flock_id'] as String?,
      incubationId: map['incubation_id'] as String?,
      title: map['title'] as String,
      category: map['category'] as String? ?? 'general',
      dueDate: DateTime.parse(map['due_date'] as String),
      dueTime: map['due_time'] as String?,
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
      recurrence: map['recurrence'] as String? ?? 'none',
      reminderMinutesBefore: map['reminder_minutes_before'] as int? ?? 30,
      notes: map['notes'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
