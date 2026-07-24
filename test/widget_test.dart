import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:navi/core/services/session_memory_service.dart';
import 'package:navi/features/quiz/quiz_session.dart';
import 'package:navi/features/results/recommendation_engine.dart';

// ─── Helpers ───────────────────────────────────────────────────────────────

QuizSession _makeSession({
  String major = 'service_management',
  String interest = 'leading_projects',
  String skill = 'communication',
  String style = 'structured',
  String goal = 'high_demand',
}) {
  return QuizSession(
    answers: [
      QuizAnswer(
        questionId: 'q1_major',
        question: 'What is your major?',
        answerId: major,
        answer: _label(major),
      ),
      QuizAnswer(
        questionId: 'q2_interest',
        question: 'What interests you most?',
        answerId: interest,
        answer: _label(interest),
      ),
      QuizAnswer(
        questionId: 'q3_skill',
        question: 'What is your strongest skill?',
        answerId: skill,
        answer: _label(skill),
      ),
      QuizAnswer(
        questionId: 'q4_style',
        question: 'How do you prefer to work?',
        answerId: style,
        answer: _label(style),
      ),
      QuizAnswer(
        questionId: 'q5_goal',
        question: 'What is your career goal?',
        answerId: goal,
        answer: _label(goal),
      ),
    ],
    completedAt: DateTime(2026, 6, 30),
  );
}

String _label(String id) {
  return {
        'service_management': 'Service Management',
        'business_analytics': 'Business Analytics',
        'mixed_interest': 'Mixed Interest',
        'data_insights': 'Data & Insights',
        'helping_people': 'Helping People',
        'leading_projects': 'Leading Projects',
        'excel_reporting': 'Excel & Reporting',
        'process_mapping': 'Process Mapping',
        'solving_systems': 'Solving Systems',
        'problem_solving': 'Problem Solving',
        'communication': 'Communication',
        'structured': 'Structured Work',
        'collaborative': 'Collaborative',
        'independent': 'Independent',
        'adaptive': 'Adaptive',
        'high_demand': 'High Demand',
        'low_coding': 'Low Coding',
        'leadership': 'Leadership',
        'salary_growth': 'Salary Growth',
        'specialization': 'Specialization',
        'still_exploring': 'Still Exploring',
        'designing_visuals': 'Designing Visuals',
        'creative_thinking': 'Creative Thinking',
      }[id] ??
      id;
}

// ─── Tests ─────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Ensure SharedPreferences mock is initialized for all tests
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // ── QuizSession ─────────────────────────────────────────────────────────

  group('QuizSession', () {
    test('answerFor returns matching answer', () {
      final session = QuizSession(
        answers: [
          const QuizAnswer(
            questionId: 'q1',
            question: 'Q1?',
            answerId: 'a1',
            answer: 'A1',
          ),
          const QuizAnswer(
            questionId: 'q2',
            question: 'Q2?',
            answerId: 'a2',
            answer: 'A2',
          ),
        ],
        completedAt: DateTime(2026),
      );
      expect(session.answerFor('q1'), 'a1');
      expect(session.answerFor('q2'), 'a2');
    });

    test('answerFor returns null for unknown question', () {
      final session = QuizSession(
        answers: [],
        completedAt: DateTime(2026),
      );
      expect(session.answerFor('unknown'), isNull);
    });
  });

  // ── RecommendationEngine ────────────────────────────────────────────────

  group('RecommendationEngine generate', () {
    test('returns 3 matches sorted by confidence descending', () async {
      final result = await RecommendationEngine.generate(_makeSession());
      expect(result.matches.length, 3);
      for (var i = 0; i < result.matches.length - 1; i++) {
        expect(
          result.matches[i].confidence,
          greaterThanOrEqualTo(result.matches[i + 1].confidence),
        );
      }
    });

    test('all matches have confidence >= 60 and <= 99', () async {
      final result = await RecommendationEngine.generate(_makeSession());
      for (final m in result.matches) {
        expect(m.confidence, inInclusiveRange(60, 99));
      }
    });

    test('each match has non-empty reasons', () async {
      final result = await RecommendationEngine.generate(_makeSession());
      for (final m in result.matches) {
        expect(m.reasons, isNotEmpty);
      }
    });

    test('each match has non-empty topEmployers', () async {
      final result = await RecommendationEngine.generate(_makeSession());
      for (final m in result.matches) {
        expect(m.topEmployers, isNotEmpty);
      }
    });

    test('each match has interestTags populated', () async {
      final result = await RecommendationEngine.generate(_makeSession());
      for (final m in result.matches) {
        expect(m.interestTags, isNotEmpty);
      }
    });

    test('each match has relatedSkills populated', () async {
      final result = await RecommendationEngine.generate(_makeSession());
      for (final m in result.matches) {
        expect(m.relatedSkills, isNotEmpty);
      }
    });

    test('service_management major boosts Service Manager to top', () async {
      final result = await RecommendationEngine.generate(
        _makeSession(major: 'service_management'),
      );
      expect(result.matches.first.id, 'service_manager');
    });
  });

  group('RecommendationEngine refine', () {
    test(
        'refine with feedback_less_coding shifts toward less technical careers',
        () async {
      final refined = await RecommendationEngine.refine(
        session: _makeSession(),
        feedbackIds: {'feedback_less_coding'},
        customFeedback: '',
      );
      // Service Manager should rank high due to low-coding preference
      final ids = refined.matches.map((m) => m.id).toList();
      expect(ids, contains('service_manager'));
    });

    test('refine with feedback_salary still produces valid result', () async {
      final salaried = await RecommendationEngine.refine(
        session: _makeSession(
          major: 'business_analytics',
          interest: 'data_insights',
          skill: 'excel_reporting',
          style: 'independent',
          goal: 'salary_growth',
        ),
        feedbackIds: {'feedback_salary'},
        customFeedback: '',
      );
      expect(salaried.matches[0].confidence, greaterThanOrEqualTo(60));
      expect(salaried.matches[0].reasons, isNotEmpty);
    });

    test('refine extracts keywords from custom feedback text', () async {
      final refinedCode = await RecommendationEngine.refine(
        session: _makeSession(),
        feedbackIds: {},
        customFeedback: 'I do not like programming or coding',
      );
      expect(refinedCode.matches.first.confidence, greaterThanOrEqualTo(60));

      final refinedPeople = await RecommendationEngine.refine(
        session: _makeSession(),
        feedbackIds: {},
        customFeedback: 'I enjoy working with people',
      );
      expect(refinedPeople.matches.length, 3);
    });

    test('refine with empty feedback returns same length as generate',
        () async {
      final base = await RecommendationEngine.generate(_makeSession());
      final refined = await RecommendationEngine.refine(
        session: _makeSession(),
        feedbackIds: {},
        customFeedback: '',
      );
      expect(refined.matches.length, base.matches.length);
    });
  });

  group('RecommendationEngine compareCareers', () {
    test('returns careers sorted by confidence descending', () async {
      final careers = await RecommendationEngine.compareCareers(
        _makeSession(),
      );
      for (var i = 0; i < careers.length - 1; i++) {
        expect(
          careers[i].confidence,
          greaterThanOrEqualTo(careers[i + 1].confidence),
        );
      }
    });

    test('each career has valid id', () async {
      final ids = <String>{
        'service_manager',
        'business_analyst',
        'data_analyst',
        'project_manager',
        'systems_analyst',
        'ux_designer',
        'data_scientist',
        'scrum_master',
        'product_owner',
        'qa_analyst',
        'it_auditor',
        'cybersecurity_analyst',
        'erp_consultant',
      };
      final careers = await RecommendationEngine.compareCareers(
        _makeSession(),
      );
      for (final c in careers) {
        expect(ids, contains(c.id));
      }
    });
  });

  group('RecommendationEngine edge cases', () {
    test('empty answers still produces valid result', () async {
      final session = QuizSession(answers: [], completedAt: DateTime(2026));
      final result = await RecommendationEngine.generate(session);
      expect(result.matches.length, 3);
      for (final m in result.matches) {
        expect(m.confidence, inInclusiveRange(60, 99));
      }
    });

    test('single answer produces valid result', () async {
      final session = QuizSession(
        answers: [
          const QuizAnswer(
            questionId: 'q1',
            question: 'Q?',
            answerId: 'service_management',
            answer: 'SM',
          ),
        ],
        completedAt: DateTime(2026),
      );
      final result = await RecommendationEngine.generate(session);
      expect(result.matches.length, 3);
    });

    test('refine with all feedback IDs still produces valid result', () async {
      final allIds = {
        'feedback_less_coding',
        'feedback_more_technical',
        'feedback_people',
        'feedback_independent',
        'feedback_creative',
        'feedback_structured',
        'feedback_fast_paced',
        'feedback_analytical',
        'feedback_leadership',
        'feedback_tech_trends',
        'feedback_work_life',
        'feedback_salary',
      };
      final refined = await RecommendationEngine.refine(
        session: _makeSession(),
        feedbackIds: allIds,
        customFeedback: '',
      );
      expect(refined.matches.length, 3);
    });
  });

  // ── SessionMemoryService ────────────────────────────────────────────────

  group('SessionMemoryService', () {
    test('save and load round-trips QuizSession', () async {
      final original = _makeSession();
      final result = await RecommendationEngine.generate(original);

      await SessionMemoryService.save(session: original, result: result);
      final loaded = await SessionMemoryService.load();

      expect(loaded.session, isNotNull);
      expect(loaded.session!.answers.length, original.answers.length);
      expect(loaded.session!.answers[0].questionId,
          original.answers[0].questionId);
      expect(
        loaded.session!.completedAt.toIso8601String(),
        original.completedAt.toIso8601String(),
      );
    });

    test('save and load round-trips RecommendationResult', () async {
      final session = _makeSession();
      final original = await RecommendationEngine.generate(session);

      await SessionMemoryService.save(session: session, result: original);
      final loaded = await SessionMemoryService.load();

      expect(loaded.result, isNotNull);
      expect(loaded.result!.matches.length, original.matches.length);
      expect(
        loaded.result!.matches[0].id,
        original.matches[0].id,
      );
      expect(
        loaded.result!.matches[0].confidence,
        original.matches[0].confidence,
      );
      expect(
        loaded.result!.matches[0].reasons.length,
        original.matches[0].reasons.length,
      );
      expect(
        loaded.result!.matches[0].topEmployers.length,
        original.matches[0].topEmployers.length,
      );
    });

    test('round-trip preserves new fields', () async {
      final session = _makeSession();
      final original = await RecommendationEngine.generate(session);

      await SessionMemoryService.save(session: session, result: original);
      final loaded = await SessionMemoryService.load();
      final restored = loaded.result!;

      for (var i = 0; i < restored.matches.length; i++) {
        expect(
          restored.matches[i].interestTags.length,
          original.matches[i].interestTags.length,
        );
        expect(
          restored.matches[i].workStyleTags,
          original.matches[i].workStyleTags,
        );
        expect(
          restored.matches[i].relatedSkills,
          original.matches[i].relatedSkills,
        );
      }
    });

    test('clear removes persisted data', () async {
      final session = _makeSession();
      final result = await RecommendationEngine.generate(session);

      await SessionMemoryService.save(session: session, result: result);
      await SessionMemoryService.clear();
      final loaded = await SessionMemoryService.load();

      expect(loaded.session, isNull);
      expect(loaded.result, isNull);
    });

    test('load returns nulls when no data saved', () async {
      final loaded = await SessionMemoryService.load();
      expect(loaded.session, isNull);
      expect(loaded.result, isNull);
    });
  });
}
