class GoalTask {
  final String id;
  final String title;
  final bool completed;

  GoalTask({
    required this.id,
    required this.title,
    this.completed = false,
  });

  GoalTask copyWith({String? title, bool? completed}) => GoalTask(
        id: id,
        title: title ?? this.title,
        completed: completed ?? this.completed,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'completed': completed,
      };

  factory GoalTask.fromJson(Map<String, dynamic> json) => GoalTask(
        id: json['id'] as String,
        title: json['title'] as String,
        completed: json['completed'] as bool? ?? false,
      );
}
