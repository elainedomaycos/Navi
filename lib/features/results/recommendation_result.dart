import 'package:flutter/material.dart';

import '../../core/models/ph_career.dart';

class RecommendationResult {
  final List<CareerRecommendation> matches;
  final DateTime generatedAt;

  const RecommendationResult({
    required this.matches,
    required this.generatedAt,
  });

  CareerRecommendation get topMatch => matches.first;
}

class CareerRecommendation {
  final String id;
  final String title;
  final int confidence;
  final String demand;
  final String salaryRange;
  final String trend;
  final String summary;
  final String mascotAsset;
  final Color tint;
  final List<String> topEmployers;
  final List<String> reasons;
  final List<String> interestTags;
  final List<String> workStyleTags;
  final List<String> relatedSkills;
  final bool discoverable;

  const CareerRecommendation({
    required this.id,
    required this.title,
    required this.confidence,
    required this.demand,
    required this.salaryRange,
    required this.trend,
    required this.summary,
    required this.mascotAsset,
    required this.tint,
    required this.topEmployers,
    required this.reasons,
    this.interestTags = const [],
    this.workStyleTags = const [],
    this.relatedSkills = const [],
    this.discoverable = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CareerRecommendation &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  factory CareerRecommendation.fromPhCareer(PhCareer career,
      {int confidence = 70, List<String> reasons = const []}) {
    return CareerRecommendation(
      id: career.id,
      title: career.title,
      confidence: confidence,
      demand: career.demandLabel,
      salaryRange: career.salaryRange.display,
      trend: career.demandNote,
      summary: career.interestTags.isNotEmpty
          ? career.interestTags.take(3).join(', ')
          : career.salaryNote,
      mascotAsset: career.mascotAsset,
      tint: career.tint,
      topEmployers: career.topEmployers,
      reasons: reasons,
      interestTags: career.interestTags,
      workStyleTags: career.workStyleTags,
      relatedSkills: career.relatedSkills,
      discoverable: career.discoverable,
    );
  }
}
