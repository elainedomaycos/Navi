import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/quiz/quiz_session.dart';
import '../../features/results/recommendation_result.dart';

class SessionMemoryService {
  SessionMemoryService._();

  static const _keySession = 'navi_session';
  static const _keyResult = 'navi_result';

  static Future<void> save({
    required QuizSession session,
    required RecommendationResult result,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySession, _sessionToJson(session));
    await prefs.setString(_keyResult, _resultToJson(result));
  }

  static Future<({QuizSession? session, RecommendationResult? result})>
      load() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = prefs.getString(_keySession);
    final resultJson = prefs.getString(_keyResult);

    return (
      session: sessionJson != null ? _sessionFromJson(sessionJson) : null,
      result: resultJson != null ? _resultFromJson(resultJson) : null,
    );
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySession);
    await prefs.remove(_keyResult);
  }

  static String _sessionToJson(QuizSession session) {
    final data = {
      'completedAt': session.completedAt.toIso8601String(),
      'answers': session.answers
          .map(
            (a) => {
              'questionId': a.questionId,
              'question': a.question,
              'answerId': a.answerId,
              'answer': a.answer,
            },
          )
          .toList(),
    };
    return jsonEncode(data);
  }

  static QuizSession _sessionFromJson(String json) {
    final data = jsonDecode(json) as Map<String, dynamic>;
    final answers = (data['answers'] as List<dynamic>)
        .map(
          (a) => QuizAnswer(
            questionId: a['questionId'] as String,
            question: a['question'] as String,
            answerId: a['answerId'] as String,
            answer: a['answer'] as String,
          ),
        )
        .toList();
    return QuizSession(
      answers: answers,
      completedAt: DateTime.parse(data['completedAt'] as String),
    );
  }

  static String _resultToJson(RecommendationResult result) {
    final data = {
      'generatedAt': result.generatedAt.toIso8601String(),
      'matches': result.matches.map(_matchToMap).toList(),
    };
    return jsonEncode(data);
  }

  static RecommendationResult _resultFromJson(String json) {
    final data = jsonDecode(json) as Map<String, dynamic>;
    final matches = (data['matches'] as List<dynamic>)
        .map((m) => _matchFromMap(m as Map<String, dynamic>))
        .toList();
    return RecommendationResult(
      matches: matches,
      generatedAt: DateTime.parse(data['generatedAt'] as String),
    );
  }

  static Map<String, dynamic> _matchToMap(CareerRecommendation match) {
    return {
      'id': match.id,
      'title': match.title,
      'confidence': match.confidence,
      'salaryRange': match.salaryRange,
      'demand': match.demand,
      'trend': match.trend,
      'summary': match.summary,
      'reasons': match.reasons,
      'topEmployers': match.topEmployers,
      'interestTags': match.interestTags,
      'workStyleTags': match.workStyleTags,
      'relatedSkills': match.relatedSkills,
      'discoverable': match.discoverable,
    };
  }

  static CareerRecommendation _matchFromMap(Map<String, dynamic> map) {
    return CareerRecommendation(
      id: map['id'] as String,
      title: map['title'] as String,
      confidence: (map['confidence'] as num).toInt(),
      salaryRange: map['salaryRange'] as String,
      demand: map['demand'] as String,
      trend: map['trend'] as String? ?? '',
      summary: map['summary'] as String,
      mascotAsset: _mascotFor(map['id'] as String),
      tint: _tintFor(map['id'] as String),
      topEmployers: (map['topEmployers'] as List<dynamic>?)?.cast<String>() ?? [],
      reasons: (map['reasons'] as List<dynamic>).cast<String>(),
      interestTags: (map['interestTags'] as List<dynamic>?)?.cast<String>() ?? [],
      workStyleTags: (map['workStyleTags'] as List<dynamic>?)?.cast<String>() ?? [],
      relatedSkills: (map['relatedSkills'] as List<dynamic>?)?.cast<String>() ?? [],
      discoverable: map['discoverable'] as bool? ?? false,
    );
  }

  static String _mascotFor(String id) {
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

  static Color _tintFor(String id) {
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
}
