import 'dart:async';

import 'package:hive/hive.dart';

import 'package:app_todo/features/tasks/models/task_item.dart';
import 'package:app_todo/features/tasks/repository/task_repository.dart';

/// Local task store backed by Hive for persistence.
class LocalTaskRepository implements TaskRepository {
  LocalTaskRepository(this._box) {
    _loadFromStorage();
  }

  final Box<dynamic> _box;
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
    await _persistTasks(uid);
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
    await _persistTasks(uid);
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
    await _persistTasks(uid);
    _emit(uid);
  }

  void _emit(String uid) {
    final controller = _controllers[uid];
    if (controller == null || controller.isClosed) {
      return;
    }
    controller.add(_sortedTasks(uid));
  }

  void _loadFromStorage() {
    for (final key in _box.keys) {
      if (key is! String || key.isEmpty) {
        continue;
      }
      final rawList = _box.get(key);
      if (rawList is! List) {
        continue;
      }
      final tasks = <TaskItem>[];
      for (final raw in rawList) {
        if (raw is! Map) {
          continue;
        }
        final data = Map<String, Object?>.from(raw);
        final idValue = data.remove('id');
        final id = idValue is String && idValue.isNotEmpty
            ? idValue
            : '${key}-task-${tasks.length + 1}';
        tasks.add(TaskItem.fromFirestore(id, data));
      }
      _tasksByUser[key] = tasks;
      _counters[key] = _computeCounter(key, tasks);
    }
  }

  Future<void> _persistTasks(String uid) {
    final tasks = _tasksByUser[uid];
    if (tasks == null) {
      return Future.value();
    }
    final encoded = tasks
        .map(_encodeTask)
        .toList(growable: false);
    return _box.put(uid, encoded);
  }

  Map<String, Object?> _encodeTask(TaskItem task) {
    final data = _encodeMap(task.toFirestore());
    data['id'] = task.id;
    return data;
  }

  Map<String, Object?> _encodeMap(Map<String, Object?> data) {
    return data.map((key, value) => MapEntry(key, _encodeValue(value)));
  }

  Object? _encodeValue(Object? value) {
    if (value is DateTime) {
      return value.toIso8601String();
    }
    if (value is Map) {
      return value.map((key, nested) => MapEntry(key, _encodeValue(nested)));
    }
    if (value is List) {
      return value.map(_encodeValue).toList(growable: false);
    }
    return value;
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

  int _computeCounter(String uid, List<TaskItem> tasks) {
    final prefix = '$uid-task-';
    var maxValue = 0;
    for (final task in tasks) {
      final id = task.id;
      if (id == null || !id.startsWith(prefix)) {
        continue;
      }
      final value = int.tryParse(id.substring(prefix.length));
      if (value != null && value > maxValue) {
        maxValue = value;
      }
    }
    return maxValue;
  }
}
