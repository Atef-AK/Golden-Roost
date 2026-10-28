class FarmSettings {
  final int id;
  final String farmName;
  final String currency;
  final String weightUnit;
  final String language;
  final String timezone;
  final double electricityKwhRate;
  final bool remindersEnabled;
  final String reminderTime; // e.g. "08:00"
  final String themeMode; // 'system', 'light', 'dark'
  final bool
  autoFeedDeduction; // Default false: forecasting never silently deducts stock
  final bool articleNotificationsEnabled; // Educational and health updates
  final bool
  marketingNotificationsEnabled; // Optional promotional announcements
  final bool adsEnabled; // Global toggle for banner/monetization
  final bool cloudSyncEnabled; // Optional cloud sync
  final DateTime? lastSyncTimestamp;

  const FarmSettings({
    this.id = 1,
    this.farmName = 'Golden Roost Farm',
    this.currency = 'TND',
    this.weightUnit = 'kg',
    this.language = 'en',
    this.timezone = 'Africa/Tunis',
    this.electricityKwhRate = 0.280, // DT per kWh
    this.remindersEnabled = true,
    this.reminderTime = '08:00',
    this.themeMode = 'system',
    this.autoFeedDeduction = false,
    this.articleNotificationsEnabled = true,
    this.marketingNotificationsEnabled = false,
    this.adsEnabled = true,
    this.cloudSyncEnabled = false,
    this.lastSyncTimestamp,
  });

  FarmSettings copyWith({
    int? id,
    String? farmName,
    String? currency,
    String? weightUnit,
    String? language,
    String? timezone,
    double? electricityKwhRate,
    bool? remindersEnabled,
    String? reminderTime,
    String? themeMode,
    bool? autoFeedDeduction,
    bool? articleNotificationsEnabled,
    bool? marketingNotificationsEnabled,
    bool? adsEnabled,
    bool? cloudSyncEnabled,
    DateTime? lastSyncTimestamp,
  }) {
    return FarmSettings(
      id: id ?? this.id,
      farmName: farmName ?? this.farmName,
      currency: currency ?? this.currency,
      weightUnit: weightUnit ?? this.weightUnit,
      language: language ?? this.language,
      timezone: timezone ?? this.timezone,
      electricityKwhRate: electricityKwhRate ?? this.electricityKwhRate,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      themeMode: themeMode ?? this.themeMode,
      autoFeedDeduction: autoFeedDeduction ?? this.autoFeedDeduction,
      articleNotificationsEnabled:
          articleNotificationsEnabled ?? this.articleNotificationsEnabled,
      marketingNotificationsEnabled:
          marketingNotificationsEnabled ?? this.marketingNotificationsEnabled,
      adsEnabled: adsEnabled ?? this.adsEnabled,
      cloudSyncEnabled: cloudSyncEnabled ?? this.cloudSyncEnabled,
      lastSyncTimestamp: lastSyncTimestamp ?? this.lastSyncTimestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'farm_name': farmName,
      'currency': currency,
      'weight_unit': weightUnit,
      'language': language,
      'timezone': timezone,
      'electricity_kwh_rate': electricityKwhRate,
      'reminders_enabled': remindersEnabled ? 1 : 0,
      'reminder_time': reminderTime,
      'theme_mode': themeMode,
      'auto_feed_deduction': autoFeedDeduction ? 1 : 0,
      'article_notifications_enabled': articleNotificationsEnabled ? 1 : 0,
      'marketing_notifications_enabled': marketingNotificationsEnabled ? 1 : 0,
      'ads_enabled': adsEnabled ? 1 : 0,
      'cloud_sync_enabled': cloudSyncEnabled ? 1 : 0,
      'last_sync_timestamp': lastSyncTimestamp?.toIso8601String(),
    };
  }

  factory FarmSettings.fromMap(Map<String, dynamic> map) {
    return FarmSettings(
      id: map['id'] as int? ?? 1,
      farmName: map['farm_name'] as String? ?? 'Golden Roost Farm',
      currency: map['currency'] as String? ?? 'TND',
      weightUnit: map['weight_unit'] as String? ?? 'kg',
      language: map['language'] as String? ?? 'en',
      timezone: map['timezone'] as String? ?? 'Africa/Tunis',
      electricityKwhRate:
          (map['electricity_kwh_rate'] as num?)?.toDouble() ?? 0.280,
      remindersEnabled: (map['reminders_enabled'] as int? ?? 1) == 1,
      reminderTime: map['reminder_time'] as String? ?? '08:00',
      themeMode: map['theme_mode'] as String? ?? 'system',
      autoFeedDeduction: (map['auto_feed_deduction'] as int? ?? 0) == 1,
      articleNotificationsEnabled:
          (map['article_notifications_enabled'] as int? ?? 1) == 1,
      marketingNotificationsEnabled:
          (map['marketing_notifications_enabled'] as int? ?? 0) == 1,
      adsEnabled: (map['ads_enabled'] as int? ?? 1) == 1,
      cloudSyncEnabled: (map['cloud_sync_enabled'] as int? ?? 0) == 1,
      lastSyncTimestamp: map['last_sync_timestamp'] != null
          ? DateTime.tryParse(map['last_sync_timestamp'] as String)
          : null,
    );
  }
}
