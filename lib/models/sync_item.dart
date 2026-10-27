class SyncItem {
  final String id;
  final String tableName;
  final String recordId;
  final String action; // 'insert', 'update', 'delete'
  final String payload; // JSON representation of data
  final String idempotencyKey;
  final String status; // 'pending', 'in_progress', 'synced', 'failed'
  final int attempts;
  final DateTime? lastAttempt;
  final String? errorMessage;
  final DateTime createdAt;

  const SyncItem({
    required this.id,
    required this.tableName,
    required this.recordId,
    required this.action,
    required this.payload,
    required this.idempotencyKey,
    this.status = 'pending',
    this.attempts = 0,
    this.lastAttempt,
    this.errorMessage,
    required this.createdAt,
  });

  SyncItem copyWith({
    String? id,
    String? tableName,
    String? recordId,
    String? action,
    String? payload,
    String? idempotencyKey,
    String? status,
    int? attempts,
    DateTime? lastAttempt,
    String? errorMessage,
    DateTime? createdAt,
  }) {
    return SyncItem(
      id: id ?? this.id,
      tableName: tableName ?? this.tableName,
      recordId: recordId ?? this.recordId,
      action: action ?? this.action,
      payload: payload ?? this.payload,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      lastAttempt: lastAttempt ?? this.lastAttempt,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'table_name': tableName,
      'record_id': recordId,
      'action': action,
      'payload': payload,
      'idempotency_key': idempotencyKey,
      'status': status,
      'attempts': attempts,
      'last_attempt': lastAttempt?.toIso8601String(),
      'error_message': errorMessage,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SyncItem.fromMap(Map<String, dynamic> map) {
    return SyncItem(
      id: map['id'] as String,
      tableName: map['table_name'] as String,
      recordId: map['record_id'] as String,
      action: map['action'] as String,
      payload: map['payload'] as String,
      idempotencyKey: map['idempotency_key'] as String,
      status: map['status'] as String? ?? 'pending',
      attempts: map['attempts'] as int? ?? 0,
      lastAttempt: map['last_attempt'] != null
          ? DateTime.tryParse(map['last_attempt'] as String)
          : null,
      errorMessage: map['error_message'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class SyncTombstone {
  final String tableName;
  final String recordId;
  final DateTime deletedAt;
  final bool synced;

  const SyncTombstone({
    required this.tableName,
    required this.recordId,
    required this.deletedAt,
    this.synced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'table_name': tableName,
      'record_id': recordId,
      'deleted_at': deletedAt.toIso8601String(),
      'synced': synced ? 1 : 0,
    };
  }

  factory SyncTombstone.fromMap(Map<String, dynamic> map) {
    return SyncTombstone(
      tableName: map['table_name'] as String,
      recordId: map['record_id'] as String,
      deletedAt: DateTime.parse(map['deleted_at'] as String),
      synced: (map['synced'] as int? ?? 0) == 1,
    );
  }
}
