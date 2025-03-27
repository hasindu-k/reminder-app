import 'package:flutter/material.dart';

void main() => runApp(TaskTimerApp());

class TaskTimerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Timer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Duration timerValue = Duration.zero;
  bool isRunning = false;

  List<String> tasks = ['Write Journal', 'Exercise', 'Read Book'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Task Timer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Timer Display
            Text(
              _formatDuration(timerValue),
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Start / Stop Button
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isRunning = !isRunning;
                });
              },
              icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
              label: Text(isRunning ? 'Stop' : 'Start'),
            ),

            const SizedBox(height: 32),
            Divider(),

            // Task List
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.task_alt_outlined),
                    title: Text(tasks[index]),
                    trailing: Chip(label: Text("Daily")),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inHours}:$minutes:$seconds';
  }
}
