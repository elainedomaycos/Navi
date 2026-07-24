enum SkillStatus { learning, proficient, mastered }

class TrackedSkill {
  final String id;
  final String name;
  final int level;
  final SkillStatus status;
  final DateTime createdAt;

  TrackedSkill({
    required this.id,
    required this.name,
    this.level = 1,
    this.status = SkillStatus.learning,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'level': level,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory TrackedSkill.fromJson(Map<String, dynamic> json) => TrackedSkill(
        id: json['id'] as String,
        name: json['name'] as String,
        level: (json['level'] as num?)?.toInt() ?? 1,
        status: SkillStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => SkillStatus.learning,
        ),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
      );

  TrackedSkill copyWith({int? level, SkillStatus? status, String? name}) =>
      TrackedSkill(
        id: id,
        name: name ?? this.name,
        level: level ?? this.level,
        status: status ?? this.status,
        createdAt: createdAt,
      );
}
