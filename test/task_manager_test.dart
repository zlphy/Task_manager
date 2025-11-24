import 'package:test/test.dart';
import 'package:task_manager/task.dart';
import 'package:task_manager/task_manager.dart';

void main() {
  group('TaskManager', () {
    test('add and find task', () {
      final manager = TaskManager();
      final task = Task(id: 't1', title: 'Sample Task');

      final added = manager.addTask(task);
      expect(added, isA<Task>());
      final found = manager.findTaskById('t1');
      expect(found, isNotNull);
      expect(found!.title, equals('Sample Task'));
    });
  });
}
