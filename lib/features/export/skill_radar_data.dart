import '../quiz/quiz_session.dart';
import '../results/recommendation_result.dart';

class SkillRadarData {
  final Map<String, double> axes;

  const SkillRadarData({required this.axes});

  static const axisLabels = [
    'Technical\nSkills',
    'Data\nAnalysis',
    'Communication',
    'Leadership',
    'Problem\nSolving',
    'Creativity',
  ];

  static SkillRadarData fromSession(
    QuizSession session,
    CareerRecommendation match,
  ) {
    final scores = <String, double>{
      'Technical\nSkills': 0.30,
      'Data\nAnalysis': 0.30,
      'Communication': 0.30,
      'Leadership': 0.30,
      'Problem\nSolving': 0.30,
      'Creativity': 0.30,
    };

    for (final answer in session.answers) {
      _applyAnswer(answer.answerId, scores);
    }

    final skillCount = match.relatedSkills.length;
    if (skillCount >= 5) {
      scores['Technical\nSkills'] =
          (scores['Technical\nSkills']! + 0.25).clamp(0.0, 1.0);
    } else if (skillCount >= 3) {
      scores['Technical\nSkills'] =
          (scores['Technical\nSkills']! + 0.15).clamp(0.0, 1.0);
    }

    final tagCount = match.interestTags.length + match.workStyleTags.length;
    final tagBoost = (tagCount * 0.04).clamp(0.0, 0.20);
    for (final key in scores.keys) {
      scores[key] = (scores[key]! + tagBoost).clamp(0.0, 1.0);
    }

    scores.updateAll((_, v) => v.clamp(0.10, 1.0));

    return SkillRadarData(axes: scores);
  }

  static void _applyAnswer(String answerId, Map<String, double> scores) {
    switch (answerId) {
      case 'communication':
        _boost(scores, 'Communication', 0.50);
        _boost(scores, 'Leadership', 0.15);
      case 'excel_reporting':
        _boost(scores, 'Data\nAnalysis', 0.50);
        _boost(scores, 'Technical\nSkills', 0.15);
      case 'process_mapping':
        _boost(scores, 'Technical\nSkills', 0.50);
        _boost(scores, 'Problem\nSolving', 0.15);
      case 'problem_solving':
        _boost(scores, 'Problem\nSolving', 0.50);
        _boost(scores, 'Technical\nSkills', 0.20);
      case 'creative_thinking':
        _boost(scores, 'Creativity', 0.50);
        _boost(scores, 'Data\nAnalysis', 0.10);
      case 'data_insights':
        _boost(scores, 'Data\nAnalysis', 0.50);
        _boost(scores, 'Problem\nSolving', 0.20);
      case 'designing_visuals':
        _boost(scores, 'Creativity', 0.50);
        _boost(scores, 'Technical\nSkills', 0.10);
      case 'helping_people':
        _boost(scores, 'Communication', 0.40);
        _boost(scores, 'Leadership', 0.25);
      case 'leading_projects':
        _boost(scores, 'Leadership', 0.50);
        _boost(scores, 'Communication', 0.20);
      case 'solving_systems':
        _boost(scores, 'Problem\nSolving', 0.50);
        _boost(scores, 'Technical\nSkills', 0.25);
      case 'service_management':
        _boost(scores, 'Leadership', 0.15);
        _boost(scores, 'Communication', 0.10);
      case 'business_analytics':
        _boost(scores, 'Data\nAnalysis', 0.15);
        _boost(scores, 'Problem\nSolving', 0.10);
      case 'structured':
        _boost(scores, 'Technical\nSkills', 0.10);
        _boost(scores, 'Problem\nSolving', 0.10);
      case 'collaborative':
        _boost(scores, 'Communication', 0.15);
        _boost(scores, 'Leadership', 0.10);
      case 'independent':
        _boost(scores, 'Data\nAnalysis', 0.10);
        _boost(scores, 'Problem\nSolving', 0.10);
      case 'adaptive':
        _boost(scores, 'Creativity', 0.10);
        _boost(scores, 'Leadership', 0.10);
      case 'salary_growth':
      case 'high_demand':
      case 'low_coding':
      case 'leadership':
      case 'specialization':
        break;
    }
  }

  static void _boost(Map<String, double> scores, String key, double amount) {
    if (scores.containsKey(key)) {
      scores[key] = (scores[key]! + amount).clamp(0.0, 1.0);
    }
  }
}
