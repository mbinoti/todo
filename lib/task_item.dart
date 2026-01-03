class TaskItem {
  const TaskItem({
    required this.title,
    this.subtitle,
    required this.completed,
    required this.createdAt,
  });

  final String title;
  final String? subtitle;
  final bool completed;
  final DateTime createdAt;

  static const Object _subtitleSentinel = Object();

  TaskItem copyWith({
    String? title,
    Object? subtitle = _subtitleSentinel,
    bool? completed,
    DateTime? createdAt,
  }) {
    final resolvedSubtitle =
        subtitle == _subtitleSentinel ? this.subtitle : subtitle as String?;
    return TaskItem(
      title: title ?? this.title,
      subtitle: resolvedSubtitle,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
