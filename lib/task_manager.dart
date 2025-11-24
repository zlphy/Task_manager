import 'package:task_manager/task.dart';
import 'package:task_manager/result.dart';
import 'package:task_manager/exceptions.dart';
import 'package:task_manager/storage.dart';

class TaskManager {
  final Map<String, Task> _tasks = {};

  // Add task (throws on duplicate)
  Task addTask(Task task) {
    if (_tasks.containsKey(task.id)) {
      throw DuplicateTaskException('Task with id ${task.id} already exists');
    }
    _tasks[task.id] = task;
    return task;
  }

  // Safe add returning Result
  Result<Task> addTaskSafe(Task task) {
    try {
      final added = addTask(task);
      return Success<Task>(added);
    } catch (e) {
      return Failure<Task>(e as Object);
    }
  }

  // Edit task by id
  Result<Task> editTask(String id, {String? title, String? description}) {
    final existing = _tasks[id];
    if (existing == null)
      return Failure(TaskNotFoundException('No task with id $id'));
    final updated = existing.copyWith(
      title: title ?? existing.title,
      description: description ?? existing.description,
    );
    _tasks[id] = updated;
    return Success(updated);
  }

  // Find by id (nullable)
  Task? findTask(String id) => _tasks[id];

  // Compatibility alias used by some callers/tests
  Task? findTaskById(String id) => findTask(id);

  // Safe find returning Result
  Result<Task> findTaskSafe(String id) {
    final t = findTask(id);
    if (t == null)
      return Failure<Task>(TaskNotFoundException('Task $id not found'));
    return Success<Task>(t);
  }

  // Search by title (case-insensitive substring)
  List<Task> findByTitle(String query) {
    final q = query.toLowerCase();
    return _tasks.values
        .where((t) => t.title.toLowerCase().contains(q))
        .toList();
  }

  // Delete task
  Result<Task> deleteTask(String id) {
    final removed = _tasks.remove(id);
    if (removed == null)
      return Failure(TaskNotFoundException('Task $id not found'));
    return Success<Task>(removed);
  }

  // Return all tasks
  List<Task> allTasks() => List.unmodifiable(_tasks.values);

  // Save to JSON file
  Future<void> saveToFile(String path) async {
    final storage = Storage(path);
    await storage.saveTasks(allTasks());
  }

  // Load from JSON file (replaces current tasks)
  Future<void> loadFromFile(String path) async {
    final storage = Storage(path);
    final loaded = await storage.loadTasks();
    _tasks
      ..clear()
      ..addEntries(loaded.map((t) => MapEntry(t.id, t)));
  }
}
