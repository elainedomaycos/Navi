import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/sound_effect_service.dart';
import 'quiz_session.dart';

class QuizScreen extends StatefulWidget {
  final QuizSession? initialSession;

  const QuizScreen({super.key, this.initialSession});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  late final Map<String, String> _selectedAnswers;

  @override
  void initState() {
    super.initState();
    _selectedAnswers = {
      for (final answer in widget.initialSession?.answers ?? <QuizAnswer>[])
        answer.questionId: answer.answerId,
    };
  }

  void _selectAnswer(String answerId) {
    SoundEffectService.playTap();
    setState(() {
      _selectedAnswers[_currentQuestion.id] = answerId;
    });
  }

  void _goBack() {
    SoundEffectService.playTap();
    if (_currentIndex == 0) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _currentIndex--;
    });
  }

  void _goNext() {
    if (!_hasCurrentAnswer) {
      return;
    }

    SoundEffectService.playConfirm();

    if (_isLastQuestion) {
      Navigator.of(context).pop(_buildSession());
      return;
    }

    setState(() {
      _currentIndex++;
    });
  }

  QuizSession _buildSession() {
    final answers = _questions.map((question) {
      final answerId = _selectedAnswers[question.id]!;
      final option = question.options.firstWhere(
        (option) => option.id == answerId,
      );
      return QuizAnswer(
        questionId: question.id,
        question: question.prompt,
        answerId: option.id,
        answer: option.label,
      );
    }).toList();

    return QuizSession(
      answers: answers,
      completedAt: DateTime.now(),
    );
  }

  _QuizQuestion get _currentQuestion => _questions[_currentIndex];
  bool get _isLastQuestion => _currentIndex == _questions.length - 1;
  bool get _hasCurrentAnswer => _selectedAnswers[_currentQuestion.id] != null;

  @override
  Widget build(BuildContext context) {
    final question = _currentQuestion;
    final selectedAnswer = _selectedAnswers[question.id];
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: NaviColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
              child: _QuizHeader(
                currentIndex: _currentIndex,
                totalQuestions: _questions.length,
                progress: progress,
                onBack: _goBack,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            question.prompt,
                            style: NaviTextStyles.heading1.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Image.asset(
                          question.mascotAsset,
                          width: 78,
                          height: 78,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    ...question.options.map(
                      (option) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _QuizOptionCard(
                          option: option,
                          selected: option.id == selectedAnswer,
                          onTap: () => _selectAnswer(option.id),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
              child: Row(
                children: [
                  _RoundIconButton(
                    icon: Icons.arrow_back_rounded,
                    onPressed: _goBack,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: FilledButton(
                      onPressed: _hasCurrentAnswer ? _goNext : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: NaviColors.primary,
                        disabledBackgroundColor: NaviColors.primaryPale,
                        foregroundColor: Colors.white,
                        disabledForegroundColor: NaviColors.textLight,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_isLastQuestion ? 'Finish Quiz' : 'Next'),
                          const SizedBox(width: 10),
                          Icon(
                            _isLastQuestion
                                ? Icons.check_rounded
                                : Icons.arrow_forward_rounded,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizHeader extends StatelessWidget {
  final int currentIndex;
  final int totalQuestions;
  final double progress;
  final VoidCallback onBack;

  const _QuizHeader({
    required this.currentIndex,
    required this.totalQuestions,
    required this.progress,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
              color: NaviColors.textDark,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Question ${currentIndex + 1} of $totalQuestions',
              style: NaviTextStyles.label.copyWith(
                color: NaviColors.textDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: NaviColors.primaryPale,
            valueColor: const AlwaysStoppedAnimation<Color>(
              NaviColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuizOptionCard extends StatelessWidget {
  final _QuizOption option;
  final bool selected;
  final VoidCallback onTap;

  const _QuizOptionCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? NaviColors.primary : const Color(0xFFE5DEF8);
    final backgroundColor = selected ? const Color(0xFFF5F2FF) : Colors.white;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          constraints: const BoxConstraints(minHeight: 70),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: borderColor,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: option.tint.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Image.asset(
                    option.mascotAsset,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option.label,
                  style: NaviTextStyles.bodyMedium.copyWith(
                    color: NaviColors.textDark,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? NaviColors.primary : NaviColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _RoundIconButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: 54,
      child: IconButton(
        onPressed: () {
          SoundEffectService.playTap();
          onPressed();
        },
        icon: Icon(icon),
        color: NaviColors.textDark,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

class _QuizQuestion {
  final String id;
  final String prompt;
  final String mascotAsset;
  final List<_QuizOption> options;

  const _QuizQuestion({
    required this.id,
    required this.prompt,
    required this.mascotAsset,
    required this.options,
  });
}

class _QuizOption {
  final String id;
  final String label;
  final String mascotAsset;
  final Color tint;

  const _QuizOption({
    required this.id,
    required this.label,
    required this.mascotAsset,
    required this.tint,
  });
}

const _britAsset = 'assets/images/mascots/brit/brit 3.png';
const _byteAsset = 'assets/images/mascots/byte/byte 4.png';
const _echoAsset = 'assets/images/mascots/echo/echo 5.png';
const _fluxAsset = 'assets/images/mascots/flux/flux 4.png';
const _novaAsset = 'assets/images/mascots/nova/nova 4.png';
const _orbitAsset = 'assets/images/mascots/orbit/orbit 5.png';

const _questions = <_QuizQuestion>[
  _QuizQuestion(
    id: 'major',
    prompt: 'Which IT major or track best describes you right now?',
    mascotAsset: _byteAsset,
    options: [
      _QuizOption(
        id: 'service_management',
        label: 'Service Management',
        mascotAsset: _orbitAsset,
        tint: NaviColors.sparkYellow,
      ),
      _QuizOption(
        id: 'business_analytics',
        label: 'Business Analytics',
        mascotAsset: _echoAsset,
        tint: NaviColors.sparkGreen,
      ),
      _QuizOption(
        id: 'still_exploring',
        label: 'I am still exploring both',
        mascotAsset: _novaAsset,
        tint: NaviColors.sparkPurple,
      ),
      _QuizOption(
        id: 'mixed_interest',
        label: 'A mix of operations, data, and tech',
        mascotAsset: _fluxAsset,
        tint: NaviColors.sparkTeal,
      ),
    ],
  ),
  _QuizQuestion(
    id: 'interests',
    prompt: 'What type of work sounds most exciting to you?',
    mascotAsset: _orbitAsset,
    options: [
      _QuizOption(
        id: 'data_insights',
        label: 'Analyzing data and finding insights',
        mascotAsset: _byteAsset,
        tint: NaviColors.sparkBlue,
      ),
      _QuizOption(
        id: 'designing_visuals',
        label: 'Designing and creating visuals or ideas',
        mascotAsset: _fluxAsset,
        tint: NaviColors.sparkPink,
      ),
      _QuizOption(
        id: 'helping_people',
        label: 'Helping and communicating with people',
        mascotAsset: _britAsset,
        tint: NaviColors.sparkPink,
      ),
      _QuizOption(
        id: 'solving_systems',
        label: 'Solving complex problems and systems',
        mascotAsset: _echoAsset,
        tint: NaviColors.sparkGreen,
      ),
      _QuizOption(
        id: 'leading_projects',
        label: 'Leading and organizing teams or projects',
        mascotAsset: _orbitAsset,
        tint: NaviColors.sparkYellow,
      ),
    ],
  ),
  _QuizQuestion(
    id: 'skills',
    prompt: 'Which skill feels strongest for you today?',
    mascotAsset: _echoAsset,
    options: [
      _QuizOption(
        id: 'communication',
        label: 'Communication and stakeholder coordination',
        mascotAsset: _britAsset,
        tint: NaviColors.sparkPink,
      ),
      _QuizOption(
        id: 'excel_reporting',
        label: 'Excel, dashboards, and reporting',
        mascotAsset: _byteAsset,
        tint: NaviColors.sparkBlue,
      ),
      _QuizOption(
        id: 'process_mapping',
        label: 'Process mapping and service improvement',
        mascotAsset: _orbitAsset,
        tint: NaviColors.sparkYellow,
      ),
      _QuizOption(
        id: 'problem_solving',
        label: 'Logical problem solving',
        mascotAsset: _echoAsset,
        tint: NaviColors.sparkGreen,
      ),
      _QuizOption(
        id: 'creative_thinking',
        label: 'Creative thinking and presentation',
        mascotAsset: _fluxAsset,
        tint: NaviColors.sparkTeal,
      ),
    ],
  ),
  _QuizQuestion(
    id: 'work_style',
    prompt: 'What work style fits you best?',
    mascotAsset: _novaAsset,
    options: [
      _QuizOption(
        id: 'structured',
        label: 'Structured tasks with clear goals',
        mascotAsset: _orbitAsset,
        tint: NaviColors.sparkYellow,
      ),
      _QuizOption(
        id: 'collaborative',
        label: 'Collaborating with teams and clients',
        mascotAsset: _britAsset,
        tint: NaviColors.sparkPink,
      ),
      _QuizOption(
        id: 'independent',
        label: 'Deep independent analysis',
        mascotAsset: _byteAsset,
        tint: NaviColors.sparkBlue,
      ),
      _QuizOption(
        id: 'adaptive',
        label: 'Fast-moving work with changing priorities',
        mascotAsset: _novaAsset,
        tint: NaviColors.sparkPurple,
      ),
    ],
  ),
  _QuizQuestion(
    id: 'goals',
    prompt: 'What matters most in your first IT career path?',
    mascotAsset: _britAsset,
    options: [
      _QuizOption(
        id: 'salary_growth',
        label: 'Strong salary growth',
        mascotAsset: _orbitAsset,
        tint: NaviColors.sparkYellow,
      ),
      _QuizOption(
        id: 'high_demand',
        label: 'High demand in the Philippine job market',
        mascotAsset: _echoAsset,
        tint: NaviColors.sparkGreen,
      ),
      _QuizOption(
        id: 'low_coding',
        label: 'A path with less coding',
        mascotAsset: _britAsset,
        tint: NaviColors.sparkPink,
      ),
      _QuizOption(
        id: 'leadership',
        label: 'A path toward leadership or project ownership',
        mascotAsset: _novaAsset,
        tint: NaviColors.sparkPurple,
      ),
      _QuizOption(
        id: 'specialization',
        label: 'Building a specialized technical skill',
        mascotAsset: _byteAsset,
        tint: NaviColors.sparkBlue,
      ),
    ],
  ),
];
