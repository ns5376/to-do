class Task {
  final int id;
  final String title;
  final bool completed;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.completed,
    required this.createdAt,
  });

  Task copyWith({
    int? id,
    String? title,
    bool? completed,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      title: json['title'] as String,
      completed: json['completed'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
