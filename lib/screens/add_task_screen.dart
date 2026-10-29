import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../task_provider.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _courseController = TextEditingController();

  TaskType _selectedType = TaskType.assignment;
  Priority _selectedPriority = Priority.medium;
  Reminder _selectedReminder = Reminder.none;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _saveTask() {
    if (_titleController.text.isEmpty ||
        _courseController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
        ),
      );
      return;
    }

    final newTask = Task(
      id: DateTime.now().toString(),
      title: _titleController.text,
      type: _selectedType,
      course: _courseController.text,
      dueDate: _selectedDate!,
      dueHour: _selectedTime!.hour,
      dueMinute: _selectedTime!.minute,
      priority: _selectedPriority,
      reminder: _selectedReminder,
    );

    Provider.of<TaskProvider>(
      context,
      listen: false,
    ).addTask(newTask);

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _courseController,
              decoration: const InputDecoration(
                labelText: 'Course / Subject',
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Type',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                ChoiceChip(
                  label: const Text('Assignment'),
                  selected:
                      _selectedType == TaskType.assignment,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType =
                          TaskType.assignment;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Quiz'),
                  selected:
                      _selectedType == TaskType.quiz,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = TaskType.quiz;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(
                      Icons.calendar_today,
                    ),
                    label: Text(
                      _selectedDate == null
                          ? 'Select Date'
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(
                      Icons.access_time,
                    ),
                    label: Text(
                      _selectedTime == null
                          ? 'Select Time'
                          : _selectedTime!
                              .format(context),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              'Priority',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            DropdownButton<Priority>(
              value: _selectedPriority,
              isExpanded: true,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPriority = value;
                  });
                }
              },
              items: Priority.values.map(
                (priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(
                      priority.name.toUpperCase(),
                    ),
                  );
                },
              ).toList(),
            ),

            const SizedBox(height: 20),

            const Text(
              'Reminder',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            DropdownButton<Reminder>(
              value: _selectedReminder,
              isExpanded: true,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedReminder = value;
                  });
                }
              },
              items: const [
                DropdownMenuItem(
                  value: Reminder.none,
                  child: Text('No reminder'),
                ),
                DropdownMenuItem(
                  value: Reminder.oneHourBefore,
                  child: Text('1 hour before'),
                ),
                DropdownMenuItem(
                  value: Reminder.oneDayBefore,
                  child: Text('1 day before'),
                ),
              ],
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  backgroundColor:
                      Theme.of(context)
                          .colorScheme
                          .primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Save Task',
                  style: TextStyle(
                    fontSize: 18,
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