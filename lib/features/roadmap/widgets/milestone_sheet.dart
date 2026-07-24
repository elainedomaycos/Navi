import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/gemini_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/goal.dart';
import '../models/goal_task.dart';
import '../../../providers/app_providers.dart';

class MilestoneSheet extends ConsumerStatefulWidget {
  final String milestoneText;
  final String yearLabel;
  final String careerTitle;

  const MilestoneSheet({
    super.key,
    required this.milestoneText,
    required this.yearLabel,
    required this.careerTitle,
  });

  static void show(
    BuildContext context, {
    required String milestoneText,
    required String yearLabel,
    required String careerTitle,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF8F4FF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (_) => MilestoneSheet(
        milestoneText: milestoneText,
        yearLabel: yearLabel,
        careerTitle: careerTitle,
      ),
    );
  }

  @override
  ConsumerState<MilestoneSheet> createState() => _MilestoneSheetState();
}

class _MilestoneSheetState extends ConsumerState<MilestoneSheet> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final goals = ref.watch(goalsProvider);
    final alreadyAdded =
        goals.any((g) => g.milestoneRef == widget.milestoneText);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: NaviColors.textMuted.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Milestone',
            style: NaviTextStyles.label.copyWith(
              color: NaviColors.textLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.milestoneText,
            style: NaviTextStyles.heading2.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.careerTitle} · ${widget.yearLabel}',
            style: NaviTextStyles.bodyMedium.copyWith(
              color: NaviColors.textMid,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: NaviColors.primaryPale.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _descriptionFor(widget.milestoneText),
              style: NaviTextStyles.bodyMedium.copyWith(
                color: NaviColors.textDark,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: (alreadyAdded || _loading)
                  ? null
                  : () async {
                      setState(() => _loading = true);
                      final taskTitles =
                          await GeminiService.generateGoalTasks(
                        title: widget.milestoneText,
                        description: _descriptionFor(widget.milestoneText),
                        difficulty: 'Medium',
                      );
                      final tasks = [
                        for (final t in taskTitles)
                          GoalTask(
                            id: DateTime.now()
                                .microsecondsSinceEpoch
                                .toString(),
                            title: t,
                          ),
                      ];
                      final goal = Goal(
                        id: DateTime.now().microsecondsSinceEpoch.toString(),
                        title: widget.milestoneText,
                        description: _descriptionFor(widget.milestoneText),
                        difficulty: 'Medium',
                        estimatedTime: '2-4 weeks',
                        milestoneRef: widget.milestoneText,
                        tasks: tasks,
                      );
                      await ref.read(goalsProvider.notifier).add(goal);
                      if (context.mounted) Navigator.of(context).pop();
                    },
              style: FilledButton.styleFrom(
                backgroundColor: NaviColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: NaviColors.textMuted,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      alreadyAdded
                          ? 'Already in My Goals'
                          : 'Add to My Goals',
                      style: NaviTextStyles.button.copyWith(fontSize: 15),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _descriptionFor(String milestone) {
    final lower = milestone.toLowerCase();
    if (lower.contains('communication')) {
      return 'Practice clear writing and speaking. Join a speaking club or lead a class presentation.';
    }
    if (lower.contains('excel') || lower.contains('dashboard')) {
      return 'Build dashboards with pivot tables, VLOOKUP, and charts from real datasets.';
    }
    if (lower.contains('sql') || lower.contains('data')) {
      return 'Work through SELECT, JOIN, GROUP BY, and filtering exercises on sample databases.';
    }
    if (lower.contains('agile') || lower.contains('scrum')) {
      return 'Run sprint planning, daily stand-ups, and retrospectives on a practice project.';
    }
    if (lower.contains('figma') || lower.contains('design')) {
      return 'Recreate 3 popular app screens, then build a simple component library.';
    }
    if (lower.contains('portfolio')) {
      return 'Document 2–3 school or personal projects with problem, process, and result.';
    }
    if (lower.contains('intern')) {
      return 'Apply to 5+ internships. Tailor your resume and cover letter per posting.';
    }
    if (lower.contains('interview')) {
      return 'Practice behavioral and technical questions weekly with a peer or AI tool.';
    }
    return 'Work on this step consistently. Track your progress and update weekly.';
  }
}
