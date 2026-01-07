import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:app_todo/features/tasks/models/task_item.dart';
import 'package:app_todo/features/tasks/repository/task_repository.dart';
import 'package:app_todo/features/tasks/view_model/auth_model.dart';

/// Exposes task streams and operations for the UI.
class TasksModel extends ChangeNotifier {
  TasksModel();

  AuthModel? _authModel;
  TaskRepository? _taskRepository;
  StreamSubscription<List<TaskItem>>? _tasksSubscription;

  List<TaskItem> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TaskItem> get tasks => List.unmodifiable(_tasks);
  List<TaskItem> get pendingTasks =>
      _tasks.where((task) => !task.completed).toList();
  List<TaskItem> get completedTasks =>
      _tasks.where((task) => task.completed).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void bind({
    required AuthModel authModel,
    required TaskRepository taskRepository,
  }) {
    if (identical(_authModel, authModel) &&
        identical(_taskRepository, taskRepository)) {
      return;
    }
    _authModel?.removeListener(_handleAuthChanged);
    _authModel = authModel;
    _taskRepository = taskRepository;
    _authModel?.addListener(_handleAuthChanged);
    _handleAuthChanged();
  }

  Future<void> addTask({
    required String title,
    String? description,
  }) async {
    final authUser = _authModel?.currentUser;
    final taskRepository = _taskRepository;
    if (authUser == null || taskRepository == null) {
      return;
    }
    _setLoading(true);
    _errorMessage = null;
    try {
      await taskRepository.addTask(
        uid: authUser.uid,
        title: title,
        description: description,
      );
    } catch (_) {
      _errorMessage = 'Não foi possível criar a tarefa.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateTask(TaskItem task) async {
    final authUser = _authModel?.currentUser;
    final taskRepository = _taskRepository;
    if (authUser == null || taskRepository == null) {
      return;
    }
    _setLoading(true);
    _errorMessage = null;
    try {
      await taskRepository.updateTask(uid: authUser.uid, task: task);
    } catch (_) {
      _errorMessage = 'Não foi possível atualizar a tarefa.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteTask(TaskItem task) async {
    final authUser = _authModel?.currentUser;
    final taskRepository = _taskRepository;
    final taskId = task.id;
    if (authUser == null || taskRepository == null || taskId == null) {
      return;
    }
    _setLoading(true);
    _errorMessage = null;
    try {
      await taskRepository.deleteTask(uid: authUser.uid, taskId: taskId);
    } catch (_) {
      _errorMessage = 'Não foi possível excluir a tarefa.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleCompletion(TaskItem task) async {
    final completed = !task.completed;
    final updated = task.copyWith(
      completed: completed,
      completedAt: completed ? DateTime.now() : null,
    );
    await updateTask(updated);
  }

  void _handleAuthChanged() {
    final authUser = _authModel?.currentUser;
    _tasksSubscription?.cancel();
    if (authUser == null) {
      _tasks = [];
      notifyListeners();
      return;
    }
    final taskRepository = _taskRepository;
    if (taskRepository == null) {
      return;
    }
    _setLoading(true);
    _tasksSubscription = taskRepository.watchTasks(authUser.uid).listen(
      (tasks) {
        _tasks = tasks;
        _errorMessage = null;
        _setLoading(false);
      },
      onError: (_) {
        _errorMessage = 'Não foi possível carregar tarefas.';
        _setLoading(false);
      },
    );
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _authModel?.removeListener(_handleAuthChanged);
    _tasksSubscription?.cancel();
    super.dispose();
  }
}
