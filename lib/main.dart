import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

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
      home: HomeScreen(),
    );
  }
}
