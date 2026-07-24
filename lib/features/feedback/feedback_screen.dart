import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../quiz/quiz_session.dart';
import '../results/recommendation_engine.dart';
import '../results/recommendation_result.dart';
import '../roadmap/models/tracked_skill.dart';
import 'feedback_chips.dart';

class FeedbackScreen extends StatefulWidget {
  final QuizSession session;
  final RecommendationResult currentResult;
  final List<TrackedSkill> trackedSkills;

  const FeedbackScreen({
    super.key,
    required this.session,
    required this.currentResult,
    this.trackedSkills = const [],
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final Set<String> _selectedIds = {};
  final TextEditingController _textController = TextEditingController();
  bool _isUpdating = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _updateResults() async {
    if (_selectedIds.isEmpty && _textController.text.trim().isEmpty) return;

    setState(() => _isUpdating = true);

    if (!mounted) return;

    final refined = await RecommendationEngine.refineWithAI(
      session: widget.session,
      feedbackIds: _selectedIds,
      customFeedback: _textController.text.trim(),
      trackedSkills: widget.trackedSkills,
    );

    if (!mounted) return;
    setState(() => _isUpdating = false);

    Navigator.of(context).pop(refined);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NaviColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: NaviColors.textDark,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Refine Your Results',
                        style: NaviTextStyles.heading2.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        'Help us personalize your results even more.',
                        style: NaviTextStyles.label,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nova mascot card
                    _NovaCard(),

                    const SizedBox(height: 20),

                    Text(
                      'Quick Picks',
                      style: NaviTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Select any that apply',
                      style: NaviTextStyles.label,
                    ),
                    const SizedBox(height: 12),

                    // Feedback chips
                    for (var i = 0; i < feedbackChips.length; i++) ...[
                      _FeedbackChipTile(
                        chip: feedbackChips[i],
                        selected: _selectedIds.contains(feedbackChips[i].id),
                        onTap: () {
                          setState(() {
                            final id = feedbackChips[i].id;
                            if (_selectedIds.contains(id)) {
                              _selectedIds.remove(id);
                            } else {
                              _selectedIds.add(id);
                            }
                          });
                        },
                      ),
                      if (i < feedbackChips.length - 1)
                        const SizedBox(height: 10),
                    ],

                    const SizedBox(height: 20),

                    Text(
                      'Or tell us more:',
                      style: NaviTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Free text input
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFEAE4F8)),
                      ),
                      child: TextField(
                        controller: _textController,
                        maxLines: 4,
                        maxLength: 200,
                        style: NaviTextStyles.bodyMedium.copyWith(
                          color: NaviColors.textDark,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Type your thoughts here...',
                          hintStyle: NaviTextStyles.bodyMedium,
                          contentPadding: EdgeInsets.all(14),
                          border: InputBorder.none,
                          counterStyle: NaviTextStyles.label,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isUpdating ? null : _updateResults,
                  style: FilledButton.styleFrom(
                    backgroundColor: NaviColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        NaviColors.primaryLight.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _isUpdating
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text('Nova is refining...'),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Update My Results'),
                            SizedBox(width: 10),
                            Icon(Icons.auto_awesome_rounded, size: 18),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Nova mascot hint card ─────────────────────────────────────────────────────

class _NovaCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NaviColors.sparkPurple.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: NaviColors.sparkPurple.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: NaviColors.sparkPurple.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Image.asset(
                'assets/images/mascots/nova/nova 5.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: NaviTextStyles.bodyMedium.copyWith(
                  color: NaviColors.textDark,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
                children: const [
                  TextSpan(
                    text: 'Nova ',
                    style: TextStyle(color: NaviColors.primaryLight),
                  ),
                  TextSpan(
                    text:
                        'will recalculate your top matches based on your feedback.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Single feedback chip tile ─────────────────────────────────────────────────

class _FeedbackChipTile extends StatelessWidget {
  final FeedbackChip chip;
  final bool selected;
  final VoidCallback onTap;

  const _FeedbackChipTile({
    required this.chip,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? NaviColors.primaryPale : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? NaviColors.primaryLight : const Color(0xFFEAE4F8),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(chip.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                chip.label,
                style: NaviTextStyles.bodyMedium.copyWith(
                  color: selected ? NaviColors.primary : NaviColors.textDark,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 22,
              width: 22,
              decoration: BoxDecoration(
                color: selected ? NaviColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? NaviColors.primary : NaviColors.textMuted,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
