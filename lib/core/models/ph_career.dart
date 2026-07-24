import 'package:flutter/material.dart';

class PhCareerMeta {
  final String description;
  final String currency;
  final String salaryUnit;
  final String lastUpdated;
  final List<String> sources;
  final String notes;
  final String matchingGuidance;

  const PhCareerMeta({
    required this.description,
    required this.currency,
    required this.salaryUnit,
    required this.lastUpdated,
    required this.sources,
    required this.notes,
    required this.matchingGuidance,
  });

  factory PhCareerMeta.fromJson(Map<String, dynamic> json) {
    return PhCareerMeta(
      description: json['description'] as String,
      currency: json['currency'] as String,
      salaryUnit: json['salary_unit'] as String,
      lastUpdated: json['last_updated'] as String,
      sources: (json['sources'] as List<dynamic>).cast<String>(),
      notes: json['notes'] as String,
      matchingGuidance: json['matching_guidance'] as String,
    );
  }
}

class SalaryRange {
  final int min;
  final int max;

  const SalaryRange({required this.min, required this.max});

  factory SalaryRange.fromJson(Map<String, dynamic> json) {
    return SalaryRange(
      min: (json['min'] as num).toInt(),
      max: (json['max'] as num).toInt(),
    );
  }

  String get display => 'PHP ${_fmt(min)} - ${_fmt(max)} / month';
  String get short => '₱${_fmt(min)}–${_fmt(max)}';

  static String _fmt(int v) {
    if (v >= 1000) return '${(v / 1000).floor()}K';
    return '$v';
  }
}

class PhCareer {
  final String id;
  final String title;
  final List<String> aliases;
  final String category;
  final bool discoverable;
  final SalaryRange salaryRange;
  final String salaryNote;
  final String demandLevel;
  final String demandNote;
  final List<String> topEmployers;
  final List<String> relatedSkills;
  final List<String> interestTags;
  final List<String> workStyleTags;
  final String typicalEducation;
  final List<String> sources;

  const PhCareer({
    required this.id,
    required this.title,
    required this.aliases,
    required this.category,
    required this.discoverable,
    required this.salaryRange,
    required this.salaryNote,
    required this.demandLevel,
    required this.demandNote,
    required this.topEmployers,
    required this.relatedSkills,
    required this.interestTags,
    required this.workStyleTags,
    required this.typicalEducation,
    required this.sources,
  });

  factory PhCareer.fromJson(Map<String, dynamic> json) {
    return PhCareer(
      id: json['id'] as String,
      title: json['title'] as String,
      aliases: (json['aliases'] as List<dynamic>).cast<String>(),
      category: json['category'] as String,
      discoverable: json['discoverable'] as bool,
      salaryRange: SalaryRange.fromJson(
        json['salary_range_php'] as Map<String, dynamic>,
      ),
      salaryNote: json['salary_note'] as String,
      demandLevel: json['demand_level'] as String,
      demandNote: json['demand_note'] as String,
      topEmployers: (json['top_employers'] as List<dynamic>).cast<String>(),
      relatedSkills: (json['related_skills'] as List<dynamic>).cast<String>(),
      interestTags: (json['interest_tags'] as List<dynamic>).cast<String>(),
      workStyleTags: (json['work_style_tags'] as List<dynamic>).cast<String>(),
      typicalEducation: json['typical_education'] as String,
      sources: (json['sources'] as List<dynamic>).cast<String>(),
    );
  }

  String get mascotAsset {
    switch (id) {
      case 'service_manager':
        return 'assets/images/mascots/orbit/orbit 2.png';
      case 'business_analyst':
        return 'assets/images/mascots/echo/echo 2.png';
      case 'data_analyst':
        return 'assets/images/mascots/byte/byte 2.png';
      case 'project_manager':
        return 'assets/images/mascots/nova/nova 2.png';
      case 'systems_analyst':
        return 'assets/images/mascots/flux/flux 2.png';
      case 'ux_designer':
        return 'assets/images/mascots/byte/byte 3.png';
      case 'data_scientist':
        return 'assets/images/mascots/byte/byte 4.png';
      case 'scrum_master':
        return 'assets/images/mascots/orbit/orbit 3.png';
      case 'product_owner':
        return 'assets/images/mascots/nova/nova 3.png';
      case 'qa_analyst':
        return 'assets/images/mascots/flux/flux 3.png';
      case 'it_auditor':
        return 'assets/images/mascots/echo/echo 3.png';
      case 'cybersecurity_analyst':
        return 'assets/images/mascots/byte/byte 5.png';
      case 'erp_consultant':
        return 'assets/images/mascots/echo/echo 4.png';
      default:
        return 'assets/images/mascots/nova/nova 1.png';
    }
  }

  Color get tint {
    switch (id) {
      case 'service_manager':
        return const Color(0xFFFFD54F);
      case 'business_analyst':
        return const Color(0xFFA5D6A7);
      case 'data_analyst':
        return const Color(0xFF81D4FA);
      case 'project_manager':
        return const Color(0xFFB39DDB);
      case 'systems_analyst':
        return const Color(0xFF80CBC4);
      case 'ux_designer':
        return const Color(0xFF81D4FA);
      case 'data_scientist':
        return const Color(0xFF81D4FA);
      case 'scrum_master':
        return const Color(0xFFFFD54F);
      case 'product_owner':
        return const Color(0xFFB39DDB);
      case 'qa_analyst':
        return const Color(0xFF80CBC4);
      case 'it_auditor':
        return const Color(0xFFA5D6A7);
      case 'cybersecurity_analyst':
        return const Color(0xFF81D4FA);
      case 'erp_consultant':
        return const Color(0xFFA5D6A7);
      default:
        return const Color(0xFFB39DDB);
    }
  }

  String get demandLabel {
    switch (demandLevel.toLowerCase()) {
      case 'high':
        return 'High Demand';
      case 'medium':
        return 'Medium Demand';
      case 'low':
        return 'Low Demand';
      default:
        return demandLevel;
    }
  }
}

class PhCareerData {
  final PhCareerMeta meta;
  final List<PhCareer> careers;

  const PhCareerData({required this.meta, required this.careers});

  factory PhCareerData.fromJson(Map<String, dynamic> json) {
    return PhCareerData(
      meta: PhCareerMeta.fromJson(json['_meta'] as Map<String, dynamic>),
      careers: (json['careers'] as List<dynamic>)
          .map((c) => PhCareer.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  PhCareer? byId(String id) {
    for (final c in careers) {
      if (c.id == id) return c;
    }
    return null;
  }

  List<PhCareer> get discoverableCareers =>
      careers.where((c) => c.discoverable).toList();

  List<PhCareer> get nonDiscoverableCareers =>
      careers.where((c) => !c.discoverable).toList();
}
