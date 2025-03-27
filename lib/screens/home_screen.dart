import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../widgets/task_tile.dart';
import '../utils/duration_format.dart';
import '../services/task_storage.dart';
import '../services/notification_service.dart';
import 'task_history_screen.dart';
import 'task_calendar_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Duration timerValue = Duration.zero;
  bool isRunning = false;
  Timer? _timer;

  List<Task> tasks = [];
  Task? activeTask;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final loaded = await TaskStorage.loadTasks();
    final prefs = await SharedPreferences.getInstance();

    final now = DateTime.now();
    final todayKey = DateFormat('yyyy-MM-dd').format(now);
    final lastOpened = prefs.getString('lastOpenedDate');

    if (lastOpened != todayKey) {
      for (var task in loaded) {
        if (task.interval == 'daily' && task.timeSpent.inSeconds > 0) {
          final resetKey = lastOpened ?? todayKey;
          task.history[resetKey] = task.timeSpent.inSeconds;
          task.timeSpent = Duration.zero;
        }
      }
      await prefs.setString('lastOpenedDate', todayKey);
      await TaskStorage.saveTasks(loaded);
    }

    setState(() => tasks = loaded);

    // Schedule reminders for daily tasks at 8:00 AM
    for (var task in tasks) {
      if (task.interval == 'daily') {
        await NotificationService.scheduleDailyReminder(
          id: task.hashCode,
          title: 'Reminder: ${task.title}',
          body: 'Don’t forget to work on your "${task.title}" task!',
          hour: 8,
          minute: 0,
        );
      }
    }
  }

  void _saveTasks() => TaskStorage.saveTasks(tasks);

  void _toggleTimer() {
    setState(() => isRunning = !isRunning);

    if (isRunning) {
      _timer = Timer.periodic(Duration(seconds: 1), (_) {
        if (activeTask != null) {
          setState(() {
            timerValue += Duration(seconds: 1);
            activeTask!.timeSpent += Duration(seconds: 1);
            _saveTasks();
          });
        }
      });
    } else {
      _timer?.cancel();
    }
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    String selectedInterval = 'daily';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Task Title'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedInterval,
                items: ['daily', 'weekly'].map((interval) {
                  return DropdownMenuItem(
                    value: interval,
                    child: Text(interval),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedInterval = value;
                  }
                },
                decoration: const InputDecoration(labelText: 'Interval'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                if (title.isNotEmpty) {
                  final newTask =
                      Task(title: title, interval: selectedInterval);
                  setState(() {
                    tasks.add(newTask);
                    _saveTasks();
                  });

                  if (selectedInterval == 'daily') {
                    await NotificationService.scheduleDailyReminder(
                      id: newTask.hashCode,
                      title: 'Reminder: ${newTask.title}',
                      body:
                          'Don’t forget to work on your "${newTask.title}" task!',
                      hour: 8,
                      minute: 0,
                    );
                  }

                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showTaskOptions(BuildContext context, Task task) {
    final titleController = TextEditingController(text: task.title);
    String selectedInterval = task.interval;

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Edit Task', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Task Title'),
              ),
              DropdownButtonFormField<String>(
                value: selectedInterval,
                items: ['daily', 'weekly']
                    .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                    .toList(),
                onChanged: (val) => selectedInterval = val ?? selectedInterval,
                decoration: InputDecoration(labelText: 'Interval'),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.delete),
                    label: Text('Delete'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      setState(() {
                        tasks.remove(task);
                        if (activeTask == task) activeTask = null;
                        _saveTasks();
                      });
                      Navigator.pop(context);
                    },
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.save),
                    label: Text('Save'),
                    onPressed: () {
                      setState(() {
                        task.title = titleController.text.trim();
                        task.interval = selectedInterval;
                        _saveTasks();
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Timer'),
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => TaskHistoryScreen(tasks: tasks)),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.calendar_month),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TaskCalendarScreen(tasks: tasks),
                ),
              );
            },
          ),
        ],
      ),
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
                  return GestureDetector(
                    onLongPress: () => _showTaskOptions(context, task),
                    child: TaskTile(
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
                      onLongPress: () => _showTaskOptions(context, task),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
