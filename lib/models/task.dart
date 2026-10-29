import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
enum TaskType {
  @HiveField(0)
  assignment,

  @HiveField(1)
  quiz,
}

@HiveType(typeId: 1)
enum Priority {
  @HiveField(0)
  low,

  @HiveField(1)
  medium,

  @HiveField(2)
  high,
}

@HiveType(typeId: 2)
enum Reminder {
  @HiveField(0)
  none,

  @HiveField(1)
  oneHourBefore,

  @HiveField(2)
  oneDayBefore,
}

@HiveType(typeId: 3)
class Task extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final TaskType type;

  @HiveField(3)
  final String course;

  @HiveField(4)
  final DateTime dueDate;

  @HiveField(5)
  final int dueHour;

  @HiveField(6)
  final int dueMinute;

  @HiveField(7)
  final Priority priority;

  @HiveField(8)
  final Reminder reminder;

  @HiveField(9)
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.type,
    required this.course,
    required this.dueDate,
    required this.dueHour,
    required this.dueMinute,
    required this.priority,
    required this.reminder,
    this.isCompleted = false,
  });
}