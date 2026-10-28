import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/localization/app_translations.dart';
import '../../core/theme/app_icons.dart';
import '../../models/feed.dart';
import '../../providers/feed_provider.dart';
import '../../providers/flock_provider.dart';

class WaterCareDialog extends ConsumerStatefulWidget {
  final String? initialFlockId;

  const WaterCareDialog({super.key, this.initialFlockId});

  static Future<void> show(BuildContext context, {String? initialFlockId}) {
    return showDialog(
      context: context,
      builder: (ctx) => WaterCareDialog(initialFlockId: initialFlockId),
    );
  }

  @override
  ConsumerState<WaterCareDialog> createState() => _WaterCareDialogState();
}

class _WaterCareDialogState extends ConsumerState<WaterCareDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedFlockId;
  final _litersController = TextEditingController();
  final _obsController = TextEditingController();
  bool _drinkerCleaned = true;
  bool _waterChecked = true;

  @override
  void initState() {
    super.initState();
    _selectedFlockId = widget.initialFlockId;
  }

  @override
  void dispose() {
    _litersController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flocks = ref
        .watch(flocksProvider)
        .where((f) => !f.isArchived)
        .toList();
    if (_selectedFlockId == null && flocks.isNotEmpty) {
      _selectedFlockId = flocks.first.id;
    }

    return AlertDialog(
      title: Row(
        children: [
          const Icon(AppIcons.water, color: Color(0xFF06B6D4)),
          const SizedBox(width: 8),
          Text(context.tr('water_check_title')),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (flocks.isNotEmpty)
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _selectedFlockId,
                  decoration: InputDecoration(
                    labelText: context.tr('flocks_name'),
                  ),
                  items: flocks.map((f) {
                    return DropdownMenuItem(
                      value: f.id,
                      child: Text(
                        '${f.name} (${f.currentCount} ${context.tr('dash_total_birds')})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedFlockId = val),
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _litersController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: context.tr('water_consumed_label'),
                  hintText: context.tr('water_consumed_hint'),
                  prefixIcon: const Icon(
                    AppIcons.water,
                    color: Color(0xFF06B6D4),
                  ),
                  suffixText: 'L',
                ),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                title: Text(context.tr('water_inspected_check')),
                value: _waterChecked,
                onChanged: (val) => setState(() => _waterChecked = val ?? true),
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                title: Text(context.tr('water_cleaned_check')),
                value: _drinkerCleaned,
                onChanged: (val) =>
                    setState(() => _drinkerCleaned = val ?? true),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _obsController,
                decoration: InputDecoration(
                  labelText: context.tr('water_observations_label'),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.tr('cancel')),
        ),
        ElevatedButton(
          onPressed: flocks.isEmpty ? null : _save,
          child: Text(context.tr('save')),
        ),
      ],
    );
  }

  void _save() {
    if (_selectedFlockId == null) return;
    final liters = double.tryParse(_litersController.text) ?? 0.0;

    final log = WaterCareLog(
      id: const Uuid().v4(),
      flockId: _selectedFlockId!,
      date: DateTime.now(),
      waterConsumedLiters: liters,
      waterCheckCompleted: _waterChecked,
      equipmentCleaned: _drinkerCleaned,
      observations: _obsController.text.trim(),
      createdAt: DateTime.now(),
    );

    ref.read(feedInventoryProvider.notifier).logWaterCare(log);
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.tr('success_saved'))));
  }
}
