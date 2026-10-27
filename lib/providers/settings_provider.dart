import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/database_helper.dart';
import '../models/farm_settings.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, FarmSettings>((
  ref,
) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<FarmSettings> {
  SettingsNotifier() : super(const FarmSettings()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final settings = await DatabaseHelper.instance.getSettings();
    state = settings;
  }

  Future<void> updateFarmName(String name) async {
    final updated = state.copyWith(farmName: name);
    await DatabaseHelper.instance.updateSettings(updated);
    state = updated;
  }

  Future<void> updateCurrency(String currency) async {
    final updated = state.copyWith(currency: currency);
    await DatabaseHelper.instance.updateSettings(updated);
    state = updated;
  }

  Future<void> updateLanguage(String lang) async {
    final updated = state.copyWith(language: lang);
    await DatabaseHelper.instance.updateSettings(updated);
    state = updated;
  }

  Future<void> updateTimezone(String tz) async {
    final updated = state.copyWith(timezone: tz);
    await DatabaseHelper.instance.updateSettings(updated);
    state = updated;
  }

  Future<void> updateElectricityTariff(double rate) async {
    final updated = state.copyWith(electricityKwhRate: rate);
    await DatabaseHelper.instance.updateSettings(updated);
    state = updated;
  }

  Future<void> toggleReminders(bool enabled) async {
    final updated = state.copyWith(remindersEnabled: enabled);
    await DatabaseHelper.instance.updateSettings(updated);
    state = updated;
  }

  Future<void> updateReminderTime(String time) async {
    final updated = state.copyWith(reminderTime: time);
    await DatabaseHelper.instance.updateSettings(updated);
    state = updated;
  }

  Future<void> updateThemeMode(String mode) async {
    final updated = state.copyWith(themeMode: mode);
    await DatabaseHelper.instance.updateSettings(updated);
    state = updated;
  }

  Future<void> toggleAutoFeedDeduction(bool enabled) async {
    final updated = state.copyWith(autoFeedDeduction: enabled);
    await DatabaseHelper.instance.updateSettings(updated);
    state = updated;
  }

  Future<void> toggleArticleNotifications(bool enabled) async {
    final updated = state.copyWith(articleNotificationsEnabled: enabled);
    await DatabaseHelper.instance.updateSettings(updated);
    state = updated;
  }

  Future<void> toggleMarketingNotifications(bool enabled) async {
    final updated = state.copyWith(marketingNotificationsEnabled: enabled);
    await DatabaseHelper.instance.updateSettings(updated);
    state = updated;
  }

  Future<void> toggleAds(bool enabled) async {
    final updated = state.copyWith(adsEnabled: enabled);
    await DatabaseHelper.instance.updateSettings(updated);
    state = updated;
  }

  Future<void> toggleCloudSync(bool enabled) async {
    final updated = state.copyWith(cloudSyncEnabled: enabled);
    await DatabaseHelper.instance.updateSettings(updated);
    state = updated;
  }

  Future<void> updateLastSyncTimestamp(DateTime timestamp) async {
    final updated = state.copyWith(lastSyncTimestamp: timestamp);
    await DatabaseHelper.instance.updateSettings(updated);
    state = updated;
  }
}
