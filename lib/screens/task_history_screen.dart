import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/duration_format.dart';

class TaskHistoryScreen extends StatefulWidget {
  final List<Task> tasks;

  const TaskHistoryScreen({required this.tasks});

  @override
  State<TaskHistoryScreen> createState() => _TaskHistoryScreenState();
}

class _TaskHistoryScreenState extends State<TaskHistoryScreen> {
  String _search = '';
  String? _selectedDate;

  List<String> get allDates {
    final all = <String>{};
    for (var task in widget.tasks) {
      all.addAll(task.history.keys);
    }
    final sorted = all.toList()..sort((a, b) => b.compareTo(a));
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = widget.tasks.where((task) {
      final matchesName =
          task.title.toLowerCase().contains(_search.toLowerCase());
      final hasDate =
          _selectedDate == null || task.history.containsKey(_selectedDate);
      return matchesName && hasDate;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Task History')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search Tasks',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _search = value),
            ),
          ),
          if (allDates.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Filter by Date'),
                value: _selectedDate,
                items: [null, ...allDates].map((date) {
                  return DropdownMenuItem(
                    value: date,
                    child: Text(date ?? 'All Dates'),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedDate = val),
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                final time = _selectedDate != null
                    ? Duration(seconds: task.history[_selectedDate!] ?? 0)
                    : task.history.entries.fold<Duration>(
                        Duration.zero,
                        (prev, e) => prev + Duration(seconds: e.value),
                      );
                return ListTile(
                  title: Text(task.title),
                  subtitle: Text(_selectedDate ?? 'Total Time'),
                  trailing: Text(formatDuration(time)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
