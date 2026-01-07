import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:app_todo/features/tasks/models/task_item.dart';
import 'package:app_todo/features/tasks/repository/task_repository.dart';

/// Firebase-backed implementation of TaskRepository.
class FirebaseTaskRepository implements TaskRepository {
  FirebaseTaskRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _tasksCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('tasks');
  }

  @override
  Stream<List<TaskItem>> watchTasks(String uid) {
    return _tasksCollection(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TaskItem.fromFirestore(doc.id, doc.data()))
          .toList();
    });
  }

  @override
  Future<void> addTask({
    required String uid,
    required String title,
    String? description,
  }) async {
    await _tasksCollection(uid).add({
      'title': title,
      'description': description,
      'completed': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'completedAt': null,
    });
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
    await _tasksCollection(uid).doc(taskId).update({
      'title': task.title,
      'description': task.description,
      'completed': task.completed,
      'updatedAt': FieldValue.serverTimestamp(),
      'completedAt':
          task.completed ? (task.completedAt ?? FieldValue.serverTimestamp()) : null,
    });
  }

  @override
  Future<void> deleteTask({
    required String uid,
    required String taskId,
  }) async {
    await _tasksCollection(uid).doc(taskId).delete();
  }
}
