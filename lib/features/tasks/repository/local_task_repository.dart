import 'dart:async';

import 'package:app_todo/features/tasks/models/task_item.dart';
import 'package:app_todo/features/tasks/repository/task_repository.dart';

/// In-memory task store for local-only data.
class LocalTaskRepository implements TaskRepository {
  final Map<String, List<TaskItem>> _tasksByUser = {};
  final Map<String, StreamController<List<TaskItem>>> _controllers = {};
  final Map<String, int> _counters = {};

  @override
  Stream<List<TaskItem>> watchTasks(String uid) {
    final controller = _controllers.putIfAbsent(
      uid,
      () => StreamController<List<TaskItem>>.broadcast(),
    );
    Future.microtask(() {
      if (controller.isClosed) {
        return;
      }
      controller.add(_sortedTasks(uid));
    });
    return controller.stream;
  }

  @override
  Future<void> addTask({
    required String uid,
    required String title,
    String? description,
  }) async {
    final now = DateTime.now();
    final id = _nextId(uid);
    final task = TaskItem(
      id: id,
      title: title,
      description: description,
      completed: false,
      createdAt: now,
      updatedAt: now,
      completedAt: null,
    );
    final list = _tasksByUser.putIfAbsent(uid, () => []);
    list.add(task);
    _emit(uid);
  }

  @override
  Future<void> updateTask({
    required String uid,
    required TaskItem task,
  }) async {
    final taskId = task.id;
    if (taskId == null || taskId.isEmpty) {
      return;
    }
    final list = _tasksByUser[uid];
    if (list == null) {
      return;
    }
    final index = list.indexWhere((item) => item.id == taskId);
    if (index == -1) {
      return;
    }
    final now = DateTime.now();
    final completedAt =
        task.completed ? (task.completedAt ?? now) : null;
    list[index] = task.copyWith(
      updatedAt: now,
      completedAt: completedAt,
    );
    _emit(uid);
  }

  @override
  Future<void> deleteTask({
    required String uid,
    required String taskId,
  }) async {
    final list = _tasksByUser[uid];
    if (list == null) {
      return;
    }
    list.removeWhere((task) => task.id == taskId);
    _emit(uid);
  }

  void _emit(String uid) {
    final controller = _controllers[uid];
    if (controller == null || controller.isClosed) {
      return;
    }
    controller.add(_sortedTasks(uid));
  }

  List<TaskItem> _sortedTasks(String uid) {
    final list = List<TaskItem>.from(_tasksByUser[uid] ?? const []);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List<TaskItem>.unmodifiable(list);
  }

  String _nextId(String uid) {
    final next = (_counters[uid] ?? 0) + 1;
    _counters[uid] = next;
    return '$uid-task-$next';
  }
}
