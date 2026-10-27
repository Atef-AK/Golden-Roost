class Article {
  final String id;
  final String slug;
  final String titleEn;
  final String titleFr;
  final String titleAr;
  final String summaryEn;
  final String summaryFr;
  final String summaryAr;
  final String bodyEn;
  final String bodyFr;
  final String bodyAr;
  final String category; // 'health', 'brooding', 'biosecurity', 'egg_production', 'quail', 'nutrition', 'incubation', 'economics'
  final List<String> tags;
  final String imageUrl;
  final String author;
  final String reviewer;
  final int readingTimeMinutes;
  final String references;
  final String disclaimer;
  final bool isPublished;
  final bool isFeatured;
  final DateTime publishedAt;
  final DateTime updatedAt;

  const Article({
    required this.id,
    required this.slug,
    required this.titleEn,
    required this.titleFr,
    required this.titleAr,
    required this.summaryEn,
    required this.summaryFr,
    required this.summaryAr,
    required this.bodyEn,
    required this.bodyFr,
    required this.bodyAr,
    required this.category,
    this.tags = const [],
    this.imageUrl = '',
    this.author = 'Golden Roost Editorial & Veterinary Team',
    this.reviewer = 'Dr. Poultry Health Specialist, DVM',
    this.readingTimeMinutes = 5,
    this.references = '',
    this.disclaimer =
        'This content is provided for educational purposes only and does not replace individualized diagnosis or treatment by a licensed avian veterinarian.',
    this.isPublished = true,
    this.isFeatured = false,
    required this.publishedAt,
    required this.updatedAt,
  });

  String localizedTitle(String langCode) {
    if (langCode == 'ar') return titleAr.isNotEmpty ? titleAr : titleEn;
    if (langCode == 'fr') return titleFr.isNotEmpty ? titleFr : titleEn;
    return titleEn;
  }

  String localizedSummary(String langCode) {
    if (langCode == 'ar') return summaryAr.isNotEmpty ? summaryAr : summaryEn;
    if (langCode == 'fr') return summaryFr.isNotEmpty ? summaryFr : summaryEn;
    return summaryEn;
  }

  String localizedBody(String langCode) {
    if (langCode == 'ar') return bodyAr.isNotEmpty ? bodyAr : bodyEn;
    if (langCode == 'fr') return bodyFr.isNotEmpty ? bodyFr : bodyEn;
    return bodyEn;
  }

  Article copyWith({
    String? id,
    String? slug,
    String? titleEn,
    String? titleFr,
    String? titleAr,
    String? summaryEn,
    String? summaryFr,
    String? summaryAr,
    String? bodyEn,
    String? bodyFr,
    String? bodyAr,
    String? category,
    List<String>? tags,
    String? imageUrl,
    String? author,
    String? reviewer,
    int? readingTimeMinutes,
    String? references,
    String? disclaimer,
    bool? isPublished,
    bool? isFeatured,
    DateTime? publishedAt,
    DateTime? updatedAt,
  }) {
    return Article(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      titleEn: titleEn ?? this.titleEn,
      titleFr: titleFr ?? this.titleFr,
      titleAr: titleAr ?? this.titleAr,
      summaryEn: summaryEn ?? this.summaryEn,
      summaryFr: summaryFr ?? this.summaryFr,
      summaryAr: summaryAr ?? this.summaryAr,
      bodyEn: bodyEn ?? this.bodyEn,
      bodyFr: bodyFr ?? this.bodyFr,
      bodyAr: bodyAr ?? this.bodyAr,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      author: author ?? this.author,
      reviewer: reviewer ?? this.reviewer,
      readingTimeMinutes: readingTimeMinutes ?? this.readingTimeMinutes,
      references: references ?? this.references,
      disclaimer: disclaimer ?? this.disclaimer,
      isPublished: isPublished ?? this.isPublished,
      isFeatured: isFeatured ?? this.isFeatured,
      publishedAt: publishedAt ?? this.publishedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'slug': slug,
      'title_en': titleEn,
      'title_fr': titleFr,
      'title_ar': titleAr,
      'summary_en': summaryEn,
      'summary_fr': summaryFr,
      'summary_ar': summaryAr,
      'body_en': bodyEn,
      'body_fr': bodyFr,
      'body_ar': bodyAr,
      'category': category,
      'tags': tags.join(','),
      'image_url': imageUrl,
      'author': author,
      'reviewer': reviewer,
      'reading_time_minutes': readingTimeMinutes,
      'references_text': references,
      'disclaimer': disclaimer,
      'is_published': isPublished ? 1 : 0,
      'is_featured': isFeatured ? 1 : 0,
      'published_at': publishedAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Article.fromMap(Map<String, dynamic> map) {
    final tagsStr = map['tags'] as String? ?? '';
    return Article(
      id: map['id'] as String,
      slug: map['slug'] as String? ?? map['id'] as String,
      titleEn: map['title_en'] as String? ?? '',
      titleFr: map['title_fr'] as String? ?? '',
      titleAr: map['title_ar'] as String? ?? '',
      summaryEn: map['summary_en'] as String? ?? '',
      summaryFr: map['summary_fr'] as String? ?? '',
      summaryAr: map['summary_ar'] as String? ?? '',
      bodyEn: map['body_en'] as String? ?? '',
      bodyFr: map['body_fr'] as String? ?? '',
      bodyAr: map['body_ar'] as String? ?? '',
      category: map['category'] as String? ?? 'health',
      tags: tagsStr.isNotEmpty ? tagsStr.split(',') : const [],
      imageUrl: map['image_url'] as String? ?? '',
      author: map['author'] as String? ?? 'Golden Roost Editorial',
      reviewer: map['reviewer'] as String? ?? 'Avian Health Specialist',
      readingTimeMinutes: map['reading_time_minutes'] as int? ?? 5,
      references: map['references_text'] as String? ?? '',
      disclaimer: map['disclaimer'] as String? ?? '',
      isPublished: (map['is_published'] as int? ?? 1) == 1,
      isFeatured: (map['is_featured'] as int? ?? 0) == 1,
      publishedAt: DateTime.parse(map['published_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
