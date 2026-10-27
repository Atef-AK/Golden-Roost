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

  const FarmSettings({
    this.id = 1,
    this.farmName = 'My Poultry Farm',
    this.currency = 'TND',
    this.weightUnit = 'kg',
    this.language = 'en',
    this.timezone = 'Africa/Tunis',
    this.electricityKwhRate = 0.280, // DT per kWh
    this.remindersEnabled = true,
    this.reminderTime = '08:00',
    this.themeMode = 'system',
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
    };
  }

  factory FarmSettings.fromMap(Map<String, dynamic> map) {
    return FarmSettings(
      id: map['id'] as int? ?? 1,
      farmName: map['farm_name'] as String? ?? 'My Poultry Farm',
      currency: map['currency'] as String? ?? 'TND',
      weightUnit: map['weight_unit'] as String? ?? 'kg',
      language: map['language'] as String? ?? 'en',
      timezone: map['timezone'] as String? ?? 'Africa/Tunis',
      electricityKwhRate:
          (map['electricity_kwh_rate'] as num?)?.toDouble() ?? 0.280,
      remindersEnabled: (map['reminders_enabled'] as int? ?? 1) == 1,
      reminderTime: map['reminder_time'] as String? ?? '08:00',
      themeMode: map['theme_mode'] as String? ?? 'system',
    );
  }
}
