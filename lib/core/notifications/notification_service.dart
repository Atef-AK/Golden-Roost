import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../models/task_item.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  NotificationService._init();

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();
    } catch (e) {
      debugPrint('Failed to initialize timezone database: $e');
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open Golden Roost',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
    );

    try {
      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );
      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to initialize notifications: $e');
    }
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;

    if (Platform.isAndroid) {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await androidImplementation
          ?.requestNotificationsPermission();
      return granted ?? false;
    } else if (Platform.isIOS || Platform.isMacOS) {
      final darwinImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final granted = await darwinImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return true;
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'golden_roost_alerts',
      'Golden Roost Farm Alerts',
      channelDescription:
          'Immediate alerts for low stock, health warnings and incubation',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    try {
      await _notificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error showing instant notification: $e');
    }
  }

  Future<void> scheduleTaskReminder(TaskItem task) async {
    // Generate deterministic positive integer ID from task.id hash
    final notifId = task.id.hashCode & 0x7FFFFFFF;

    const androidDetails = AndroidNotificationDetails(
      'golden_roost_tasks',
      'Golden Roost Scheduled Tasks',
      channelDescription:
          'Reminders for vaccinations, feeding, watering and maintenance',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    int hour = 8;
    int minute = 0;
    if (task.dueTime != null && task.dueTime!.contains(':')) {
      final parts = task.dueTime!.split(':');
      hour = int.tryParse(parts[0]) ?? 8;
      minute = int.tryParse(parts[1]) ?? 0;
    }

    try {
      // 1. Daily recurring task (e.g. daily feeding, watering)
      if (task.recurrence == 'daily') {
        await _notificationsPlugin.periodicallyShow(
          id: notifId,
          title: 'Golden Roost: ${task.title}',
          body:
              'Daily routine task (${task.category.toUpperCase()}) due at ${task.dueTime ?? '08:00'}',
          repeatInterval: RepeatInterval.daily,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: 'task:${task.id}',
        );
        debugPrint(
          'Scheduled daily recurring notification #$notifId for "${task.title}"',
        );
        return;
      }

      // 2. Weekly recurring task (e.g. weekly cleaning, disinfection)
      if (task.recurrence == 'weekly') {
        await _notificationsPlugin.periodicallyShow(
          id: notifId,
          title: 'Golden Roost: ${task.title}',
          body:
              'Weekly routine task (${task.category.toUpperCase()}) due at ${task.dueTime ?? '08:00'}',
          repeatInterval: RepeatInterval.weekly,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: 'task:${task.id}',
        );
        debugPrint(
          'Scheduled weekly recurring notification #$notifId for "${task.title}"',
        );
        return;
      }

      // 3. Exact date/time schedule for one-off, biweekly or monthly tasks
      final targetDateTime = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
        hour,
        minute,
      ).subtract(Duration(minutes: task.reminderMinutesBefore));

      if (targetDateTime.isAfter(DateTime.now())) {
        final tzTarget = tz.TZDateTime.from(targetDateTime, tz.local);
        await _notificationsPlugin.zonedSchedule(
          id: notifId,
          title: 'Golden Roost: ${task.title}',
          body:
              'Task due in ${task.reminderMinutesBefore}m (${task.category.toUpperCase()})',
          scheduledDate: tzTarget,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: 'task:${task.id}',
        );
        debugPrint(
          'Scheduled exact notification #$notifId for "${task.title}" at $targetDateTime',
        );
      }
    } catch (e) {
      debugPrint('Error scheduling task reminder #$notifId: $e');
    }
  }

  Future<void> cancelTaskReminder(TaskItem task) async {
    final notifId = task.id.hashCode & 0x7FFFFFFF;
    await cancelNotification(notifId);
  }

  Future<void> syncAllTaskReminders(List<TaskItem> tasks) async {
    for (final task in tasks) {
      if (!task.isCompleted) {
        await scheduleTaskReminder(task);
      }
    }
  }

  Future<void> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id: id);
    } catch (e) {
      debugPrint('Error canceling notification: $e');
    }
  }

  Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('Error canceling all notifications: $e');
    }
  }
}
