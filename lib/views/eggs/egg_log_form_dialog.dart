import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/localization/app_translations.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../models/egg_record.dart';
import '../../providers/egg_provider.dart';
import '../../providers/flock_provider.dart';

class EggLogFormDialog extends ConsumerStatefulWidget {
  final String? initialFlockId;
  final EggLog? initialLog;

  const EggLogFormDialog({
    super.key,
    this.initialFlockId,
    this.initialLog,
  });

  static Future<void> show(
    BuildContext context, {
    String? initialFlockId,
    EggLog? initialLog,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => EggLogFormDialog(
        initialFlockId: initialFlockId,
        initialLog: initialLog,
      ),
    );
  }

  @override
  ConsumerState<EggLogFormDialog> createState() => _EggLogFormDialogState();
}

class _EggLogFormDialogState extends ConsumerState<EggLogFormDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedFlockId;
  String _collectionTime = 'total';
  DateTime _date = DateTime.now();

  final _totalController = TextEditingController();
  final _crackedController = TextEditingController(text: '0');
  final _dirtyController = TextEditingController(text: '0');
  final _incubationController = TextEditingController(text: '0');
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final existing = widget.initialLog;
    if (existing != null) {
      _selectedFlockId = existing.flockId;
      _collectionTime = existing.collectionTime;
      _date = existing.date;
      _totalController.text = existing.totalEggs.toString();
      _crackedController.text = existing.crackedEggs.toString();
      _dirtyController.text = existing.dirtyEggs.toString();
      _incubationController.text = existing.keptForIncubation.toString();
      _notesController.text = existing.notes;
    } else {
      _selectedFlockId = widget.initialFlockId;
    }
  }

  @override
  void dispose() {
    _totalController.dispose();
    _crackedController.dispose();
    _dirtyController.dispose();
    _incubationController.dispose();
    _notesController.dispose();
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
      title: Text(
        widget.initialLog != null
            ? '${context.tr('edit')} ${context.tr('eggs_collect')}'
            : context.tr('eggs_collect'),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (flocks.isEmpty)
                Text(
                  context.tr('flocks_empty'),
                  style: const TextStyle(color: Colors.red),
                )
              else
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
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _collectionTime,
                      decoration: InputDecoration(labelText: context.tr('time')),
                      items: [
                        DropdownMenuItem(
                          value: 'total',
                          child: Text(context.tr('eggs_time_total')),
                        ),
                        DropdownMenuItem(
                          value: 'morning',
                          child: Text(context.tr('eggs_time_morning')),
                        ),
                        DropdownMenuItem(
                          value: 'afternoon',
                          child: Text(context.tr('eggs_time_afternoon')),
                        ),
                        DropdownMenuItem(
                          value: 'evening',
                          child: Text(context.tr('eggs_time_evening')),
                        ),
                      ],
                      onChanged: (val) =>
                          setState(() => _collectionTime = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _totalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.tr('eggs_total'),
                  suffixIcon: const Icon(AppIcons.eggs, color: AppColors.warning),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter egg count';
                  final n = int.tryParse(val);
                  if (n == null || n < 0) return 'Must be positive number';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _crackedController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: context.tr('eggs_cracked'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _dirtyController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: context.tr('eggs_dirty'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _incubationController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.tr('eggs_incubation'),
                  helperText: context.tr('eggs_incubation_helper'),
                  prefixIcon: const Icon(AppIcons.incubator, color: AppColors.warning),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(labelText: context.tr('notes')),
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
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFlockId == null) return;

    final total = int.tryParse(_totalController.text) ?? 0;
    final cracked = int.tryParse(_crackedController.text) ?? 0;
    final dirty = int.tryParse(_dirtyController.text) ?? 0;
    final incubation = int.tryParse(_incubationController.text) ?? 0;

    int usable = total - cracked - dirty;
    if (usable < 0) usable = 0;

    final existing = widget.initialLog;
    final log = EggLog(
      id: existing?.id ?? const Uuid().v4(),
      flockId: _selectedFlockId!,
      date: existing?.date ?? _date,
      collectionTime: _collectionTime,
      totalEggs: total,
      crackedEggs: cracked,
      dirtyEggs: dirty,
      usableEggs: usable,
      keptForIncubation: incubation,
      notes: _notesController.text.trim(),
      createdAt: existing?.createdAt ?? DateTime.now(),
    );

    if (existing != null) {
      ref.read(eggLogsProvider.notifier).updateLog(log);
    } else {
      ref.read(eggLogsProvider.notifier).recordLog(log);
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.tr('success_saved'))));
  }
}
