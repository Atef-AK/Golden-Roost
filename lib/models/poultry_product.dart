class PoultryProduct {
  final String id;
  final String
  category; // 'incubators', 'brooders', 'feeders', 'drinkers', 'hygrometers', 'candlers', 'biosecurity'
  final String nameEn;
  final String nameFr;
  final String nameAr;
  final String descriptionEn;
  final String descriptionFr;
  final String descriptionAr;
  final String imageUrl;
  final String merchantName;
  final double price;
  final String currency;
  final DateTime? priceVerifiedDate;
  final String targetUrl;
  final String affiliateUrl;
  final String commercialDisclosure;
  final bool isFeatured;
  final bool isActive;
  final int displayOrder;
  final DateTime createdAt;

  const PoultryProduct({
    required this.id,
    required this.category,
    required this.nameEn,
    required this.nameFr,
    required this.nameAr,
    required this.descriptionEn,
    required this.descriptionFr,
    required this.descriptionAr,
    this.imageUrl = '',
    required this.merchantName,
    this.price = 0.0,
    this.currency = 'USD',
    this.priceVerifiedDate,
    required this.targetUrl,
    this.affiliateUrl = '',
    this.commercialDisclosure =
        'Golden Roost may earn an affiliate commission if you purchase through this link, at no extra cost to you.',
    this.isFeatured = false,
    this.isActive = true,
    this.displayOrder = 0,
    required this.createdAt,
  });

  String localizedName(String langCode) {
    if (langCode == 'ar') return nameAr.isNotEmpty ? nameAr : nameEn;
    if (langCode == 'fr') return nameFr.isNotEmpty ? nameFr : nameEn;
    return nameEn;
  }

  String localizedDescription(String langCode) {
    if (langCode == 'ar') {
      return descriptionAr.isNotEmpty ? descriptionAr : descriptionEn;
    }
    if (langCode == 'fr') {
      return descriptionFr.isNotEmpty ? descriptionFr : descriptionEn;
    }
    return descriptionEn;
  }

  String get effectiveUrl => affiliateUrl.isNotEmpty ? affiliateUrl : targetUrl;

  PoultryProduct copyWith({
    String? id,
    String? category,
    String? nameEn,
    String? nameFr,
    String? nameAr,
    String? descriptionEn,
    String? descriptionFr,
    String? descriptionAr,
    String? imageUrl,
    String? merchantName,
    double? price,
    String? currency,
    DateTime? priceVerifiedDate,
    String? targetUrl,
    String? affiliateUrl,
    String? commercialDisclosure,
    bool? isFeatured,
    bool? isActive,
    int? displayOrder,
    DateTime? createdAt,
  }) {
    return PoultryProduct(
      id: id ?? this.id,
      category: category ?? this.category,
      nameEn: nameEn ?? this.nameEn,
      nameFr: nameFr ?? this.nameFr,
      nameAr: nameAr ?? this.nameAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionFr: descriptionFr ?? this.descriptionFr,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      imageUrl: imageUrl ?? this.imageUrl,
      merchantName: merchantName ?? this.merchantName,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      priceVerifiedDate: priceVerifiedDate ?? this.priceVerifiedDate,
      targetUrl: targetUrl ?? this.targetUrl,
      affiliateUrl: affiliateUrl ?? this.affiliateUrl,
      commercialDisclosure: commercialDisclosure ?? this.commercialDisclosure,
      isFeatured: isFeatured ?? this.isFeatured,
      isActive: isActive ?? this.isActive,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'name_en': nameEn,
      'name_fr': nameFr,
      'name_ar': nameAr,
      'description_en': descriptionEn,
      'description_fr': descriptionFr,
      'description_ar': descriptionAr,
      'image_url': imageUrl,
      'merchant_name': merchantName,
      'price': price,
      'currency': currency,
      'price_verified_date': priceVerifiedDate?.toIso8601String(),
      'target_url': targetUrl,
      'affiliate_url': affiliateUrl,
      'commercial_disclosure': commercialDisclosure,
      'is_featured': isFeatured ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'display_order': displayOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PoultryProduct.fromMap(Map<String, dynamic> map) {
    return PoultryProduct(
      id: map['id'] as String,
      category: map['category'] as String? ?? 'incubators',
      nameEn: map['name_en'] as String? ?? '',
      nameFr: map['name_fr'] as String? ?? '',
      nameAr: map['name_ar'] as String? ?? '',
      descriptionEn: map['description_en'] as String? ?? '',
      descriptionFr: map['description_fr'] as String? ?? '',
      descriptionAr: map['description_ar'] as String? ?? '',
      imageUrl: map['image_url'] as String? ?? '',
      merchantName: map['merchant_name'] as String? ?? 'Authorized Supplier',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] as String? ?? 'USD',
      priceVerifiedDate: map['price_verified_date'] != null
          ? DateTime.tryParse(map['price_verified_date'] as String)
          : null,
      targetUrl: map['target_url'] as String? ?? '',
      affiliateUrl: map['affiliate_url'] as String? ?? '',
      commercialDisclosure: map['commercial_disclosure'] as String? ?? '',
      isFeatured: (map['is_featured'] as int? ?? 0) == 1,
      isActive: (map['is_active'] as int? ?? 1) == 1,
      displayOrder: map['display_order'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
