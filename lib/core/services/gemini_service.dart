import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../features/quiz/quiz_session.dart';
import '../../features/results/recommendation_result.dart';
import '../models/generated_career_profile.dart';
import '../models/ph_career.dart';
import 'career_data_service.dart';

class GeminiService {
  GeminiService._();

  static const _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama-3.3-70b-versatile';
  static bool _unavailable = false;

  static Future<String?> _chat(String prompt) async {
    if (_unavailable) return null;
    final key = dotenv.env['GROQ_API_KEY'];
    if (key == null || key.isEmpty) {
      _unavailable = true;
      return null;
    }

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $key',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _model,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.7,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Groq API error ${response.statusCode}: ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = json['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) return null;
    return choices[0]['message']['content'] as String?;
  }

  static Future<RecommendationResult?> analyzeCareers(
    QuizSession session,
  ) async {
    try {
      final data = await CareerDataService.load();
      final prompt = _buildPrompt(session, data, {}, '');
      final text = await _chat(prompt);
      if (text == null) return null;

      return _parseResult(text, session, data);
    } catch (e) {
      debugPrint('GeminiService.analyzeCareers error: $e');
      _unavailable = true;
      return null;
    }
  }

  static Future<RecommendationResult?> refineCareers({
    required QuizSession session,
    required Set<String> feedbackIds,
    required String customFeedback,
  }) async {
    try {
      final data = await CareerDataService.load();
      final prompt = _buildPrompt(session, data, feedbackIds, customFeedback);
      final text = await _chat(prompt);
      if (text == null) return null;

      return _parseResult(text, session, data);
    } catch (e) {
      debugPrint('GeminiService.refineCareers error: $e');
      _unavailable = true;
      return null;
    }
  }

  static Future<GeneratedCareerProfile?> generateCareerProfile(
    String roleTitle,
  ) async {
    try {
      final prompt = '''
You are Navi, a career-guidance AI for Filipino IT students. Generate a detailed career profile for the IT role "$roleTitle" in the Philippine job market.

Return ONLY valid JSON with this exact structure (no markdown, no explanation, no backticks):
{
  "title": "$roleTitle",
  "description": "A 2-3 sentence overview of what this role is about in the PH IT industry",
  "day_to_day": "A paragraph describing what someone in this role actually does on a daily basis — tasks, meetings, tools used, collaboration, etc.",
  "salary_range_php": "e.g. PHP 50K - 90K / month",
  "demand_level": "High Demand, Medium Demand, or Low Demand in the Philippines",
  "skills": ["Skill 1", "Skill 2", "Skill 3", "..."],
  "top_employers": ["Company 1", "Company 2", "..."]
}

Rules:
- salary_range_php must be realistic for the Philippine market in PHP.
- demand_level must reflect actual PH hiring trends.
- skills must be relevant, specific technical and soft skills.
- top_employers must be real companies that hire for this role in the Philippines (BPO, tech, banks, telecoms, etc.).
- day_to_day should be specific and practical, not generic.
- Use Philippine context throughout.
''';
      final text = await _chat(prompt);
      if (text == null) return null;

      final cleaned = _extractJson(text);
      final decoded = jsonDecode(cleaned) as Map<String, dynamic>;
      return GeneratedCareerProfile.fromJson(decoded);
    } catch (e) {
      debugPrint('GeminiService.generateCareerProfile error: $e');
      _unavailable = true;
      return null;
    }
  }

  static Future<List<String>> generateGoalTasks({
    required String title,
    required String description,
    required String difficulty,
  }) async {
    try {
      final prompt = '''
You are Navi, a career-guidance AI for Filipino IT students. Generate specific, actionable subtasks for this goal.

Goal: "$title"
Description: "$description"
Difficulty: $difficulty

Return ONLY a valid JSON array of task strings (no markdown, no explanation, no backticks):
["Task 1", "Task 2", "Task 3", "Task 4", "Task 5"]

Rules:
- Return 4-6 concise, actionable tasks.
- Each task should be a clear action the student can complete (e.g., "Set up a React project with Vite", not "Learn React").
- Tasks should follow a logical order from start to finish.
- Keep task text short (under 60 characters).
- Make tasks specific to Filipino IT students when possible.
- Do not include vague tasks like "Practice" or "Learn more".
''';
      final text = await _chat(prompt);
      if (text == null) return [];

      final cleaned = _extractJson(text);
      final decoded = jsonDecode(cleaned) as List<dynamic>;
      return decoded.cast<String>();
    } catch (e) {
      debugPrint('GeminiService.generateGoalTasks error: $e');
      return [];
    }
  }

  static String _buildPrompt(
    QuizSession session,
    PhCareerData data,
    Set<String> feedbackIds,
    String customFeedback,
  ) {
    final answers = session.answers
        .map((a) => '- ${a.question}: ${a.answer}')
        .join('\n');

    final careersBlock = data.careers.map((c) {
      final tags = [
        ...c.interestTags.map((t) => '      - "$t"'),
      ].join('\n');
      final styles = [
        ...c.workStyleTags.map((t) => '      - "$t"'),
      ].join('\n');
      return '''  ${c.id} | "${c.title}" | ${c.salaryRange.display} | ${c.demandLabel}
    discoverable: ${c.discoverable}
    salary_note: ${c.salaryNote}
    typical_education: ${c.typicalEducation}
    interest_tags:
$tags
    work_style_tags:
$styles
    related_skills: ${c.relatedSkills.join(', ')}
    top_employers: ${c.topEmployers.join(', ')}''';
    }).join('\n\n');

    final feedbackBlock = () {
      final parts = <String>[];
      if (feedbackIds.isNotEmpty) {
        final labels = <String, String>{
          'feedback_less_coding': 'Prefers less coding / technical work',
          'feedback_more_technical': 'Wants more hands-on technical work',
          'feedback_people': 'Enjoys working with people',
          'feedback_independent': 'Prefers working independently',
          'feedback_creative': 'Wants creative / design-oriented work',
          'feedback_structured': 'Prefers structured / routine work',
          'feedback_fast_paced': 'Thrives in fast-paced environments',
          'feedback_analytical': 'Enjoys data analysis / spreadsheets',
          'feedback_leadership': 'Wants leadership / management',
          'feedback_tech_trends': 'Interested in emerging tech',
          'feedback_work_life': 'Values work-life balance',
          'feedback_salary': 'Prioritizes high salary',
        };
        final selected = feedbackIds
            .map((id) => labels[id])
            .whereType<String>()
            .toList();
        if (selected.isNotEmpty) {
          parts.add('Selected preferences: ${selected.join(', ')}.');
        }
      }
      if (customFeedback.isNotEmpty) {
        parts.add('Additional context: "$customFeedback".');
      }
      return parts.isNotEmpty ? '-- Student feedback --\n${parts.join('\n')}\n' : '';
    }();

    final matchingGuidance = data.meta.matchingGuidance;

    return '''
You are Navi, a career-guidance AI for Filipino IT students in Service Management and Business Analytics.

$matchingGuidance

-- Quiz answers --
$answers

$feedbackBlock-- Career options --
$careersBlock

Return ONLY valid JSON with this exact structure (no markdown, no explanation, no backticks):
{
  "matches": [
    {
      "id": "service_manager",
      "title": "Service Manager",
      "confidence": 85,
      "salaryRange": "PHP 45K - 80K / month",
      "demand": "High Demand",
      "trend": "A short one-sentence PH industry trend drawn from the career data",
      "summary": "Why this fits the student (1-2 sentences, referencing interest_tags or work_style_tags that matched)",
      "reasons": [
        "First reason tied to a specific interest_tag or work_style_tag",
        "Second reason tied to an answer or feedback",
        "Third reason tied to market data or skills"
      ],
      "topEmployers": ["ACCENTURE", "IBM", "INFOR"]
    }
  ]
}

Rules:
- Return exactly 3 matches, ordered best match first.
- confidence must be an integer between 60 and 99.
- Match against interest_tags and work_style_tags first.
- DO consider discoverable: true careers when interest_tags align strongly, even if the student didn't select them.
- reasons must be specific to the student's answers and feedback (not generic).
- topEmployers must use PH-relevant company names from the provided data.
- Do not return careers where the student has zero alignment.
''';
  }

  static RecommendationResult? _parseResult(
    String raw,
    QuizSession session,
    PhCareerData data,
  ) {
    final cleaned = _extractJson(raw);
    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
    final list = decoded['matches'] as List<dynamic>?;
    if (list == null || list.isEmpty) return null;

    final matches = list.map((item) {
      final map = item as Map<String, dynamic>;
      final id = map['id'] as String;
      final career = data.byId(id);
      return CareerRecommendation(
        id: id,
        title: map['title'] as String,
        confidence: (map['confidence'] as num).toInt(),
        salaryRange: map['salaryRange'] as String,
        demand: map['demand'] as String,
        trend: map['trend'] as String? ?? '',
        summary: map['summary'] as String? ?? '',
        mascotAsset: career?.mascotAsset ?? _mascotFor(id),
        tint: career?.tint ?? _tintFor(id),
        topEmployers: (map['topEmployers'] as List<dynamic>?)
                ?.cast<String>() ??
            career?.topEmployers ??
            [],
        reasons: (map['reasons'] as List<dynamic>?)?.cast<String>() ?? [],
        interestTags: career?.interestTags ?? [],
        workStyleTags: career?.workStyleTags ?? [],
        relatedSkills: career?.relatedSkills ?? [],
        discoverable: career?.discoverable ?? false,
      );
    }).toList();

    return RecommendationResult(
      matches: matches.take(3).toList(),
      generatedAt: DateTime.now(),
    );
  }

  static String _extractJson(String text) {
    var s = text.trim();
    if (s.startsWith('```')) {
      s = s.replaceFirst(RegExp(r'^```(json)?\s*'), '');
      s = s.replaceFirst(RegExp(r'\s*```$'), '');
    }
    return s;
  }

  static String _mascotFor(String id) {
    return PhCareer(
      id: id,
      title: '',
      aliases: [],
      category: '',
      discoverable: false,
      salaryRange: const SalaryRange(min: 0, max: 0),
      salaryNote: '',
      demandLevel: '',
      demandNote: '',
      topEmployers: [],
      relatedSkills: [],
      interestTags: [],
      workStyleTags: [],
      typicalEducation: '',
      sources: [],
    ).mascotAsset;
  }

  static Color _tintFor(String id) {
    return PhCareer(
      id: id,
      title: '',
      aliases: [],
      category: '',
      discoverable: false,
      salaryRange: const SalaryRange(min: 0, max: 0),
      salaryNote: '',
      demandLevel: '',
      demandNote: '',
      topEmployers: [],
      relatedSkills: [],
      interestTags: [],
      workStyleTags: [],
      typicalEducation: '',
      sources: [],
    ).tint;
  }
}
