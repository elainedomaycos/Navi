class RoadmapPlan {
  final String careerTitle;
  final String mascotAsset;
  final List<RoadmapYear> years;
  final List<SkillGap> skillGaps;

  const RoadmapPlan({
    required this.careerTitle,
    required this.mascotAsset,
    required this.years,
    required this.skillGaps,
  });
}

class RoadmapYear {
  final String label;
  final String title;
  final int progress;
  final List<String> milestones;

  const RoadmapYear({
    required this.label,
    required this.title,
    required this.progress,
    required this.milestones,
  });
}

class SkillGap {
  final String skill;
  final String priority;
  final String action;

  const SkillGap({
    required this.skill,
    required this.priority,
    required this.action,
  });
}
