import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../task_provider.dart';
import '../widgets/task_card.dart';

class CompletedScreen extends StatelessWidget {
  const CompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final completedTasks = taskProvider.completedTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Tasks'),
      ),
      body: completedTasks.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No completed tasks yet.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: completedTasks.length,
              itemBuilder: (context, index) {
                return TaskCard(
                  task: completedTasks[index],
                );
              },
            ),
    );
  }
}