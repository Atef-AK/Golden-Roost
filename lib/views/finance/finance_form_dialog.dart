import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/localization/app_translations.dart';
import '../../models/finance.dart';
import '../../providers/finance_provider.dart';
import '../../providers/flock_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/theme/app_icons.dart';

class FinanceFormDialog extends ConsumerStatefulWidget {
  final String initialType; // 'expense' or 'income'
  final FinancialTransaction? initialTransaction;

  const FinanceFormDialog({
    super.key,
    this.initialType = 'expense',
    this.initialTransaction,
  });

  static Future<void> show(
    BuildContext context, {
    String initialType = 'expense',
    FinancialTransaction? initialTransaction,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => FinanceFormDialog(
        initialType: initialType,
        initialTransaction: initialTransaction,
      ),
    );
  }

  @override
  ConsumerState<FinanceFormDialog> createState() => _FinanceFormDialogState();
}

class _FinanceFormDialogState extends ConsumerState<FinanceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  late String _category;
  String? _selectedFlockId;
  bool _isCapital = false;
  String _paymentStatus = 'paid';

  final _amountController = TextEditingController();
  final _amountPaidController = TextEditingController();
  final _notesController = TextEditingController();

  final List<String> _expenseCategories = [
    'feed',
    'chicks',
    'adult_birds',
    'vaccines',
    'medicines',
    'bedding',
    'electricity',
    'water',
    'equipment',
    'incubators',
    'heating',
    'maintenance',
    'transport',
    'packaging',
    'miscellaneous',
  ];

  final List<String> _incomeCategories = [
    'sales_eggs',
    'sales_birds',
    'sales_meat',
    'sales_chicks',
    'sales_manure',
    'miscellaneous',
  ];

  @override
  void initState() {
    super.initState();
    final existing = widget.initialTransaction;
    if (existing != null) {
      _type = existing.type;
      _category = existing.category;
      _selectedFlockId = existing.flockId;
      _isCapital = existing.isCapitalInvestment;
      _paymentStatus = existing.paymentStatus;
      _amountController.text = existing.amount.toString();
      _amountPaidController.text = existing.amountPaid.toString();
      _notesController.text = existing.notes;
    } else {
      _type = widget.initialType;
      _category = _type == 'expense' ? 'feed' : 'sales_eggs';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountPaidController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flocks = ref.watch(flocksProvider);
    final currency = ref.watch(settingsProvider).currency;
    final categories = _type == 'expense'
        ? _expenseCategories
        : _incomeCategories;

    return AlertDialog(
      title: Text(
        widget.initialTransaction != null
            ? '${context.tr('edit')} ${context.tr('nav_finances')}'
            : (_type == 'expense'
                ? context.tr('finance_add_expense')
                : context.tr('finance_add_income')),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'expense',
                    label: Text(context.tr('finance_expenses')),
                  ),
                  ButtonSegment(
                    value: 'income',
                    label: Text(context.tr('finance_income')),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (val) {
                  setState(() {
                    _type = val.first;
                    _category = _type == 'expense' ? 'feed' : 'sales_eggs';
                  });
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                isExpanded: true,
                key: ValueKey('cat_$_category'),
                initialValue: _category,
                decoration: InputDecoration(
                  labelText: context.tr('finance_category'),
                ),
                items: categories.map((cat) {
                  final (icon, color) = AppIcons.getFinanceCategoryVisual(cat);
                  return DropdownMenuItem(
                    value: cat,
                    child: Row(
                      children: [
                        Icon(icon, size: 18, color: color),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            context.trFinanceCategory(cat),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _category = val!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: context.tr('finance_amount'),
                  suffixText: currency,
                ),
                onChanged: (val) {
                  if (_paymentStatus == 'paid') {
                    _amountPaidController.text = val;
                  }
                },
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter amount';
                  final n = double.tryParse(val);
                  if (n == null || n <= 0) return 'Must be positive';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              if (flocks.isNotEmpty)
                DropdownButtonFormField<String?>(
                  isExpanded: true,
                  initialValue: _selectedFlockId,
                  decoration: InputDecoration(
                    labelText: context.tr('finance_link_flock'),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(context.tr('finance_no_flock')),
                    ),
                    ...flocks.map(
                      (f) => DropdownMenuItem(value: f.id, child: Text(f.name)),
                    ),
                  ],
                  onChanged: (val) => setState(() => _selectedFlockId = val),
                ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _paymentStatus,
                decoration: InputDecoration(
                  labelText: context.tr('finance_payment_status'),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'paid',
                    child: Text(context.tr('finance_paid')),
                  ),
                  DropdownMenuItem(
                    value: 'unpaid',
                    child: Text(context.tr('finance_unpaid')),
                  ),
                  DropdownMenuItem(
                    value: 'partial',
                    child: Text(context.tr('finance_partial')),
                  ),
                ],
                onChanged: (val) {
                  setState(() {
                    _paymentStatus = val!;
                    if (_paymentStatus == 'paid') {
                      _amountPaidController.text = _amountController.text;
                    } else if (_paymentStatus == 'unpaid') {
                      _amountPaidController.text = '0';
                    }
                  });
                },
              ),
              if (_paymentStatus == 'partial') ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountPaidController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: context.tr('finance_amount_paid'),
                    suffixText: currency,
                  ),
                ),
              ],
              if (_type == 'expense') ...[
                const SizedBox(height: 8),
                SwitchListTile(
                  title: Text(
                    context.tr('finance_is_capital'),
                    style: const TextStyle(fontSize: 13),
                  ),
                  subtitle: Text(
                    context.tr('finance_capital_sub'),
                    style: const TextStyle(fontSize: 11),
                  ),
                  value: _isCapital,
                  onChanged: (val) => setState(() => _isCapital = val),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
              const SizedBox(height: 8),
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
        ElevatedButton(onPressed: _save, child: Text(context.tr('save'))),
      ],
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    double amountPaid = amount;
    if (_paymentStatus == 'unpaid') {
      amountPaid = 0.0;
    } else if (_paymentStatus == 'partial') {
      amountPaid = double.tryParse(_amountPaidController.text) ?? amount;
    }

    final existing = widget.initialTransaction;
    final tx = FinancialTransaction(
      id: existing?.id ?? const Uuid().v4(),
      type: _type,
      category: _category,
      amount: amount,
      date: existing?.date ?? DateTime.now(),
      flockId: _selectedFlockId,
      isCapitalInvestment: _isCapital,
      paymentStatus: _paymentStatus,
      amountPaid: amountPaid,
      notes: _notesController.text.trim(),
      createdAt: existing?.createdAt ?? DateTime.now(),
    );

    if (existing != null) {
      ref.read(financesProvider.notifier).updateTransaction(tx);
    } else {
      ref.read(financesProvider.notifier).addTransaction(tx);
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.tr('success_saved'))));
  }
}
