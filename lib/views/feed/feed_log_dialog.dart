import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/localization/app_translations.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../models/feed.dart';
import '../../providers/feed_provider.dart';
import '../../providers/flock_provider.dart';

class FeedLogDialog extends ConsumerStatefulWidget {
  final String? initialFlockId;

  const FeedLogDialog({super.key, this.initialFlockId});

  static Future<void> show(BuildContext context, {String? initialFlockId}) {
    return showDialog(
      context: context,
      builder: (ctx) => FeedLogDialog(initialFlockId: initialFlockId),
    );
  }

  @override
  ConsumerState<FeedLogDialog> createState() => _FeedLogDialogState();
}

class _FeedLogDialogState extends ConsumerState<FeedLogDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedFeedId;
  String? _selectedFlockId;
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  bool _useGrams = false;

  @override
  void initState() {
    super.initState();
    _selectedFlockId = widget.initialFlockId;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feeds = ref.watch(feedInventoryProvider);
    final flocks = ref
        .watch(flocksProvider)
        .where((f) => !f.isArchived)
        .toList();

    if (_selectedFeedId == null && feeds.isNotEmpty) {
      _selectedFeedId = feeds.first.id;
    }
    if (_selectedFlockId == null && flocks.isNotEmpty) {
      _selectedFlockId = flocks.first.id;
    }

    final selectedFeed = feeds.cast<FeedItem?>().firstWhere(
      (f) => f?.id == _selectedFeedId,
      orElse: () => null,
    );
    final selectedFlock = flocks.cast<dynamic>().firstWhere(
      (f) => f.id == _selectedFlockId,
      orElse: () => null,
    );

    // Calculate per-bird preview
    double perBirdGrams = 0.0;
    final qtyEntered = double.tryParse(_quantityController.text) ?? 0.0;
    final qtyKg = _useGrams ? (qtyEntered / 1000.0) : qtyEntered;
    if (selectedFlock != null && selectedFlock.currentCount > 0 && qtyKg > 0) {
      perBirdGrams = (qtyKg * 1000.0) / selectedFlock.currentCount;
    }

    return AlertDialog(
      title: Text(context.tr('feed_log_consumption')),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (feeds.isEmpty)
                Text(
                  context.tr('feed_empty_hint'),
                  style: const TextStyle(color: Colors.red),
                )
              else
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _selectedFeedId,
                  decoration: InputDecoration(
                    labelText: context.tr('feed_type'),
                    prefixIcon: const Icon(AppIcons.feed, color: AppColors.semanticSuccess),
                    helperText: selectedFeed != null
                        ? '${context.tr('feed_available_stock_label')}: ${selectedFeed.currentStockKg.toStringAsFixed(1)} ${context.tr('kg')}'
                        : null,
                  ),
                  items: feeds.map((f) {
                    return DropdownMenuItem(
                      value: f.id,
                      child: Text(
                        '${f.name} (${f.currentStockKg.toStringAsFixed(1)} ${context.tr('kg')})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedFeedId = val),
                ),
              const SizedBox(height: 12),
              if (flocks.isNotEmpty)
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _selectedFlockId,
                  decoration: InputDecoration(
                    labelText: context.tr('flocks_name'),
                    prefixIcon: const Icon(AppIcons.birds, color: AppColors.primaryTeal),
                  ),
                  items: flocks.map((f) {
                    return DropdownMenuItem(
                      value: f.id,
                      child: Text(
                        '${f.name} (${f.currentCount} ${context.tr('birds')})',
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
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: context.tr('quantity'),
                        prefixIcon: const Icon(Icons.scale_outlined),
                        suffixText: _useGrams ? context.tr('g') : context.tr('kg'),
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (val) {
                        if (val == null || val.isEmpty) return context.tr('feed_qty_required');
                        final n = double.tryParse(val);
                        if (n == null || n <= 0) {
                          return context.tr('flocks_count_positive');
                        }
                        final enteredKg = _useGrams ? (n / 1000.0) : n;
                        if (selectedFeed != null &&
                            enteredKg > selectedFeed.currentStockKg) {
                          return '${context.tr('feed_available_stock_label')}: ${selectedFeed.currentStockKg.toStringAsFixed(1)} kg';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(context.tr('kg')),
                    selected: !_useGrams,
                    onSelected: (sel) => setState(() => _useGrams = !sel),
                  ),
                  const SizedBox(width: 4),
                  ChoiceChip(
                    label: Text(context.tr('g')),
                    selected: _useGrams,
                    onSelected: (sel) => setState(() => _useGrams = sel),
                  ),
                ],
              ),
              if (perBirdGrams > 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${context.tr('dash_daily_burn')}: ${perBirdGrams.toStringAsFixed(1)} ${context.tr('g')} / ${context.tr('birds')}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
          onPressed: feeds.isEmpty ? null : _save,
          child: Text(context.tr('save')),
        ),
      ],
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFeedId == null) return;

    final n = double.tryParse(_quantityController.text) ?? 0.0;
    final qtyKg = _useGrams ? (n / 1000.0) : n;

    final tx = FeedTransaction(
      id: const Uuid().v4(),
      feedId: _selectedFeedId!,
      flockId: _selectedFlockId,
      date: DateTime.now(),
      type: 'consumption',
      quantityKg: qtyKg,
      notes: _notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    ref.read(feedInventoryProvider.notifier).recordTransaction(tx);
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.tr('success_saved'))));
  }
}
