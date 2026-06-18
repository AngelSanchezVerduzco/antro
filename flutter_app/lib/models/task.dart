enum TaskPriority { baja, media, alta }

class Task {
  const Task({
    required this.id,
    required this.title,
    this.description = '',
    this.completed = false,
    this.priority = TaskPriority.media,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final bool completed;
  final TaskPriority priority;
  final DateTime createdAt;

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? completed,
    TaskPriority? priority,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
