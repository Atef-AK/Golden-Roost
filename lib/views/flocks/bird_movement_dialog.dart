import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/localization/app_translations.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/chicken_icon.dart';
import '../../models/bird_movement.dart';
import '../../providers/flock_provider.dart';
import '../../providers/settings_provider.dart';

class BirdMovementDialog extends ConsumerStatefulWidget {
  final String? initialFlockId;
  final String initialType; // 'mortality', 'cull', 'sale', 'purchase'

  const BirdMovementDialog({
    super.key,
    this.initialFlockId,
    this.initialType = 'mortality',
  });

  static Future<void> show(
    BuildContext context, {
    String? initialFlockId,
    String initialType = 'mortality',
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => BirdMovementDialog(
        initialFlockId: initialFlockId,
        initialType: initialType,
      ),
    );
  }

  @override
  ConsumerState<BirdMovementDialog> createState() => _BirdMovementDialogState();
}

class _BirdMovementDialogState extends ConsumerState<BirdMovementDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedFlockId;
  late String _type;

  final _countController = TextEditingController();
  final _malesController = TextEditingController(text: '0');
  final _femalesController = TextEditingController(text: '0');
  final _unitPriceController = TextEditingController();
  final _reasonOrBuyerController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedFlockId = widget.initialFlockId;
    _type = widget.initialType;
  }

  @override
  void dispose() {
    _countController.dispose();
    _malesController.dispose();
    _femalesController.dispose();
    _unitPriceController.dispose();
    _reasonOrBuyerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flocks = ref
        .watch(flocksProvider)
        .where((f) => !f.isArchived)
        .toList();
    final currency = ref.watch(settingsProvider).currency;

    if (_selectedFlockId == null && flocks.isNotEmpty) {
      _selectedFlockId = flocks.first.id;
    }

    final isSale = _type == 'sale';
    final isPurchase = _type == 'purchase';

    return AlertDialog(
      title: Text(_dialogTitle),
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
                        '${f.name} (${f.currentCount} ${context.tr('movement_live')})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedFlockId = val),
                ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _type,
                decoration: InputDecoration(labelText: context.tr('movement_event_type')),
                items: [
                  DropdownMenuItem(
                    value: 'mortality',
                    child: Row(
                      children: [
                        const Icon(AppIcons.mortality, size: 18, color: AppColors.error),
                        const SizedBox(width: 8),
                        Text(context.tr('movement_mortality')),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'cull',
                    child: Row(
                      children: [
                        const Icon(Icons.remove_circle_outline, size: 18, color: AppColors.warning),
                        const SizedBox(width: 8),
                        Text(context.tr('movement_cull')),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'sale',
                    child: Row(
                      children: [
                        const Icon(AppIcons.sale, size: 18, color: AppColors.semanticSuccess),
                        const SizedBox(width: 8),
                        Text(context.tr('movement_sale')),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'purchase',
                    child: Row(
                      children: [
                        const ChickenIcon(size: 18, color: AppColors.primaryTeal),
                        const SizedBox(width: 8),
                        Text(context.tr('movement_purchase')),
                      ],
                    ),
                  ),
                ],
                onChanged: (val) => setState(() => _type = val!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _countController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.tr('movement_num_birds'),
                  suffixIcon: const Padding(
                    padding: EdgeInsets.all(12),
                    child: ChickenIcon(size: 18, color: AppColors.primaryTeal),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Enter number of birds';
                  }
                  final n = int.tryParse(val);
                  if (n == null || n <= 0) {
                    return 'Must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _malesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: context.tr('flocks_males'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _femalesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: context.tr('flocks_females'),
                      ),
                    ),
                  ),
                ],
              ),
              if (isSale || isPurchase) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _unitPriceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: '${context.tr('movement_price_per_bird')} ($currency)',
                    suffixText: currency,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _reasonOrBuyerController,
                decoration: InputDecoration(
                  labelText: isSale
                      ? context.tr('movement_buyer_name')
                      : context.tr('movement_reason_diagnosis'),
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

  String get _dialogTitle {
    switch (_type) {
      case 'mortality':
        return context.tr('flocks_record_mortality');
      case 'cull':
        return '${context.tr('record')} ${context.tr('movement_cull')}';
      case 'sale':
        return '${context.tr('record')} ${context.tr('movement_sale')}';
      case 'purchase':
        return '${context.tr('record')} ${context.tr('movement_purchase')}';
      default:
        return context.tr('flocks_movements_title');
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFlockId == null) return;

    final count = int.tryParse(_countController.text) ?? 0;
    final males = int.tryParse(_malesController.text) ?? 0;
    final females = int.tryParse(_femalesController.text) ?? 0;
    final unitPrice = double.tryParse(_unitPriceController.text) ?? 0.0;
    final total = count * unitPrice;

    final movement = BirdMovement(
      id: const Uuid().v4(),
      flockId: _selectedFlockId!,
      date: DateTime.now(),
      type: _type,
      count: count,
      maleCount: males,
      femaleCount: females,
      unitPrice: unitPrice,
      totalAmount: total,
      reasonOrBuyer: _reasonOrBuyerController.text.trim(),
      notes: _notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    ref.read(flocksProvider.notifier).recordMovement(movement);
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.tr('success_saved'))));
  }
}
