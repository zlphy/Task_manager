// Main entry point for Task Manager application
import 'dart:io';

import 'package:task_manager/exceptions.dart';
import 'package:task_manager/result.dart';
import 'package:task_manager/storage.dart';
import 'package:task_manager/task.dart';
import 'package:task_manager/task_manager.dart';

// Make main async to use await
Future<void> main(List<String> arguments) async {
  print('Welcome to Task Manager CLI!');
  await runApp();
}

Future<void> runApp() async {
  final manager = TaskManager();

  String readLine(String prompt) {
    stdout.write(prompt);
    return stdin.readLineSync() ?? '';
  }

  Future<void> addTaskFlow() async {
    final id = readLine('Enter task id: ').trim();
    final title = readLine('Enter title: ').trim();
    final description = readLine('Enter description (optional): ').trim();
    if (id.isEmpty || title.isEmpty) {
      print('Id and title are required.');
      return;
    }
    final res = manager.addTaskSafe(
      Task(
        id: id,
        title: title,
        description: description.isEmpty ? null : description,
      ),
    );
    res
        .onSuccess((t) => print('Added: $t'))
        .onFailure((e) => print('Add failed: $e'));
  }

  Future<void> editTaskFlow() async {
    final id = readLine('Enter task id to edit: ').trim();
    if (id.isEmpty) {
      print('Id is required.');
      return;
    }
    final title = readLine('Enter new title (leave blank to keep): ');
    final description = readLine(
      'Enter new description (leave blank to keep): ',
    );
    final titleValue = title.trim().isEmpty ? null : title.trim();
    final descValue = description.trim().isEmpty ? null : description.trim();
    manager
        .editTask(id, title: titleValue, description: descValue)
        .onSuccess((t) => print('Edited: $t'))
        .onFailure((e) => print('Edit failed: $e'));
  }

  void searchFlow() {
    final q = readLine('Enter title query: ').trim();
    if (q.isEmpty) {
      print('Query is empty');
      return;
    }
    final results = manager.findByTitle(q);
    if (results.isEmpty) {
      print('No tasks found.');
      return;
    }
    for (final t in results) print(t);
  }

  void deleteFlow() {
    final id = readLine('Enter task id to delete: ').trim();
    if (id.isEmpty) {
      print('Id is required.');
      return;
    }
    manager
        .deleteTask(id)
        .onSuccess((t) => print('Deleted: $t'))
        .onFailure((e) => print('Delete failed: $e'));
  }

  Future<void> saveFlow() async {
    final p = readLine(
      'Enter file path to save (leave blank for ./tasks.json): ',
    ).trim();
    final path = p.isEmpty
        ? '${Directory.current.path}${Platform.pathSeparator}tasks.json'
        : p;
    try {
      await manager.saveToFile(path);
      print('Saved to $path');
    } catch (e) {
      print('Save failed: $e');
    }
  }

  Future<void> loadFlow() async {
    final p = readLine(
      'Enter file path to load (leave blank for ./tasks.json): ',
    ).trim();
    final path = p.isEmpty
        ? '${Directory.current.path}${Platform.pathSeparator}tasks.json'
        : p;
    try {
      await manager.loadFromFile(path);
      print('Loaded tasks:');
      for (final t in manager.allTasks()) print(t);
    } catch (e) {
      print('Load failed: $e');
    }
  }

  while (true) {
    print('\n=== Task Manager Menu ===');
    print('1) Add Task');
    print('2) Edit Task');
    print('3) Search Tasks by Title');
    print('4) Delete Task');
    print('5) Save Tasks to JSON');
    print('6) Load Tasks from JSON');
    print('7) List all tasks');
    print('0) Exit');
    final choice = readLine('Choose an option: ').trim();
    switch (choice) {
      case '1':
        await addTaskFlow();
        break;
      case '2':
        await editTaskFlow();
        break;
      case '3':
        searchFlow();
        break;
      case '4':
        deleteFlow();
        break;
      case '5':
        await saveFlow();
        break;
      case '6':
        await loadFlow();
        break;
      case '7':
        print('\nAll tasks:');
        for (final t in manager.allTasks()) print(t);
        break;
      case '0':
        print('Goodbye');
        return;
      default:
        print('Unknown option');
    }
  }
}
