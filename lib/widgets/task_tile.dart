import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isActive;

  const TaskTile({super.key, 
    required this.task,
    required this.onTap,
    this.onLongPress,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.task_alt_outlined),
      title: Text(task.title),
      subtitle: Text('Time: ${task.timeSpent.inMinutes} min'),
      trailing: Chip(label: Text(task.interval)),
      tileColor: isActive ? Colors.blue.shade50 : null,
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
