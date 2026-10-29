import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'models/task.dart';
import 'services/notification_service.dart';

class TaskProvider extends ChangeNotifier {
  final Box<Task> _taskBox = Hive.box<Task>('tasks');

  List<Task> get allTasks => _taskBox.values.toList();

  List<Task> get tasksDueToday {
    final now = DateTime.now();

    return allTasks.where((task) {
      return !task.isCompleted &&
          task.dueDate.year == now.year &&
          task.dueDate.month == now.month &&
          task.dueDate.day == now.day;
    }).toList()
      ..sort(_sortTasks);
  }

  List<Task> get upcomingTasks {
    final now = DateTime.now();
    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    return allTasks.where((task) {
      final taskDate = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );

      return !task.isCompleted && taskDate.isAfter(today);
    }).toList()
      ..sort(_sortTasks);
  }

  List<Task> get completedTasks {
    return allTasks.where((task) => task.isCompleted).toList()
      ..sort(_sortTasks);
  }

  int get totalTasksCount => allTasks.length;

  int get completedTasksCount =>
      allTasks.where((task) => task.isCompleted).length;

  double get completionPercentage {
    if (allTasks.isEmpty) {
      return 0.0;
    }

    return completedTasksCount / totalTasksCount;
  }

  int _sortTasks(Task a, Task b) {
    final aDateTime = DateTime(
      a.dueDate.year,
      a.dueDate.month,
      a.dueDate.day,
      a.dueHour,
      a.dueMinute,
    );

    final bDateTime = DateTime(
      b.dueDate.year,
      b.dueDate.month,
      b.dueDate.day,
      b.dueHour,
      b.dueMinute,
    );

    final dateCompare = aDateTime.compareTo(bDateTime);

    if (dateCompare != 0) {
      return dateCompare;
    }

    return b.priority.index.compareTo(a.priority.index);
  }

  Future<void> addTask(Task task) async {
    await _taskBox.put(task.id, task);

    await NotificationService.scheduleNotification(task);

    notifyListeners();
  }

  Future<void> completeTask(String id) async {
    final task = _taskBox.get(id);

    if (task != null) {
      task.isCompleted = true;
      await task.save();

      await NotificationService.cancelNotification(id);

      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    await _taskBox.delete(id);

    await NotificationService.cancelNotification(id);

    notifyListeners();
  }
}