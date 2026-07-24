class GeneratedCareerProfile {
  final String title;
  final String description;
  final String dayToDay;
  final String salaryRange;
  final String demandLevel;
  final List<String> skills;
  final List<String> topEmployers;

  const GeneratedCareerProfile({
    required this.title,
    required this.description,
    required this.dayToDay,
    required this.salaryRange,
    required this.demandLevel,
    required this.skills,
    required this.topEmployers,
  });

  factory GeneratedCareerProfile.fromJson(Map<String, dynamic> json) {
    return GeneratedCareerProfile(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      dayToDay: json['day_to_day'] as String? ?? '',
      salaryRange: json['salary_range_php'] as String? ?? '',
      demandLevel: json['demand_level'] as String? ?? '',
      skills: (json['skills'] as List<dynamic>?)?.cast<String>() ?? [],
      topEmployers:
          (json['top_employers'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}
