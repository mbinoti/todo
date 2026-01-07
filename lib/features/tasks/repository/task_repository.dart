import 'package:app_todo/features/tasks/models/task_item.dart';

/// Contract for task persistence.
abstract class TaskRepository {
  Stream<List<TaskItem>> watchTasks(String uid);

  Future<void> addTask({
    required String uid,
    required String title,
    String? description,
  });

  Future<void> updateTask({
    required String uid,
    required TaskItem task,
  });

  Future<void> deleteTask({
    required String uid,
    required String taskId,
  });
}
