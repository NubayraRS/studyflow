import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../task_provider.dart';

class DetailsScreen extends StatelessWidget {
  final Task task;

  const DetailsScreen({
    super.key,
    required this.task,
  });

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.blue;
    }
  }

  String _formatReminder(Reminder reminder) {
    switch (reminder) {
      case Reminder.none:
        return 'No reminder';
      case Reminder.oneHourBefore:
        return '1 hour before';
      case Reminder.oneDayBefore:
        return '1 day before';
    }
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Task?'),
          content: const Text(
            'This will permanently remove this task. You cannot undo this.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<TaskProvider>(
                  context,
                  listen: false,
                ).deleteTask(task.id);

                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dueTime = TimeOfDay(
      hour: task.dueHour,
      minute: task.dueMinute,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Chip(
              label: Text(
                task.type.name.toUpperCase(),
              ),
              backgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
            ),

            const Divider(height: 40),

            _buildInfoRow(
              Icons.book,
              'Course',
              task.course,
            ),

            _buildInfoRow(
              Icons.calendar_today,
              'Due Date',
              '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
            ),

            _buildInfoRow(
              Icons.access_time,
              'Due Time',
              dueTime.format(context),
            ),

            _buildInfoRow(
              Icons.priority_high,
              'Priority',
              task.priority.name.toUpperCase(),
              color: _getPriorityColor(task.priority),
            ),

            _buildInfoRow(
              Icons.notifications_active,
              'Reminder',
              _formatReminder(task.reminder),
            ),

            _buildInfoRow(
              Icons.info_outline,
              'Status',
              task.isCompleted ? 'Completed' : 'Pending',
              color: task.isCompleted
                  ? Colors.green
                  : Colors.orange,
            ),

            const Spacer(),

            if (!task.isCompleted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Provider.of<TaskProvider>(
                      context,
                      listen: false,
                    ).completeTask(task.id);

                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Mark as Completed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showDeleteDialog(context);
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete Task'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                  side: const BorderSide(
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}