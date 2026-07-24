import '../../core/models/ph_career.dart';
import '../../core/services/career_data_service.dart';
import '../../core/services/gemini_service.dart';
import '../quiz/quiz_session.dart';
import '../roadmap/models/tracked_skill.dart';
import 'recommendation_result.dart';

class RecommendationEngine {
  RecommendationEngine._();

  static Future<RecommendationResult> generateWithAI(
    QuizSession session, {
    List<TrackedSkill> trackedSkills = const [],
  }) async {
    final ai = await GeminiService.analyzeCareers(session);
    return ai ?? await generate(session, trackedSkills: trackedSkills);
  }

  static Future<RecommendationResult> refineWithAI({
    required QuizSession session,
    required Set<String> feedbackIds,
    required String customFeedback,
    List<TrackedSkill> trackedSkills = const [],
  }) async {
    final ai = await GeminiService.refineCareers(
      session: session,
      feedbackIds: feedbackIds,
      customFeedback: customFeedback,
    );
    return ai ??
        await refine(
          session: session,
          feedbackIds: feedbackIds,
          customFeedback: customFeedback,
          trackedSkills: trackedSkills,
        );
  }

  static Future<RecommendationResult> generate(
    QuizSession session, {
    List<TrackedSkill> trackedSkills = const [],
  }) async {
    return _score(session, {}, '', trackedSkills);
  }

  static Future<RecommendationResult> refine({
    required QuizSession session,
    required Set<String> feedbackIds,
    required String customFeedback,
    List<TrackedSkill> trackedSkills = const [],
  }) async {
    return _score(session, feedbackIds, customFeedback, trackedSkills);
  }

  static Future<List<CareerRecommendation>> compareCareers(
    QuizSession session, {
    List<TrackedSkill> trackedSkills = const [],
  }) async {
    final result = await _score(session, {}, '', trackedSkills);
    final data = await CareerDataService.load();
    final all = data.careers.map((c) {
      final existing = result.matches.where((m) => m.id == c.id).firstOrNull;
      return existing ?? CareerRecommendation.fromPhCareer(c, confidence: 60);
    }).toList();
    all.sort((a, b) => b.confidence.compareTo(a.confidence));
    return all;
  }

  static Future<RecommendationResult> _score(
    QuizSession session,
    Set<String> feedbackIds,
    String customFeedback,
    List<TrackedSkill> trackedSkills,
  ) async {
    final data = await CareerDataService.load();
    final tags = _inferTags(session, feedbackIds, customFeedback);

    final scored = <_ScoredCareer>[];
    for (final career in data.careers) {
      final result = _scoreCareer(
        career,
        tags,
        session,
        feedbackIds,
        trackedSkills,
      );
      scored.add(result);
    }

    scored.sort((a, b) => b.totalScore.compareTo(a.totalScore));

    final matches = scored.take(3).map((s) => s.toRecommendation()).toList();

    return RecommendationResult(
      matches: matches,
      generatedAt: DateTime.now(),
    );
  }

  static _ScoredCareer _scoreCareer(
    PhCareer career,
    _TagSet tags,
    QuizSession session,
    Set<String> feedbackIds,
    List<TrackedSkill> trackedSkills,
  ) {
    double score = 50;
    final reasons = <String>[];

    // ── Tag matching ──────────────────────────────────────────────────
    final interestHits = <String>{};
    final styleHits = <String>{};

    for (final userTag in tags.interestTags) {
      for (final careerTag in career.interestTags) {
        if (_tagMatches(userTag, careerTag)) {
          interestHits.add(careerTag);
        }
      }
    }
    for (final userTag in tags.workStyleTags) {
      for (final careerTag in career.workStyleTags) {
        if (_tagMatches(userTag, careerTag)) {
          styleHits.add(careerTag);
        }
      }
    }

    score += interestHits.length * 8;
    score += styleHits.length * 6;

    if (interestHits.isNotEmpty && reasons.length < 3) {
      final top = interestHits.take(1).first;
      reasons.add('You are interested in "$top" — this role fits that.');
    }
    if (styleHits.isNotEmpty && reasons.length < 3) {
      final top = styleHits.take(1).first;
      reasons.add('Your work style " $top" aligns well with this path.');
    }

    // ── Skill overlap ─────────────────────────────────────────────────
    final skillHits = <String>{};
    for (final userSkill in tags.skills) {
      for (final careerSkill in career.relatedSkills) {
        if (_tagMatches(userSkill, careerSkill)) {
          skillHits.add(careerSkill);
        }
      }
    }
    score += skillHits.length * 4;

    final trackedHits = <String>{};
    for (final trackedSkill in trackedSkills) {
      for (final careerSkill in career.relatedSkills) {
        if (_tagMatches(trackedSkill.name, careerSkill)) {
          trackedHits.add(careerSkill);
          score += 3;
          score += switch (trackedSkill.status) {
            SkillStatus.learning => 0,
            SkillStatus.proficient => 2,
            SkillStatus.mastered => 4,
          };
          score += trackedSkill.level * 0.8;
        }
      }
    }
    if (trackedHits.isNotEmpty && reasons.length < 3) {
      reasons
          .add('Your tracked skill "${trackedHits.first}" supports this path.');
    }

    // ── Demand bonus ──────────────────────────────────────────────────
    if (tags.prefersHighDemand && career.demandLevel.toLowerCase() == 'high') {
      score += 5;
      if (reasons.length < 3) {
        reasons.add('High demand in the Philippine job market.');
      }
    }

    // ── Salary bonus ──────────────────────────────────────────────────
    if (tags.prefersHighSalary) {
      final avg = (career.salaryRange.min + career.salaryRange.max) / 2;
      score += (avg / 10000).floor().clamp(0, 8);
    }

    // ── Low-coding bonus ──────────────────────────────────────────────
    if (tags.prefersLowCoding) {
      final techKeywords = [
        'Python',
        'SQL',
        'java',
        'coding',
        'technical',
        'hands-on',
        'tool-heavy',
        'tool-driven'
      ];
      final techCount = career.relatedSkills.where((s) {
        final lower = s.toLowerCase();
        return techKeywords.any((k) => lower.contains(k));
      }).length;
      if (techCount <= 1) {
        score += 8;
        if (reasons.length < 3) {
          reasons.add('This path works well even with less coding.');
        }
      }
    }

    // ── Discoverable bonus ────────────────────────────────────────────
    if (career.discoverable && interestHits.length >= 2) {
      score += 4;
    }
    if (career.discoverable && reasons.length < 3) {
      reasons.add('A career path you might not have considered — '
          'worth exploring based on your profile.');
    }

    // ── Feedback-specific boosts ──────────────────────────────────────
    if (feedbackIds.contains('feedback_people') &&
        career.workStyleTags.any((t) => t.contains('people-facing'))) {
      score += 6;
    }
    if (feedbackIds.contains('feedback_creative') &&
        career.interestTags.any((t) => t.contains('creative'))) {
      score += 6;
    }
    if (feedbackIds.contains('feedback_stability') &&
        career.demandLevel.toLowerCase() == 'high') {
      score += 4;
    }

    final confidence = score.round().clamp(60, 99);

    return _ScoredCareer(
      career: career,
      totalScore: score,
      confidence: confidence,
      reasons: reasons.isEmpty
          ? [
              'Your profile has potential in this area.',
              'Consider exploring this path further.',
              'It is a viable option in the PH job market.'
            ]
          : reasons.take(3).toList(),
    );
  }

  static bool _tagMatches(String userTerm, String careerTerm) {
    final u = userTerm.toLowerCase().trim();
    final c = careerTerm.toLowerCase().trim();
    if (u == c) return true;
    if (c.contains(u) || u.contains(c)) return true;
    final uWords = u.split(RegExp(r'\s+'));
    final cWords = c.split(RegExp(r'\s+'));
    return uWords.any((w) => cWords.contains(w));
  }

  static _TagSet _inferTags(
    QuizSession session,
    Set<String> feedbackIds,
    String customFeedback,
  ) {
    final answerIds = {
      for (final a in session.answers) a.answerId,
    };

    final interestTags = <String>{};
    final workStyleTags = <String>{};
    final skills = <String>{};

    // Map answerIds to tags
    for (final id in answerIds) {
      switch (id) {
        // ── Major ────────────────────────────────────────────────────
        case 'service_management':
          interestTags.addAll([
            'keeping operations running smoothly',
            'process improvement',
          ]);
          skills.add('service delivery');
        case 'business_analytics':
          interestTags.addAll([
            'analyzing how a company works',
            'finding inefficiencies',
          ]);
          skills.add('requirements analysis');
        case 'still_exploring':
          interestTags.add('understanding different career options');
          skills.add('adaptability');
        case 'mixed_interest':
          interestTags.addAll([
            'bridging business and tech',
            'improving workflows',
          ]);
        // ── Interests ────────────────────────────────────────────────
        case 'data_insights':
          interestTags.addAll([
            'finding patterns in numbers',
            'answering questions with evidence',
          ]);
          skills.add('data analysis');
        case 'designing_visuals':
          interestTags.addAll([
            'designing and creating visuals or ideas',
            'creative problem solving',
          ]);
        case 'helping_people':
          interestTags.addAll([
            'solving customer/client problems',
            'helping a team work better together',
          ]);
          workStyleTags.add('people-facing');
        case 'solving_systems':
          interestTags.addAll([
            'understanding how systems fit together',
            'solving complex problems and systems',
          ]);
          skills.add('systems thinking');
        case 'leading_projects':
          interestTags.addAll([
            'leading and organizing teams or projects',
            'organizing chaos into a plan',
          ]);
          workStyleTags.add('coordinating across departments');
        // ── Skills ───────────────────────────────────────────────────
        case 'communication':
          workStyleTags.add('people-facing');
          skills.add('stakeholder communication');
        case 'excel_reporting':
          interestTags.add('working with spreadsheets and dashboards');
          skills.addAll(['excel', 'reporting']);
        case 'process_mapping':
          interestTags.addAll(['improving workflows', 'process improvement']);
          skills.add('process mapping');
        case 'problem_solving':
          interestTags.add('deep technical problem solving');
          skills.add('problem solving');
        case 'creative_thinking':
          interestTags.addAll([
            'designing and creating visuals or ideas',
            'creative problem solving',
          ]);
        // ── Work style ───────────────────────────────────────────────
        case 'structured':
          workStyleTags.addAll([
            'structured/process-driven',
            'detail-oriented',
          ]);
        case 'collaborative':
          workStyleTags.addAll([
            'people-facing',
            'cross-functional collaboration',
          ]);
        case 'independent':
          workStyleTags.addAll([
            'independent/heads-down',
            'independent research',
          ]);
        case 'adaptive':
          workStyleTags.addAll([
            'fast-paced',
            'decision-making under ambiguity',
          ]);
        // ── Goals ────────────────────────────────────────────────────
        case 'salary_growth':
        case 'high_demand':
        case 'low_coding':
        case 'leadership':
        case 'specialization':
        // handled via boolean flags below
      }
    }

    // ── Feedback text keyword extraction ────────────────────────────
    final text = customFeedback.toLowerCase();
    if (text.contains('coding') || text.contains('programming')) {
      feedbackIds.add('feedback_less_coding');
    }
    if (text.contains('people') || text.contains('communicat')) {
      interestTags.add('solving customer/client problems');
      workStyleTags.add('people-facing');
    }
    if (text.contains('salary') || text.contains('money')) {
      feedbackIds.add('feedback_salary');
    }
    if (text.contains('creative') || text.contains('design')) {
      interestTags.add('designing and creating visuals or ideas');
    }
    if (text.contains('stable') || text.contains('stability')) {
      feedbackIds.add('feedback_stability');
    }

    // ── Feedback chip handling ──────────────────────────────────────
    for (final id in feedbackIds) {
      switch (id) {
        case 'feedback_less_coding':
        case 'feedback_more_technical':
        case 'feedback_people':
          workStyleTags.add('people-facing');
        case 'feedback_independent':
          workStyleTags.add('independent/heads-down');
        case 'feedback_creative':
          interestTags.add('creative problem solving');
        case 'feedback_structured':
          workStyleTags.add('structured/process-driven');
        case 'feedback_fast_paced':
          workStyleTags.add('fast-paced');
        case 'feedback_analytical':
          interestTags.add('finding patterns in numbers');
        case 'feedback_leadership':
          interestTags.add('leading and organizing teams or projects');
        case 'feedback_tech_trends':
          interestTags.add('working with AI/ML');
        case 'feedback_work_life':
        case 'feedback_salary':
      }
    }

    return _TagSet(
      interestTags: interestTags,
      workStyleTags: workStyleTags,
      skills: skills,
      prefersHighDemand: answerIds.contains('high_demand') ||
          feedbackIds.contains('feedback_stability'),
      prefersHighSalary: answerIds.contains('salary_growth') ||
          feedbackIds.contains('feedback_salary'),
      prefersLowCoding: answerIds.contains('low_coding') ||
          feedbackIds.contains('feedback_less_coding'),
      prefersLeadership: answerIds.contains('leadership') ||
          feedbackIds.contains('feedback_leadership'),
      prefersSpecialization: answerIds.contains('specialization') ||
          feedbackIds.contains('feedback_tech_trends'),
    );
  }
}

class _TagSet {
  final Set<String> interestTags;
  final Set<String> workStyleTags;
  final Set<String> skills;
  final bool prefersHighDemand;
  final bool prefersHighSalary;
  final bool prefersLowCoding;
  final bool prefersLeadership;
  final bool prefersSpecialization;

  const _TagSet({
    required this.interestTags,
    required this.workStyleTags,
    required this.skills,
    this.prefersHighDemand = false,
    this.prefersHighSalary = false,
    this.prefersLowCoding = false,
    this.prefersLeadership = false,
    this.prefersSpecialization = false,
  });
}

class _ScoredCareer {
  final PhCareer career;
  final double totalScore;
  final int confidence;
  final List<String> reasons;

  const _ScoredCareer({
    required this.career,
    required this.totalScore,
    required this.confidence,
    required this.reasons,
  });

  CareerRecommendation toRecommendation() {
    return CareerRecommendation(
      id: career.id,
      title: career.title,
      confidence: confidence,
      demand: career.demandLabel,
      salaryRange: career.salaryRange.display,
      trend: career.demandNote,
      summary:
          reasons.isNotEmpty ? reasons.first : career.interestTags.join(', '),
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
