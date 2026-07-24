class QuizAnswer {
  final String questionId;
  final String question;
  final String answerId;
  final String answer;

  const QuizAnswer({
    required this.questionId,
    required this.question,
    required this.answerId,
    required this.answer,
  });
}

class QuizSession {
  final List<QuizAnswer> answers;
  final DateTime completedAt;

  const QuizSession({
    required this.answers,
    required this.completedAt,
  });

  String? answerFor(String questionId) {
    for (final answer in answers) {
      if (answer.questionId == questionId) {
        return answer.answerId;
      }
    }
    return null;
  }
}
