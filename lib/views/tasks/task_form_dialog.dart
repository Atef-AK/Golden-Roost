import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/localization/app_translations.dart';
import '../../models/task_item.dart';
import '../../providers/task_provider.dart';
import '../../providers/flock_provider.dart';

class TaskFormDialog extends ConsumerStatefulWidget {
  final String? initialFlockId;
  final String initialCategory;
  final TaskItem? initialTask;

  const TaskFormDialog({
    super.key,
    this.initialFlockId,
    this.initialCategory = 'general',
    this.initialTask,
  });

  static Future<void> show(
    BuildContext context, {
    String? initialFlockId,
    String initialCategory = 'general',
    TaskItem? initialTask,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => TaskFormDialog(
        initialFlockId: initialFlockId,
        initialCategory: initialCategory,
        initialTask: initialTask,
      ),
    );
  }

  @override
  ConsumerState<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends ConsumerState<TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  late String _category;
  String? _selectedFlockId;
  DateTime _dueDate = DateTime.now();
  TimeOfDay _dueTime = const TimeOfDay(hour: 8, minute: 30);
  String _recurrence = 'none';

  @override
  void initState() {
    super.initState();
    final existing = widget.initialTask;
    if (existing != null) {
      _titleController.text = existing.title;
      _notesController.text = existing.notes;
      _category = existing.category;
      _selectedFlockId = existing.flockId;
      _dueDate = existing.dueDate;
      _recurrence = existing.recurrence;
      if (existing.dueTime != null && existing.dueTime!.contains(':')) {
        final parts = existing.dueTime!.split(':');
        _dueTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 8,
          minute: int.tryParse(parts[1]) ?? 30,
        );
      }
    } else {
      _category = widget.initialCategory;
      _selectedFlockId = widget.initialFlockId;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flocks = ref.watch(flocksProvider);

    return AlertDialog(
      title: Text(
        widget.initialTask != null
            ? '${context.tr('edit')} ${context.tr('tasks_new_title')}'
            : context.tr('tasks_add'),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: context.tr('tasks_new_title'),
                  hintText: context.tr('tasks_title_hint'),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter task title';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _category,
                decoration: InputDecoration(
                  labelText: context.tr('finance_category'),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'feeding',
                    child: Text(context.trTaskCategory('feeding')),
                  ),
                  DropdownMenuItem(
                    value: 'watering',
                    child: Text(context.trTaskCategory('watering')),
                  ),
                  DropdownMenuItem(
                    value: 'cleaning',
                    child: Text(context.trTaskCategory('cleaning')),
                  ),
                  DropdownMenuItem(
                    value: 'vaccination',
                    child: Text(context.trTaskCategory('vaccination')),
                  ),
                  DropdownMenuItem(
                    value: 'weighing',
                    child: Text(context.trTaskCategory('weighing')),
                  ),
                  DropdownMenuItem(
                    value: 'incubation',
                    child: Text(context.trTaskCategory('incubation')),
                  ),
                  DropdownMenuItem(
                    value: 'maintenance',
                    child: Text(context.trTaskCategory('maintenance')),
                  ),
                  DropdownMenuItem(
                    value: 'general',
                    child: Text(context.trTaskCategory('general')),
                  ),
                ],
                onChanged: (val) => setState(() => _category = val!),
              ),
              const SizedBox(height: 12),
              if (flocks.isNotEmpty)
                DropdownButtonFormField<String?>(
                  isExpanded: true,
                  initialValue: _selectedFlockId,
                  decoration: InputDecoration(
                    labelText: context.tr('tasks_assign_flock'),
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
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 8,
                        ),
                      ),
                      icon: const Icon(Icons.calendar_today, size: 14),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(_dueDate),
                          maxLines: 1,
                        ),
                      ),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _dueDate,
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 30),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) setState(() => _dueDate = picked);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 8,
                        ),
                      ),
                      icon: const Icon(Icons.access_time, size: 14),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(_dueTime.format(context), maxLines: 1),
                      ),
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _dueTime,
                        );
                        if (picked != null) setState(() => _dueTime = picked);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _recurrence,
                decoration: InputDecoration(
                  labelText: context.tr('tasks_repeat'),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'none',
                    child: Text(context.trRecurrence('none')),
                  ),
                  DropdownMenuItem(
                    value: 'daily',
                    child: Text(context.trRecurrence('daily')),
                  ),
                  DropdownMenuItem(
                    value: 'weekly',
                    child: Text(context.trRecurrence('weekly')),
                  ),
                  DropdownMenuItem(
                    value: 'biweekly',
                    child: Text(context.trRecurrence('biweekly')),
                  ),
                  DropdownMenuItem(
                    value: 'monthly',
                    child: Text(context.trRecurrence('monthly')),
                  ),
                ],
                onChanged: (val) => setState(() => _recurrence = val!),
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
        ElevatedButton(onPressed: _save, child: Text(context.tr('save'))),
      ],
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final dueDateTime = DateTime(
      _dueDate.year,
      _dueDate.month,
      _dueDate.day,
      _dueTime.hour,
      _dueTime.minute,
    );

    final existing = widget.initialTask;
    final task = TaskItem(
      id: existing?.id ?? const Uuid().v4(),
      flockId: _selectedFlockId,
      title: _titleController.text.trim(),
      category: _category,
      dueDate: dueDateTime,
      dueTime:
          '${_dueTime.hour.toString().padLeft(2, '0')}:${_dueTime.minute.toString().padLeft(2, '0')}',
      recurrence: _recurrence,
      notes: _notesController.text.trim(),
      isCompleted: existing?.isCompleted ?? false,
      completedAt: existing?.completedAt,
      createdAt: existing?.createdAt ?? DateTime.now(),
    );

    if (existing != null) {
      ref.read(tasksProvider.notifier).updateTask(task);
    } else {
      ref.read(tasksProvider.notifier).addTask(task);
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.tr('success_saved'))));
  }
}
