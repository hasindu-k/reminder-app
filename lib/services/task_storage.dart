import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskStorage {
  static const _taskKey = 'tasks';

  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_taskKey, encoded);
  }

  static Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_taskKey);
    if (jsonStr == null) return [];

    final List decoded = jsonDecode(jsonStr);
    return decoded.map((data) => Task.fromJson(data)).toList();
  }
}
