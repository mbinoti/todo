import 'package:cloud_firestore/cloud_firestore.dart';

/// Domain model for a task stored in Firestore.
class TaskItem {
  const TaskItem({
    this.id,
    required this.title,
    this.description,
    required this.completed,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  final String? id;
  final String title;
  final String? description;
  final bool completed;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  static const Object _descriptionSentinel = Object();

  TaskItem copyWith({
    String? id,
    String? title,
    Object? description = _descriptionSentinel,
    bool? completed,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    final resolvedDescription = description == _descriptionSentinel
        ? this.description
        : description as String?;
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: resolvedDescription,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Serializes the task for Firestore writes.
  Map<String, Object?> toFirestore() {
    return {
      'title': title,
      'description': description,
      'completed': completed,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'completedAt': completedAt,
    };
  }

  /// Builds a TaskItem from Firestore data.
  static TaskItem fromFirestore(String id, Map<String, Object?> data) {
    DateTime resolveDate(Object? value) {
      if (value is DateTime) {
        return value;
      }
      if (value is Timestamp) {
        return value.toDate();
      }
      return DateTime.now();
    }

    DateTime? resolveOptionalDate(Object? value) {
      if (value == null) {
        return null;
      }
      if (value is DateTime) {
        return value;
      }
      if (value is Timestamp) {
        return value.toDate();
      }
      return null;
    }

    return TaskItem(
      id: id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String?,
      completed: data['completed'] as bool? ?? false,
      createdAt: resolveDate(data['createdAt']),
      updatedAt: resolveOptionalDate(data['updatedAt']),
      completedAt: resolveOptionalDate(data['completedAt']),
    );
  }
}
