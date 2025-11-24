import 'dart:convert';
import 'dart:io';
import 'package:task_manager/task.dart';

class Storage {
  final String path;

  Storage(this.path);

  Future<void> saveTasks(List<Task> tasks) async {
    final file = File(path);
    final list = tasks.map((t) => t.toJson()).toList();
    await file.writeAsString(jsonEncode(list), flush: true);
  }

  Future<List<Task>> loadTasks() async {
    final file = File(path);
    if (!await file.exists()) return [];
    final content = await file.readAsString();
    if (content.trim().isEmpty) return [];
    final jsonList = jsonDecode(content) as List<dynamic>;
    return jsonList
        .map((e) => Task.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
