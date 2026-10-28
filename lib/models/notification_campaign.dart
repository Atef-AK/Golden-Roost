class NotificationCampaign {
  final String id;
  final String titleEn;
  final String titleFr;
  final String titleAr;
  final String bodyEn;
  final String bodyFr;
  final String bodyAr;
  final String campaignType; // 'article', 'product', 'announcement', 'reminder'
  final String destinationType; // 'article', 'product', 'dashboard', 'url'
  final String? destinationId;
  final String
  audienceFilter; // 'all', 'arabic', 'french', 'english', 'opted_in_marketing'
  final String status; // 'draft', 'scheduled', 'sent', 'failed'
  final int sentCount;
  final DateTime? scheduledAt;
  final DateTime? sentAt;
  final DateTime createdAt;

  const NotificationCampaign({
    required this.id,
    required this.titleEn,
    required this.titleFr,
    required this.titleAr,
    required this.bodyEn,
    required this.bodyFr,
    required this.bodyAr,
    required this.campaignType,
    required this.destinationType,
    this.destinationId,
    this.audienceFilter = 'all',
    this.status = 'draft',
    this.sentCount = 0,
    this.scheduledAt,
    this.sentAt,
    required this.createdAt,
  });

  String localizedTitle(String langCode) {
    if (langCode == 'ar') return titleAr.isNotEmpty ? titleAr : titleEn;
    if (langCode == 'fr') return titleFr.isNotEmpty ? titleFr : titleEn;
    return titleEn;
  }

  String localizedBody(String langCode) {
    if (langCode == 'ar') return bodyAr.isNotEmpty ? bodyAr : bodyEn;
    if (langCode == 'fr') return bodyFr.isNotEmpty ? bodyFr : bodyEn;
    return bodyEn;
  }

  NotificationCampaign copyWith({
    String? id,
    String? titleEn,
    String? titleFr,
    String? titleAr,
    String? bodyEn,
    String? bodyFr,
    String? bodyAr,
    String? campaignType,
    String? destinationType,
    String? destinationId,
    String? audienceFilter,
    String? status,
    int? sentCount,
    DateTime? scheduledAt,
    DateTime? sentAt,
    DateTime? createdAt,
  }) {
    return NotificationCampaign(
      id: id ?? this.id,
      titleEn: titleEn ?? this.titleEn,
      titleFr: titleFr ?? this.titleFr,
      titleAr: titleAr ?? this.titleAr,
      bodyEn: bodyEn ?? this.bodyEn,
      bodyFr: bodyFr ?? this.bodyFr,
      bodyAr: bodyAr ?? this.bodyAr,
      campaignType: campaignType ?? this.campaignType,
      destinationType: destinationType ?? this.destinationType,
      destinationId: destinationId ?? this.destinationId,
      audienceFilter: audienceFilter ?? this.audienceFilter,
      status: status ?? this.status,
      sentCount: sentCount ?? this.sentCount,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      sentAt: sentAt ?? this.sentAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title_en': titleEn,
      'title_fr': titleFr,
      'title_ar': titleAr,
      'body_en': bodyEn,
      'body_fr': bodyFr,
      'body_ar': bodyAr,
      'campaign_type': campaignType,
      'destination_type': destinationType,
      'destination_id': destinationId,
      'audience_filter': audienceFilter,
      'status': status,
      'sent_count': sentCount,
      'scheduled_at': scheduledAt?.toIso8601String(),
      'sent_at': sentAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory NotificationCampaign.fromMap(Map<String, dynamic> map) {
    return NotificationCampaign(
      id: map['id'] as String,
      titleEn: map['title_en'] as String? ?? '',
      titleFr: map['title_fr'] as String? ?? '',
      titleAr: map['title_ar'] as String? ?? '',
      bodyEn: map['body_en'] as String? ?? '',
      bodyFr: map['body_fr'] as String? ?? '',
      bodyAr: map['body_ar'] as String? ?? '',
      campaignType: map['campaign_type'] as String? ?? 'announcement',
      destinationType: map['destination_type'] as String? ?? 'dashboard',
      destinationId: map['destination_id'] as String?,
      audienceFilter: map['audience_filter'] as String? ?? 'all',
      status: map['status'] as String? ?? 'draft',
      sentCount: map['sent_count'] as int? ?? 0,
      scheduledAt: map['scheduled_at'] != null
          ? DateTime.tryParse(map['scheduled_at'] as String)
          : null,
      sentAt: map['sent_at'] != null
          ? DateTime.tryParse(map['sent_at'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
