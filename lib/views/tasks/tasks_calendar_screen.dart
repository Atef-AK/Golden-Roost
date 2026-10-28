import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/localization/app_translations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/responsive.dart';
import '../../core/utils/formatters.dart';
import '../../models/task_item.dart';
import '../../providers/feed_provider.dart';
import '../../providers/task_provider.dart';
import '../widgets/empty_state_view.dart';
import 'task_form_dialog.dart';

class TasksCalendarScreen extends ConsumerStatefulWidget {
  const TasksCalendarScreen({super.key});

  @override
  ConsumerState<TasksCalendarScreen> createState() =>
      _TasksCalendarScreenState();
}

class _TasksCalendarScreenState extends ConsumerState<TasksCalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredTasks = tasks.where((t) {
      if (_selectedCategory != 'all' && t.category != _selectedCategory) {
        return false;
      }
      return t.dueDate.year == _selectedDate.year &&
          t.dueDate.month == _selectedDate.month &&
          t.dueDate.day == _selectedDate.day;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('tasks_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: context.tr('tasks_add'),
            onPressed: () => TaskFormDialog.show(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_tasks',
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_task),
        label: Text(context.tr('tasks_add')),
        onPressed: () => TaskFormDialog.show(context),
      ),
      body: ResponsiveContainer(
        maxWidth: 1000,
        child: Column(
          children: [
            // Horizontal date strip
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.cardLight,
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
              ),
              child: SizedBox(
                height: 72,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: 14,
                  itemBuilder: (ctx, i) {
                    final date = DateTime.now()
                        .subtract(const Duration(days: 3))
                        .add(Duration(days: i));
                    final isSelected =
                        date.year == _selectedDate.year &&
                        date.month == _selectedDate.month &&
                        date.day == _selectedDate.day;
                    final isToday =
                        date.year == DateTime.now().year &&
                        date.month == DateTime.now().month &&
                        date.day == DateTime.now().day;

                    final localeCode = Localizations.localeOf(
                      context,
                    ).languageCode;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedDate = date),
                      child: Container(
                        width: 58,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryTeal
                              : (isToday
                                    ? AppColors.primaryTeal.withAlpha(20)
                                    : (isDark
                                          ? AppColors.cardDark
                                          : AppColors.pageBackgroundLight)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryTeal
                                : (isToday
                                      ? AppColors.primaryTeal
                                      : (isDark
                                            ? AppColors.borderDark
                                            : AppColors.borderLight)),
                            width: isToday || isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                DateFormat(
                                  'EEE',
                                  localeCode,
                                ).format(date).toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? Colors.white.withAlpha(200)
                                      : (isDark
                                            ? AppColors.textMutedDark
                                            : AppColors.textMutedLight),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppFormatters.toWesternNumerals(
                                date.day.toString(),
                              ),
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimaryLight),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Category filter strip
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  _buildCatChip('all', context.tr('tasks_cat_all')),
                  const SizedBox(width: 8),
                  _buildCatChip('feeding', context.tr('tasks_cat_feeding')),
                  const SizedBox(width: 8),
                  _buildCatChip('watering', context.tr('tasks_cat_watering')),
                  const SizedBox(width: 8),
                  _buildCatChip(
                    'vaccination',
                    context.tr('tasks_cat_vaccination'),
                  ),
                  const SizedBox(width: 8),
                  _buildCatChip('cleaning', context.tr('tasks_cat_cleaning')),
                  const SizedBox(width: 8),
                  _buildCatChip(
                    'incubation',
                    context.tr('tasks_cat_incubation'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            Expanded(
              child: filteredTasks.isEmpty
                  ? EmptyStateView(
                      icon: Icons.event_available,
                      title:
                          '${context.tr('tasks_no_tasks_for')} ${AppFormatters.formatDate(_selectedDate, locale: Localizations.localeOf(context).languageCode)}',
                      description: context.tr('tasks_clear_desc'),
                      actionLabel: context.tr('tasks_add'),
                      onAction: () => TaskFormDialog.show(context),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                      itemCount: filteredTasks.length,
                      itemBuilder: (ctx, index) {
                        final task = filteredTasks[index];
                        final isVaccine = task.category == 'vaccination';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: PremiumCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: task.isCompleted,
                                  activeColor: AppColors.primaryTeal,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  onChanged: (_) async {
                                    final res = await ref
                                        .read(tasksProvider.notifier)
                                        .toggleComplete(task);
                                    if (res != null && context.mounted) {
                                      ref
                                          .read(feedInventoryProvider.notifier)
                                          .loadInventory();
                                      ref.invalidate(feedTransactionsProvider);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          backgroundColor: const Color(
                                            0xFF0F766E,
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          content: Row(
                                            children: [
                                              const Icon(
                                                Icons.check_circle_rounded,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  '${context.tr('feed_task_completed_deducted')}: ${res.deductedKg.toStringAsFixed(1)} kg (${res.feedName})',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task.title,
                                        style: TextStyle(
                                          decoration: task.isCompleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: task.isCompleted
                                              ? (isDark
                                                    ? AppColors.textMutedDark
                                                    : AppColors.textMutedLight)
                                              : (isDark
                                                    ? AppColors.textPrimaryDark
                                                    : AppColors
                                                          .textPrimaryLight),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          StatusBadge(
                                            label: context.trTaskCategory(
                                              task.category,
                                            ),
                                            variant: isVaccine
                                                ? BadgeVariant.error
                                                : BadgeVariant.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '${task.dueTime ?? context.tr('tasks_anytime')} • ${context.trRecurrence(task.recurrence)}${task.notes.isNotEmpty ? ' • ${task.notes}' : ''}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isDark
                                                    ? AppColors.textMutedDark
                                                    : AppColors.textMutedLight,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.more_vert, size: 20),
                                  color: isDark
                                      ? AppColors.textMutedDark
                                      : AppColors.textMutedLight,
                                  onPressed: () =>
                                      _showTaskOptions(context, task),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCatChip(String value, String label) {
    final isSelected = _selectedCategory == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected
              ? Colors.white
              : (isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight),
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primaryTeal,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      side: BorderSide(
        color: isSelected
            ? AppColors.primaryTeal
            : (isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (sel) {
        if (sel) setState(() => _selectedCategory = value);
      },
    );
  }

  void _showTaskOptions(BuildContext context, TaskItem task) {
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
                leading: const Icon(
                  Icons.edit_outlined,
                  color: AppColors.primaryTeal,
                ),
                title: Text(context.tr('edit')),
                subtitle: Text(context.tr('tasks_edit_subtitle')),
                onTap: () {
                  Navigator.pop(ctx);
                  TaskFormDialog.show(context, initialTask: task);
                },
              ),
              ListTile(
                leading: const Icon(Icons.update, color: AppColors.primaryTeal),
                title: Text(context.tr('tasks_postpone')),
                subtitle: Text(context.tr('tasks_move_tomorrow')),
                onTap: () {
                  ref.read(tasksProvider.notifier).postponeTask(task, days: 1);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppColors.semanticError,
                ),
                title: Text(
                  context.tr('delete'),
                  style: const TextStyle(color: AppColors.semanticError),
                ),
                onTap: () {
                  ref.read(tasksProvider.notifier).deleteTask(task.id);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
