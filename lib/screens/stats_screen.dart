import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/duration_format.dart';

class StatsScreen extends StatelessWidget {
  final List<Task> tasks;

  const StatsScreen({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final sorted = [...tasks]
      ..sort((a, b) => b.timeSpent.compareTo(a.timeSpent));

    return Scaffold(
      appBar: AppBar(title: Text('Task Stats')),
      body: ListView.builder(
        itemCount: sorted.length,
        itemBuilder: (context, index) {
          final task = sorted[index];
          return ListTile(
            title: Text(task.title),
            subtitle: Text('Interval: ${task.interval}'),
            trailing: Text(formatDuration(task.timeSpent)),
          );
        },
      ),
    );
  }
}
