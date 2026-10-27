import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/database/database_helper.dart';
import '../../core/database/sample_data.dart';
import '../../core/localization/app_translations.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/responsive.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/egg_provider.dart';
import '../../providers/feed_provider.dart';
import '../../providers/finance_provider.dart';
import '../../providers/flock_provider.dart';
import '../../providers/incubation_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/task_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('settings_title'))),
      body: ResponsiveContainer(
        maxWidth: 900,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            // 1. Appearance & Theme Selection
            PremiumCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.palette_outlined,
                          color: AppColors.primaryTeal,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          context.tr('settings_appearance'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr('settings_appearance_desc'),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (ctx, constraints) {
                      return SegmentedButton<String>(
                        showSelectedIcon: false,
                        segments: [
                          ButtonSegment<String>(
                            value: 'system',
                            icon: const Icon(Icons.brightness_auto, size: 16),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(context.tr('settings_theme_system')),
                            ),
                          ),
                          ButtonSegment<String>(
                            value: 'light',
                            icon: const Icon(Icons.light_mode, size: 16),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(context.tr('settings_theme_light')),
                            ),
                          ),
                          ButtonSegment<String>(
                            value: 'dark',
                            icon: const Icon(Icons.dark_mode, size: 16),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(context.tr('settings_theme_dark')),
                            ),
                          ),
                        ],
                        selected: {settings.themeMode},
                        onSelectionChanged: (newSelection) {
                          ref
                              .read(settingsProvider.notifier)
                              .updateThemeMode(newSelection.first);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. Farm Profile & Regional Settings
            PremiumCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.storefront_outlined,
                          color: AppColors.primaryTeal,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          context.tr('settings_profile_region'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.tr('settings_farm_name')),
                    subtitle: Text(settings.farmName),
                    trailing: const Icon(Icons.edit, size: 18),
                    onTap: () => _editFarmName(context, ref, settings.farmName),
                  ),
                  Divider(
                    height: 1,
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.tr('settings_currency')),
                    subtitle: Text(
                      '${settings.currency} (${context.tr('tnd')})',
                    ),
                    trailing: const Icon(Icons.edit, size: 18),
                    onTap: () => _editCurrency(context, ref, settings.currency),
                  ),
                  Divider(
                    height: 1,
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.tr('settings_language')),
                    subtitle: Text(
                      settings.language == 'ar'
                          ? 'العربية (Arabic - RTL)'
                          : settings.language == 'fr'
                          ? 'Français (French)'
                          : 'English',
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () =>
                        _changeLanguage(context, ref, settings.language),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. Notifications & Reminders
            PremiumCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.notifications_none,
                          color: AppColors.primaryTeal,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          context.tr('settings_notifications'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.tr('settings_enable_reminders')),
                    subtitle: Text(
                      context.tr('settings_reminders_desc'),
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: settings.remindersEnabled,
                    activeThumbColor: AppColors.primaryTeal,
                    onChanged: (val) async {
                      if (val) {
                        await NotificationService.instance.requestPermissions();
                      }
                      ref.read(settingsProvider.notifier).toggleReminders(val);
                    },
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.notifications_active_outlined),
                    label: Text(context.tr('settings_test_notification')),
                    onPressed: () async {
                      final reminderDesc = context.tr('settings_reminders_desc');
                      final testNotifMsg = context.tr('settings_test_notification');
                      await NotificationService.instance.requestPermissions();
                      await NotificationService.instance.showInstantNotification(
                        id: 999,
                        title: 'Golden Roost',
                        body: reminderDesc,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(testNotifMsg),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 4. Backup & Offline Persistence
            PremiumCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.cloud_download_outlined,
                          color: AppColors.primaryTeal,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          context.tr('settings_backup'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr('settings_backup_desc'),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                    ),
                    icon: const Icon(Icons.backup_outlined, size: 18),
                    label: Text(context.tr('settings_export_backup')),
                    onPressed: () => _exportJsonBackup(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 5. Sample Data Management
            PremiumCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accentLime.withAlpha(
                            isDark ? 25 : 35,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.auto_fix_high,
                          color: AppColors.primaryTeal,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          context.tr('settings_sample_data'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr('settings_sample_desc'),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryTeal,
                          ),
                          icon: const Icon(
                            Icons.download_for_offline,
                            size: 18,
                          ),
                          label: Text(context.tr('settings_load_sample')),
                          onPressed: () => _loadSample(context, ref),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.semanticError,
                            side: const BorderSide(
                              color: AppColors.semanticError,
                            ),
                          ),
                          icon: const Icon(
                            Icons.delete_sweep,
                            color: AppColors.semanticError,
                            size: 18,
                          ),
                          label: Text(context.tr('settings_clear_sample')),
                          onPressed: () => _confirmClearSample(context, ref),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFDC2626),
                            side: const BorderSide(
                              color: Color(0xFFDC2626),
                            ),
                          ),
                          icon: const Icon(
                            Icons.phonelink_erase,
                            color: Color(0xFFDC2626),
                            size: 18,
                          ),
                          label: Text(context.tr('settings_clear_all_data')),
                          onPressed: () => _confirmClearAllData(context, ref),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editFarmName(BuildContext context, WidgetRef ref, String currentName) {
    final ctrl = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('settings_farm_name')),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(labelText: context.tr('settings_farm_name')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
            ),
            onPressed: () {
              final n = ctrl.text.trim();
              if (n.isNotEmpty) {
                ref.read(settingsProvider.notifier).updateFarmName(n);
              }
              Navigator.pop(ctx);
            },
            child: Text(context.tr('save')),
          ),
        ],
      ),
    );
  }

  void _editCurrency(
    BuildContext context,
    WidgetRef ref,
    String currentCurrency,
  ) {
    final ctrl = TextEditingController(text: currentCurrency);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('settings_currency')),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            labelText: context.tr('settings_currency'),
            hintText: 'e.g. TND, DT, EUR, USD, DZD, MAD',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
            ),
            onPressed: () {
              final c = ctrl.text.trim();
              if (c.isNotEmpty) {
                ref
                    .read(settingsProvider.notifier)
                    .updateCurrency(c.toUpperCase());
              }
              Navigator.pop(ctx);
            },
            child: Text(context.tr('save')),
          ),
        ],
      ),
    );
  }

  void _changeLanguage(
    BuildContext context,
    WidgetRef ref,
    String currentLang,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
                title: const Text('English'),
                trailing: currentLang == 'en'
                    ? const Icon(Icons.check, color: AppColors.primaryTeal)
                    : null,
                onTap: () {
                  ref.read(settingsProvider.notifier).updateLanguage('en');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Text('🇫🇷', style: TextStyle(fontSize: 24)),
                title: const Text('Français'),
                trailing: currentLang == 'fr'
                    ? const Icon(Icons.check, color: AppColors.primaryTeal)
                    : null,
                onTap: () {
                  ref.read(settingsProvider.notifier).updateLanguage('fr');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Text('🇹🇳', style: TextStyle(fontSize: 24)),
                title: const Text('العربية (Arabic - RTL)'),
                trailing: currentLang == 'ar'
                    ? const Icon(Icons.check, color: AppColors.primaryTeal)
                    : null,
                onTap: () {
                  ref.read(settingsProvider.notifier).updateLanguage('ar');
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _loadSample(BuildContext context, WidgetRef ref) async {
    await SampleDataGenerator.loadSampleData();
    _refreshAllProviders(ref);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('settings_sample_loaded'))),
      );
    }
  }

  void _confirmClearSample(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('settings_clear_sample')),
        content: Text(
          context.tr('settings_clear_sample_confirm'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.semanticError,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _clearSample(context, ref);
            },
            child: Text(context.tr('delete')),
          ),
        ],
      ),
    );
  }

  void _clearSample(BuildContext context, WidgetRef ref) async {
    await DatabaseHelper.instance.clearSampleData();
    _refreshAllProviders(ref);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('settings_sample_cleared'))),
      );
    }
  }

  void _confirmClearAllData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('settings_clear_all_data')),
        content: Text(
          context.tr('settings_clear_all_confirm'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _clearAllData(context, ref);
            },
            child: Text(context.tr('delete')),
          ),
        ],
      ),
    );
  }

  void _clearAllData(BuildContext context, WidgetRef ref) async {
    await DatabaseHelper.instance.clearAllData();
    _refreshAllProviders(ref);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('settings_clear_all_success'))),
      );
    }
  }

  void _refreshAllProviders(WidgetRef ref) {
    ref.read(flocksProvider.notifier).loadFlocks();
    ref.read(feedInventoryProvider.notifier).loadInventory();
    ref.read(eggLogsProvider.notifier).loadLogs();
    ref.read(eggSalesProvider.notifier).loadSales();
    ref.read(incubationBatchesProvider.notifier).loadBatches();
    ref.read(tasksProvider.notifier).loadTasks();
    ref.read(vaccinationsProvider.notifier).loadVaccinations();
    ref.read(healthRecordsProvider.notifier).loadHealthRecords();
    ref.read(financesProvider.notifier).loadFinances();
    ref.read(settingsProvider.notifier).loadSettings();
    ref.invalidate(dashboardStatsProvider);
  }

  void _exportJsonBackup(BuildContext context) async {
    try {
      final jsonMap = await DatabaseHelper.instance.exportAllDataAsJson();
      final jsonStr = const JsonEncoder.withIndent('  ').convert(jsonMap);

      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/golden_roost_backup_${DateTime.now().millisecondsSinceEpoch}.json',
      );
      await file.writeAsString(jsonStr);

      // ignore: deprecated_member_use
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Golden Roost JSON Database Backup');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Backup error: $e')));
      }
    }
  }
}
