import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/localization/app_translations.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../models/flock.dart';
import '../../providers/flock_provider.dart';
import '../../providers/settings_provider.dart';
import '../widgets/chicken_icon.dart';

class FlockFormScreen extends ConsumerStatefulWidget {
  final String? flockId;

  const FlockFormScreen({super.key, this.flockId});

  @override
  ConsumerState<FlockFormScreen> createState() => _FlockFormScreenState();
}

class _FlockFormScreenState extends ConsumerState<FlockFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _startCountController = TextEditingController();
  final _maleCountController = TextEditingController(text: '0');
  final _femaleCountController = TextEditingController(text: '0');
  final _unitPriceController = TextEditingController(text: '0.0');
  final _totalCostController = TextEditingController(text: '0.0');
  final _supplierController = TextEditingController();
  final _housingController = TextEditingController();
  final _notesController = TextEditingController();
  final _customSpeciesController = TextEditingController();

  String _species = 'chicken';
  String _purpose = 'layers';
  DateTime _acquisitionDate = DateTime.now();
  DateTime? _hatchDate;
  bool _isCustomSpecies = false;
  Flock? _existingFlock;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.flockId != null) {
        final flocks = ref.read(flocksProvider);
        final found = flocks.cast<Flock?>().firstWhere(
          (f) => f?.id == widget.flockId,
          orElse: () => null,
        );
        if (found != null) {
          setState(() {
            _existingFlock = found;
            _nameController.text = found.name;
            _breedController.text = found.breed;
            _startCountController.text = found.startCount.toString();
            _maleCountController.text = found.maleCount.toString();
            _femaleCountController.text = found.femaleCount.toString();
            _unitPriceController.text = found.purchasePricePerBird.toString();
            _totalCostController.text = found.totalPurchaseCost.toString();
            _supplierController.text = found.supplier;
            _housingController.text = found.housingLocation;
            _notesController.text = found.notes;
            _acquisitionDate = found.acquisitionDate;
            _hatchDate = found.hatchDate ?? found.acquisitionDate;
            _purpose = found.purpose;

            if ([
              'chicken',
              'quail',
              'duck',
              'turkey',
              'goose',
            ].contains(found.species)) {
              _species = found.species;
            } else {
              _species = 'other';
              _isCustomSpecies = true;
              _customSpeciesController.text = found.species;
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _startCountController.dispose();
    _maleCountController.dispose();
    _femaleCountController.dispose();
    _unitPriceController.dispose();
    _totalCostController.dispose();
    _supplierController.dispose();
    _housingController.dispose();
    _notesController.dispose();
    _customSpeciesController.dispose();
    super.dispose();
  }

  void _calculateTotalCost() {
    final count = int.tryParse(_startCountController.text) ?? 0;
    final price = double.tryParse(_unitPriceController.text) ?? 0.0;
    _totalCostController.text = (count * price).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(settingsProvider).currency;
    final isEditing = widget.flockId != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? context.tr('flocks_edit') : context.tr('flocks_add_new'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: context.tr('flocks_name'),
                  hintText: context.tr('flocks_name_hint'),
                  prefixIcon: const Icon(AppIcons.birds, color: AppColors.primaryTeal),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return context.tr('flocks_name_required');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Species & Custom Species
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _species,
                decoration: InputDecoration(
                  labelText: context.tr('flocks_species'),
                  prefixIcon: const Icon(AppIcons.chicken, color: AppColors.primaryTeal),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'chicken',
                    child: Row(
                      children: [
                        const ChickenIcon(size: 18, color: AppColors.primaryTeal),
                        const SizedBox(width: 8),
                        Text(context.tr('species_chicken')),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'quail',
                    child: Row(
                      children: [
                        const Icon(AppIcons.quail, size: 18, color: Color(0xFFD97706)),
                        const SizedBox(width: 8),
                        Text(context.tr('species_quail')),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'duck',
                    child: Row(
                      children: [
                        const Icon(AppIcons.duck, size: 18, color: Color(0xFF0284C7)),
                        const SizedBox(width: 8),
                        Text(context.tr('species_duck')),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'turkey',
                    child: Row(
                      children: [
                        const Icon(AppIcons.turkey, size: 18, color: Color(0xFF9A3412)),
                        const SizedBox(width: 8),
                        Text(context.tr('species_turkey')),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'goose',
                    child: Row(
                      children: [
                        const Icon(Icons.flutter_dash_outlined, size: 18, color: Color(0xFF059669)),
                        const SizedBox(width: 8),
                        Text(context.tr('species_goose')),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'other',
                    child: Row(
                      children: [
                        const Icon(AppIcons.birds, size: 18, color: Colors.blueGrey),
                        const SizedBox(width: 8),
                        Text(context.tr('species_other')),
                      ],
                    ),
                  ),
                ],
                onChanged: (val) {
                  setState(() {
                    _species = val!;
                    _isCustomSpecies = (_species == 'other');
                  });
                },
              ),
              if (_isCustomSpecies) ...[
                const SizedBox(height: 14),
                TextFormField(
                  controller: _customSpeciesController,
                  decoration: InputDecoration(
                    labelText: context.tr('species_custom_label'),
                  ),
                  validator: (val) {
                    if (_isCustomSpecies &&
                        (val == null || val.trim().isEmpty)) {
                      return context.tr('species_custom_label');
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 14),

              // Breed & Purpose
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _breedController,
                      decoration: InputDecoration(
                        labelText: context.tr('flocks_breed'),
                        hintText: context.tr('flocks_breed_hint'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _purpose,
                      decoration: InputDecoration(
                        labelText: context.tr('flocks_purpose'),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'layers',
                          child: Row(
                            children: [
                              const Icon(AppIcons.layers, size: 16, color: AppColors.warning),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  context.tr('purpose_layers'),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'meat',
                          child: Row(
                            children: [
                              const Icon(AppIcons.broilers, size: 16, color: AppColors.primaryTeal),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  context.tr('purpose_meat'),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'breeders',
                          child: Row(
                            children: [
                              const Icon(Icons.favorite_outline, size: 16, color: Color(0xFFE11D48)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  context.tr('purpose_breeders'),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'mixed',
                          child: Row(
                            children: [
                              const Icon(Icons.diversity_3_outlined, size: 16, color: Color(0xFF8B5CF6)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  context.tr('purpose_mixed'),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (val) => setState(() => _purpose = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Birth / Hatch Date Picker & Live Age Calibration
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF131D31)
                      : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primaryTeal.withAlpha(isDark ? 50 : 30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _hatchDate ?? _acquisitionDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );
                        if (picked != null) {
                          setState(() {
                            _hatchDate = picked;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: context.tr('flocks_hatch_date'),
                          prefixIcon: const Icon(Icons.cake_outlined, color: AppColors.primaryTeal),
                          helperText: context.tr('flocks_hatch_date_hint'),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('yyyy-MM-dd').format(_hatchDate ?? _acquisitionDate),
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            const Icon(Icons.edit_calendar_rounded, size: 18, color: AppColors.primaryTeal),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Live Age Calibration Badge
                    Builder(
                      builder: (ctx) {
                        final effective = _hatchDate ?? _acquisitionDate;
                        final days = DateTime.now().difference(effective).inDays.clamp(0, 99999);
                        final weeks = (days / 7).floor();
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryTeal.withAlpha(20),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.timelapse_rounded, size: 18, color: AppColors.primaryTeal),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${context.tr('flocks_age_preview')}: $weeks ${context.tr('flocks_weeks')} ($days ${context.tr('flocks_days')})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: AppColors.primaryTeal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Acquisition Date picker
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _acquisitionDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (picked != null) setState(() => _acquisitionDate = picked);
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: context.tr('flocks_acquisition_date'),
                    prefixIcon: const Icon(Icons.calendar_month_outlined),
                  ),
                  child: Text(
                    DateFormat('yyyy-MM-dd').format(_acquisitionDate),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Initial Count, Males, Females
              TextFormField(
                controller: _startCountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.tr('flocks_start_count'),
                  prefixIcon: const Icon(AppIcons.birds, color: AppColors.primaryTeal),
                ),
                onChanged: (_) => _calculateTotalCost(),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return context.tr('flocks_start_count_required');
                  }
                  final n = int.tryParse(val);
                  if (n == null || n <= 0) {
                    return context.tr('flocks_count_positive');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _maleCountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: context.tr('flocks_males'),
                        prefixIcon: const Icon(Icons.male),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _femaleCountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: context.tr('flocks_females'),
                        prefixIcon: const Icon(Icons.female),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Price per bird & total purchase cost
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _unitPriceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: context.tr('flocks_unit_price'),
                        suffixText: currency,
                      ),
                      onChanged: (_) => _calculateTotalCost(),
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
                        labelText: context.tr('flocks_total_cost'),
                        suffixText: currency,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Housing location & Supplier
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _housingController,
                      decoration: InputDecoration(
                        labelText: context.tr('flocks_housing'),
                        hintText: context.tr('flocks_housing_hint'),
                        prefixIcon: const Icon(AppIcons.coop, color: Color(0xFF8B5CF6)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _supplierController,
                      decoration: InputDecoration(
                        labelText: context.tr('flocks_supplier'),
                        hintText: context.tr('flocks_supplier_hint'),
                        prefixIcon: const Icon(Icons.storefront_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: context.tr('flocks_notes'),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text(context.tr('save')),
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final startCount = int.parse(_startCountController.text.trim());
    final maleCount = int.tryParse(_maleCountController.text.trim()) ?? 0;
    final femaleCount = int.tryParse(_femaleCountController.text.trim()) ?? 0;
    final unitPrice = double.tryParse(_unitPriceController.text.trim()) ?? 0.0;
    final totalCost =
        double.tryParse(_totalCostController.text.trim()) ??
        (startCount * unitPrice);
    final speciesFinal = _isCustomSpecies
        ? _customSpeciesController.text.trim()
        : _species;

    if (_existingFlock != null) {
      final updated = _existingFlock!.copyWith(
        name: _nameController.text.trim(),
        species: speciesFinal,
        breed: _breedController.text.trim(),
        purpose: _purpose,
        acquisitionDate: _acquisitionDate,
        hatchDate: _hatchDate,
        startCount: startCount,
        maleCount: maleCount,
        femaleCount: femaleCount,
        purchasePricePerBird: unitPrice,
        totalPurchaseCost: totalCost,
        supplier: _supplierController.text.trim(),
        housingLocation: _housingController.text.trim(),
        notes: _notesController.text.trim(),
      );
      await ref.read(flocksProvider.notifier).updateFlock(updated);
    } else {
      final newFlock = Flock(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        species: speciesFinal,
        breed: _breedController.text.trim(),
        purpose: _purpose,
        acquisitionDate: _acquisitionDate,
        hatchDate: _hatchDate,
        startCount: startCount,
        currentCount: startCount,
        maleCount: maleCount,
        femaleCount: femaleCount,
        purchasePricePerBird: unitPrice,
        totalPurchaseCost: totalCost,
        supplier: _supplierController.text.trim(),
        housingLocation: _housingController.text.trim(),
        notes: _notesController.text.trim(),
        createdAt: DateTime.now(),
      );
      await ref.read(flocksProvider.notifier).addFlock(newFlock);
    }

    if (mounted) {
      context.pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.tr('success_saved'))));
    }
  }
}
