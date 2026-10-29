import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/task.dart' hide Priority;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz_data.initializeTimeZones();

    final currentTimeZone = await FlutterTimezone.getLocalTimezone();

    tz.setLocalLocation(
      tz.getLocation(currentTimeZone.identifier),
    );

    const androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
    );

    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();

    await androidPlugin?.requestExactAlarmsPermission();
  }

  static Future<void> scheduleNotification(Task task) async {
    if (task.reminder == Reminder.none) {
      return;
    }

    final dueDateTime = DateTime(
      task.dueDate.year,
      task.dueDate.month,
      task.dueDate.day,
      task.dueHour,
      task.dueMinute,
    );

    DateTime reminderTime;

    switch (task.reminder) {
      case Reminder.oneHourBefore:
        reminderTime = dueDateTime.subtract(
          const Duration(hours: 1),
        );
        break;

      case Reminder.oneDayBefore:
        reminderTime = dueDateTime.subtract(
          const Duration(days: 1),
        );
        break;

      case Reminder.none:
        return;
    }

    if (!reminderTime.isAfter(DateTime.now())) {
      return;
    }

    final notificationId =
        task.id.hashCode & 0x7fffffff;

    try {
      await _notificationsPlugin.zonedSchedule(
        notificationId,
        'StudyFlow Reminder',
        '${task.title} for ${task.course} is due soon!',
        tz.TZDateTime.from(
          reminderTime,
          tz.local,
        ),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'studyflow_tasks',
            'Academic Reminders',
            channelDescription:
                'Reminders for upcoming StudyFlow assignments and quizzes',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode:
            AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (error) {
      debugPrint(
        'Notification could not be scheduled: $error',
      );
    }
  }

  static Future<void> cancelNotification(
    String taskId,
  ) async {
    final notificationId =
        taskId.hashCode & 0x7fffffff;

    try {
      await _notificationsPlugin.cancel(
        notificationId,
      );
    } catch (error) {
      debugPrint(
        'Notification could not be cancelled: $error',
      );
    }
  }
}