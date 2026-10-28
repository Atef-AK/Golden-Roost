import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/localization/app_translations.dart';
import '../../core/theme/app_icons.dart';
import '../../models/incubation.dart';
import '../../providers/incubation_provider.dart';
import '../../providers/flock_provider.dart';
import '../../providers/settings_provider.dart';

class BatchFormScreen extends ConsumerStatefulWidget {
  const BatchFormScreen({super.key});

  @override
  ConsumerState<BatchFormScreen> createState() => _BatchFormScreenState();
}

class _BatchFormScreenState extends ConsumerState<BatchFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _incubatorNameController = TextEditingController(text: 'Incubator 1');
  final _eggsCountController = TextEditingController();
  final _eggCostController = TextEditingController(text: '0.0');
  final _totalCostController = TextEditingController(text: '0.0');
  final _durationController = TextEditingController(text: '21');
  final _notesController = TextEditingController();

  String _species = 'chicken';
  String? _selectedFlockId;
  DateTime _setDate = DateTime.now();
  late DateTime _expectedHatchDate;
  DateTime? _candlingDate;

  final Map<String, int> _standardDurations = {
    'chicken': 21,
    'quail': 17,
    'duck': 28,
    'turkey': 28,
    'goose': 30,
    'other': 21,
  };

  @override
  void initState() {
    super.initState();
    _expectedHatchDate = _setDate.add(const Duration(days: 21));
    _candlingDate = _setDate.add(const Duration(days: 7));
  }

  @override
  void dispose() {
    _incubatorNameController.dispose();
    _eggsCountController.dispose();
    _eggCostController.dispose();
    _totalCostController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onSpeciesChanged(String sp) {
    setState(() {
      _species = sp;
      final dur = _standardDurations[sp] ?? 21;
      _durationController.text = dur.toString();
      _expectedHatchDate = _setDate.add(Duration(days: dur));
    });
  }

  void _recalcCosts() {
    final count = int.tryParse(_eggsCountController.text) ?? 0;
    final cost = double.tryParse(_eggCostController.text) ?? 0.0;
    _totalCostController.text = (count * cost).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final flocks = ref
        .watch(flocksProvider)
        .where((f) => !f.isArchived)
        .toList();
    final currency = ref.watch(settingsProvider).currency;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('incubator_new_batch'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _species,
                decoration: InputDecoration(
                  labelText: context.tr('flocks_species'),
                  prefixIcon: const Icon(Icons.pets),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'chicken',
                    child: Text(
                      '${context.tr('species_chicken')} (21 ${context.tr('flocks_days')})',
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'quail',
                    child: Text(
                      '${context.tr('species_quail')} (17 ${context.tr('flocks_days')})',
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'duck',
                    child: Text(
                      '${context.tr('species_duck')} (28 ${context.tr('flocks_days')})',
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'turkey',
                    child: Text(
                      '${context.tr('species_turkey')} (28 ${context.tr('flocks_days')})',
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'goose',
                    child: Text(
                      '${context.tr('species_goose')} (30 ${context.tr('flocks_days')})',
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'other',
                    child: Text(
                      '${context.tr('species_other')} (${context.tr('recurrence_custom')})',
                    ),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) _onSpeciesChanged(val);
                },
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _incubatorNameController,
                decoration: InputDecoration(
                  labelText: context.tr('incubator_machine_model'),
                  hintText: context.tr('incubator_machine_hint'),
                  prefixIcon: const Icon(Icons.wb_incandescent_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Enter incubator name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              if (flocks.isNotEmpty)
                DropdownButtonFormField<String?>(
                  isExpanded: true,
                  initialValue: _selectedFlockId,
                  decoration: InputDecoration(
                    labelText: context.tr('incubator_egg_source'),
                    prefixIcon: const Icon(AppIcons.birds),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(context.tr('incubator_egg_source_ext')),
                    ),
                    ...flocks.map(
                      (f) => DropdownMenuItem(
                        value: f.id,
                        child: Text(
                          '${f.name} (${context.trSpecies(f.species)})',
                        ),
                      ),
                    ),
                  ],
                  onChanged: (val) => setState(() => _selectedFlockId = val),
                ),
              const SizedBox(height: 14),

              // Set Date Picker
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _setDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (picked != null) {
                    setState(() {
                      _setDate = picked;
                      final dur = int.tryParse(_durationController.text) ?? 21;
                      _expectedHatchDate = _setDate.add(Duration(days: dur));
                      _candlingDate = _setDate.add(const Duration(days: 7));
                    });
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: context.tr('incubator_set_date'),
                    prefixIcon: const Icon(Icons.calendar_month),
                  ),
                  child: Text(DateFormat('yyyy-MM-dd').format(_setDate)),
                ),
              ),
              const SizedBox(height: 14),

              // Eggs count & duration
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _eggsCountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: context.tr('incubator_eggs_set'),
                        prefixIcon: const Icon(Icons.egg),
                      ),
                      onChanged: (_) => _recalcCosts(),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Enter eggs count';
                        }
                        final n = int.tryParse(val);
                        if (n == null || n <= 0) {
                          return 'Must be positive';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: context.tr('incubator_duration_label'),
                        suffixText: context.tr('flocks_days'),
                      ),
                      onChanged: (val) {
                        final dur = int.tryParse(val) ?? 21;
                        setState(() {
                          _expectedHatchDate = _setDate.add(
                            Duration(days: dur),
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Expected hatch date & Candling date
              Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: context.tr('incubator_expected_hatch'),
                        helperText: context.tr('incubator_auto_calc'),
                      ),
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(_expectedHatchDate),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: context.tr('incubator_candling_date'),
                        helperText: context.tr('incubator_candling_hint'),
                      ),
                      child: Text(
                        _candlingDate != null
                            ? DateFormat('dd/MM/yyyy').format(_candlingDate!)
                            : 'Not set',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Cost
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _eggCostController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: context.tr('incubator_unit_cost'),
                        suffixText: currency,
                      ),
                      onChanged: (_) => _recalcCosts(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _totalCostController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: context.tr('incubator_total_cost'),
                        suffixText: currency,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: context.tr('flocks_notes'),
                  hintText: context.tr('incubator_notes_hint'),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.wb_incandescent),
                  label: Text(context.tr('incubator_start_batch_btn')),
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final eggsSet = int.parse(_eggsCountController.text.trim());
    final unitCost = double.tryParse(_eggCostController.text.trim()) ?? 0.0;
    final totalCost =
        double.tryParse(_totalCostController.text.trim()) ??
        (eggsSet * unitCost);
    final duration = int.tryParse(_durationController.text.trim()) ?? 21;

    final batch = IncubationBatch(
      id: const Uuid().v4(),
      flockId: _selectedFlockId,
      species: _species,
      incubatorName: _incubatorNameController.text.trim(),
      setDate: _setDate,
      eggsSetCount: eggsSet,
      eggUnitCost: unitCost,
      totalEggCost: totalCost,
      expectedHatchDate: _expectedHatchDate,
      candlingDate: _candlingDate,
      durationDays: duration,
      status: 'incubating',
      notes: _notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    await ref.read(incubationBatchesProvider.notifier).addBatch(batch);

    if (mounted) {
      context.pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.tr('success_saved'))));
    }
  }
}
