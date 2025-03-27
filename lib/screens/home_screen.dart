import 'dart:async';
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../widgets/task_tile.dart';
import '../utils/duration_format.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Duration timerValue = Duration.zero;
  bool isRunning = false;
  Timer? _timer;

  List<Task> tasks = [
    Task(title: 'Write Journal'),
    Task(title: 'Exercise'),
    Task(title: 'Read Book'),
  ];

  Task? activeTask;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    setState(() => isRunning = !isRunning);

    if (isRunning) {
      _timer = Timer.periodic(Duration(seconds: 1), (_) {
        if (activeTask != null) {
          setState(() {
            timerValue += Duration(seconds: 1);
            activeTask!.timeSpent += Duration(seconds: 1);
          });
        }
      });
    } else {
      _timer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Task Timer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (activeTask != null)
              Text(
                'Current Task: ${activeTask!.title}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            const SizedBox(height: 8),
            Text(
              formatDuration(timerValue),
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _toggleTimer,
              icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
              label: Text(isRunning ? 'Stop' : 'Start'),
            ),
            const SizedBox(height: 32),
            Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return TaskTile(
                    task: task,
                    isActive: task == activeTask,
                    onTap: () {
                      setState(() {
                        activeTask = task;
                        timerValue = activeTask!.timeSpent;
                        isRunning = false;
                        _timer?.cancel();
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
