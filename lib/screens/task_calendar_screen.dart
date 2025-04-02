import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../utils/duration_format.dart';

class TaskCalendarScreen extends StatefulWidget {
  final List<Task> tasks;

  const TaskCalendarScreen({super.key, required this.tasks});

  @override
  State<TaskCalendarScreen> createState() => _TaskCalendarScreenState();
}

class _TaskCalendarScreenState extends State<TaskCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, List<Task>> get _tasksByDate {
    final map = <DateTime, List<Task>>{};
    for (final task in widget.tasks) {
      task.history.forEach((dateStr, seconds) {
        final parts = dateStr.split('-');
        final date = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
        map.putIfAbsent(date, () => []).add(task);
      });
    }
    return map;
  }

  List<Task> _getTasksForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return _tasksByDate[normalized] ?? [];
  }

  bool _hasTasks(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return _tasksByDate.containsKey(normalized);
  }

  @override
  Widget build(BuildContext context) {
    final selectedTasks =
        _selectedDay != null ? _getTasksForDay(_selectedDay!) : [];

    return Scaffold(
      appBar: AppBar(title: const Text('Task Calendar')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (_hasTasks(day)) {
                  return Positioned(
                    bottom: 4,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blueAccent,
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedDay != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Tasks on ${DateFormat('yyyy-MM-dd').format(_selectedDay!)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: selectedTasks.length,
              itemBuilder: (context, index) {
                final task = selectedTasks[index];
                final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDay!);
                final duration = Duration(seconds: task.history[dateKey] ?? 0);
                return ListTile(
                  title: Text(task.title),
                  subtitle: Text('Duration: ${formatDuration(duration)}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
