class FeedbackChip {
  final String id;
  final String label;
  final String emoji;

  const FeedbackChip({
    required this.id,
    required this.label,
    required this.emoji,
  });
}

const feedbackChips = <FeedbackChip>[
  FeedbackChip(
    id: 'feedback_less_coding',
    label: "I don't enjoy coding",
    emoji: '❌',
  ),
  FeedbackChip(
    id: 'feedback_people',
    label: 'I love working with people',
    emoji: '🤝',
  ),
  FeedbackChip(
    id: 'feedback_creative',
    label: 'I prefer creative work',
    emoji: '🎨',
  ),
  FeedbackChip(
    id: 'feedback_salary',
    label: 'I want higher salary',
    emoji: '💰',
  ),
  FeedbackChip(
    id: 'feedback_stability',
    label: 'I want more job stability',
    emoji: '🔒',
  ),
];
