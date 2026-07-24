import 'goal_task.dart';

class Goal {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final String estimatedTime;
  final List<GoalTask> tasks;
  final String? dueDate;
  final String milestoneRef;
  final DateTime createdAt;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.estimatedTime,
    this.tasks = const [],
    this.dueDate,
    this.milestoneRef = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  int get progressFromTasks {
    if (tasks.isEmpty) return 0;
    return (tasks.where((t) => t.completed).length / tasks.length * 100)
        .round();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'difficulty': difficulty,
        'estimatedTime': estimatedTime,
        'tasks': tasks.map((t) => t.toJson()).toList(),
        'dueDate': dueDate,
        'milestoneRef': milestoneRef,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        difficulty: json['difficulty'] as String? ?? 'Medium',
        estimatedTime: json['estimatedTime'] as String? ?? '2-4 weeks',
        tasks: (json['tasks'] as List<dynamic>?)
                ?.map((t) => GoalTask.fromJson(t as Map<String, dynamic>))
                .toList() ??
            [],
        dueDate: json['dueDate'] as String?,
        milestoneRef: json['milestoneRef'] as String? ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
      );

  Goal copyWith({
    String? title,
    String? description,
    String? difficulty,
    String? estimatedTime,
    List<GoalTask>? tasks,
    String? dueDate,
  }) =>
      Goal(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        difficulty: difficulty ?? this.difficulty,
        estimatedTime: estimatedTime ?? this.estimatedTime,
        tasks: tasks ?? this.tasks,
        dueDate: dueDate ?? this.dueDate,
        milestoneRef: milestoneRef,
        createdAt: createdAt,
      );
}
