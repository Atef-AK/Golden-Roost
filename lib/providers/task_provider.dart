import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../core/database/database_helper.dart';
import '../core/notifications/notification_service.dart';
import '../models/task_item.dart';
import '../models/vaccination.dart';
import '../models/health_record.dart';

import '../core/services/feed_automation_service.dart';

final tasksProvider = StateNotifierProvider<TasksNotifier, List<TaskItem>>((
  ref,
) {
  return TasksNotifier();
});

final vaccinationsProvider =
    StateNotifierProvider<VaccinationsNotifier, List<VaccinationSchedule>>((
      ref,
    ) {
      return VaccinationsNotifier();
    });

final healthRecordsProvider =
    StateNotifierProvider<HealthRecordsNotifier, List<HealthRecord>>((ref) {
      return HealthRecordsNotifier();
    });

class TasksNotifier extends StateNotifier<List<TaskItem>> {
  TasksNotifier() : super([]) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    final list = await DatabaseHelper.instance.getTasks();
    state = list;
    // Keep active reminders synchronized in background
    NotificationService.instance.syncAllTaskReminders(list);
  }

  Future<void> addTask(TaskItem task) async {
    await DatabaseHelper.instance.insertTask(task);
    // Schedule notification for task (recurring or exact)
    await NotificationService.instance.scheduleTaskReminder(task);
    await loadTasks();
  }

  Future<FeedDeductionResult?> toggleComplete(TaskItem task) async {
    final completing = !task.isCompleted;
    final updated = task.copyWith(
      isCompleted: completing,
      completedAt: completing ? DateTime.now() : null,
    );
    await DatabaseHelper.instance.updateTask(updated);

    FeedDeductionResult? feedResult;

    if (completing) {
      await NotificationService.instance.cancelTaskReminder(task);

      // Auto feed deduction if category or title indicates feeding
      final cat = task.category.toLowerCase().trim();
      final title = task.title.toLowerCase().trim();
      final isFeeding = cat == 'feeding' ||
          cat == 'nourriture' ||
          title.contains('feed') ||
          title.contains('علف') ||
          title.contains('تغذية') ||
          title.contains('nourrir');

      if (isFeeding) {
        feedResult = await FeedAutomationService.instance.deductForCompletedTask(task);
      }

      // Automatically generate next recurring instance if recurring
      if (task.recurrence != 'none') {
        final nextDueDate = switch (task.recurrence) {
          'daily' => task.dueDate.add(const Duration(days: 1)),
          'weekly' => task.dueDate.add(const Duration(days: 7)),
          'biweekly' => task.dueDate.add(const Duration(days: 14)),
          'monthly' => DateTime(
            task.dueDate.year,
            task.dueDate.month + 1,
            task.dueDate.day,
          ),
          _ => null,
        };

        if (nextDueDate != null) {
          final nextTask = task.copyWith(
            id: const Uuid().v4(),
            dueDate: nextDueDate,
            isCompleted: false,
            completedAt: null,
            createdAt: DateTime.now(),
          );
          await DatabaseHelper.instance.insertTask(nextTask);
          await NotificationService.instance.scheduleTaskReminder(nextTask);
        }
      }
    } else {
      // Re-activated task, re-schedule notification
      await NotificationService.instance.scheduleTaskReminder(updated);
    }

    await loadTasks();
    return feedResult;
  }

  Future<void> postponeTask(TaskItem task, {int days = 1}) async {
    final updated = task.copyWith(
      dueDate: task.dueDate.add(Duration(days: days)),
    );
    await DatabaseHelper.instance.updateTask(updated);
    await NotificationService.instance.scheduleTaskReminder(updated);
    await loadTasks();
  }

  Future<void> updateTask(TaskItem task) async {
    await DatabaseHelper.instance.updateTask(task);
    await NotificationService.instance.scheduleTaskReminder(task);
    await loadTasks();
  }

  Future<void> deleteTask(String id) async {
    final notifId = id.hashCode & 0x7FFFFFFF;
    await NotificationService.instance.cancelNotification(notifId);
    await DatabaseHelper.instance.deleteTask(id);
    await loadTasks();
  }
}

class VaccinationsNotifier extends StateNotifier<List<VaccinationSchedule>> {
  VaccinationsNotifier() : super([]) {
    loadVaccinations();
  }

  Future<void> loadVaccinations({String? flockId}) async {
    final list = await DatabaseHelper.instance.getVaccinations(
      flockId: flockId,
    );
    state = list;
  }

  Future<void> addVaccination(VaccinationSchedule vax) async {
    await DatabaseHelper.instance.insertVaccination(vax);

    // Also automatically create a calendar task for this vaccination!
    await DatabaseHelper.instance.insertTask(
      TaskItem(
        id: 'task_vax_${vax.id}',
        flockId: vax.flockId,
        title: 'Vaccination: ${vax.vaccineName} (${vax.administrationRoute})',
        category: 'vaccination',
        dueDate: vax.targetDate,
        dueTime: '08:00',
        notes: vax.notes,
        createdAt: DateTime.now(),
      ),
    );

    await loadVaccinations();
  }

  Future<void> updateVaccination(VaccinationSchedule vax) async {
    await DatabaseHelper.instance.updateVaccination(vax);
    await loadVaccinations();
  }

  Future<void> deleteVaccination(String id) async {
    await DatabaseHelper.instance.deleteVaccination(id);
    await loadVaccinations();
  }
}

class HealthRecordsNotifier extends StateNotifier<List<HealthRecord>> {
  HealthRecordsNotifier() : super([]) {
    loadHealthRecords();
  }

  Future<void> loadHealthRecords({String? flockId}) async {
    final list = await DatabaseHelper.instance.getHealthRecords(
      flockId: flockId,
    );
    state = list;
  }

  Future<void> addHealthRecord(HealthRecord record) async {
    await DatabaseHelper.instance.insertHealthRecord(record);
    await loadHealthRecords();
  }
}
