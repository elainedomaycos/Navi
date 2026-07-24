import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/app_providers.dart';
import './my_goals_screen.dart';
import './my_skills_screen.dart';
import '../quiz/quiz_session.dart';
import '../results/recommendation_engine.dart';
import '../results/recommendation_result.dart';
import 'roadmap_engine.dart';
import 'roadmap_plan.dart';
import 'models/tracked_skill.dart';
import 'widgets/milestone_sheet.dart';

class RoadmapScreen extends ConsumerStatefulWidget {
  final QuizSession? session;
  final RecommendationResult? result;
  final VoidCallback onStartAssessment;

  const RoadmapScreen({
    super.key,
    required this.session,
    required this.result,
    required this.onStartAssessment,
  });

  @override
  ConsumerState<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends ConsumerState<RoadmapScreen> {
  RoadmapPlan? _plan;
  bool _loading = true;
  String? _skillSignature;
  bool _refreshQueued = false;
  String _loadingText = 'Building your roadmap...';

  @override
  void initState() {
    super.initState();
    _generatePlan(forceRecalculate: true);
  }

  @override
  void didUpdateWidget(covariant RoadmapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.session != null &&
        widget.result != null &&
        (oldWidget.session == null || oldWidget.result == null)) {
      _generatePlan(forceRecalculate: true);
    } else if (oldWidget.session != widget.session ||
        oldWidget.result != widget.result) {
      _generatePlan(forceRecalculate: true);
    }
  }

  Future<void> _generatePlan({bool forceRecalculate = false}) async {
    final session = widget.session;
    final result = widget.result;
    if (session == null || result == null) {
      setState(() {
        _loading = false;
        _loadingText = 'Building your roadmap...';
      });
      return;
    }

    final trackedSkills = ref.read(trackedSkillsProvider);
    final signature = _skillsSignature(trackedSkills);

    if (!forceRecalculate &&
        _plan != null &&
        _skillSignature == signature) {
      setState(() => _loading = false);
      return;
    }

    setState(() {
      _loading = true;
      _loadingText = 'Analyzing career fit...';
    });

    RecommendationResult recalculated;
    if (forceRecalculate || _skillSignature != signature) {
      if (result.matches.isNotEmpty) {
        recalculated = result;
      } else {
        recalculated = await RecommendationEngine.generate(
          session,
          trackedSkills: trackedSkills,
        );
        if (!mounted) return;
        ref.read(recommendationResultProvider.notifier).setResult(recalculated);
      }
    } else {
      recalculated = result;
    }

    setState(() => _loadingText = 'Generating your roadmap...');

    final plan = await RoadmapEngine.generate(
      session: session,
      recommendation: recalculated.topMatch,
    );

    if (!mounted) return;
    setState(() {
      _plan = plan;
      _loading = false;
      _skillSignature = signature;
      _refreshQueued = false;
      _loadingText = 'Building your roadmap...';
    });
  }

  String _skillsSignature(List<TrackedSkill> skills) {
    return skills
        .map((skill) => '${skill.id}:${skill.level}:${skill.status.name}')
        .join('|');
  }

  @override
  Widget build(BuildContext context) {
    final trackedSkills = ref.watch(trackedSkillsProvider);
    final session = widget.session;
    final result = widget.result;
    final signature = _skillsSignature(trackedSkills);

    if (!_loading &&
        _plan != null &&
        _skillSignature != null &&
        _skillSignature != signature &&
        !_refreshQueued) {
      _refreshQueued = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_skillSignature != signature) {
          _generatePlan(forceRecalculate: true);
        } else {
          _refreshQueued = false;
        }
      });
    }

    if (session == null || result == null) {
      return _RoadmapEmptyState(onStartAssessment: widget.onStartAssessment);
    }

    if (_loading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: NaviColors.primary),
              const SizedBox(height: 16),
              Text(
                _loadingText,
                style: NaviTextStyles.bodyMedium.copyWith(
                  color: NaviColors.textMid,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final plan = _plan!;

    return DefaultTabController(
      length: 4,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RoadmapHeader(plan: plan)
                .animate()
                .fadeIn(duration: 500.ms)
                .slideY(
                  begin: -0.08,
                  end: 0,
                  curve: Curves.easeOut,
                ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFEAE4F8)),
              ),
              child: const TabBar(
                isScrollable: false,
                indicatorSize: TabBarIndicatorSize.tab,
                labelPadding: EdgeInsets.zero,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: NaviColors.primary,
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: NaviColors.textMid,
                tabs: [
                  Tab(text: 'Timeline'),
                  Tab(text: 'Skill Gap'),
                  Tab(text: 'My Goals'),
                  Tab(text: 'My Skills'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: TabBarView(
                children: [
                  _TimelineTab(plan: plan)
                      .animate(delay: 180.ms)
                      .fadeIn(
                        duration: 600.ms,
                      )
                      .slideY(begin: 0.06, end: 0, curve: Curves.easeOut),
                  _SkillGapTab(plan: plan)
                      .animate(delay: 220.ms)
                      .fadeIn(
                        duration: 600.ms,
                      )
                      .slideY(begin: 0.06, end: 0, curve: Curves.easeOut),
                  const MyGoalsScreen(),
                  MySkillsScreen(
                    suggestedSkills:
                        plan.skillGaps.map((g) => g.skill).toList(),
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

class _RoadmapHeader extends StatelessWidget {
  final RoadmapPlan plan;

  const _RoadmapHeader({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Career Roadmap',
                style: NaviTextStyles.heading2.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                plan.careerTitle,
                style: NaviTextStyles.heading1.copyWith(
                  color: NaviColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Updated with your current quiz answers and tracked skills.',
                style: NaviTextStyles.bodyMedium.copyWith(
                  color: NaviColors.textMid,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        Image.asset(
          plan.mascotAsset,
          width: 78,
          height: 78,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}

class _TimelineTab extends ConsumerWidget {
  final RoadmapPlan plan;

  const _TimelineTab({required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);
    final completedMilestones =
        goals.where((goal) => goal.milestoneRef.isNotEmpty).length;
    final totalMilestones =
        plan.years.fold<int>(0, (sum, year) => sum + year.milestones.length);

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: NaviColors.primaryPale.withValues(alpha: 0.26),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              _MiniStat(
                value: '$completedMilestones',
                label: 'Saved goals',
              ),
              const SizedBox(width: 12),
              _MiniStat(
                value: '$totalMilestones',
                label: 'Roadmap steps',
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tap any milestone to check details and add it to your goals.',
                  style: NaviTextStyles.bodyMedium.copyWith(
                    color: NaviColors.textMid,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        for (var index = 0; index < plan.years.length; index++) ...[
          _YearCard(
            year: plan.years[index],
            milestones: plan.years[index].milestones,
            careerTitle: plan.careerTitle,
          ),
          if (index < plan.years.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;

  const _MiniStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: NaviTextStyles.heading2.copyWith(
              fontWeight: FontWeight.w900,
              color: NaviColors.primary,
            ),
          ),
          Text(
            label,
            style: NaviTextStyles.label.copyWith(color: NaviColors.textMid),
          ),
        ],
      ),
    );
  }
}

class _YearCard extends ConsumerWidget {
  final RoadmapYear year;
  final List<String> milestones;
  final String careerTitle;

  const _YearCard({
    required this.year,
    required this.milestones,
    required this.careerTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);
    final total = milestones.length;
    final completed =
        milestones.where((m) => goals.any((g) => g.milestoneRef == m)).length;
    final progress = total > 0 ? ((completed / total) * 100).round() : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAE4F8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  year.label,
                  style: NaviTextStyles.label.copyWith(
                    color: NaviColors.textLight,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (progress > 0) _ProgressPill(progress: progress),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            year.title,
            style: NaviTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          for (final milestone in milestones) ...[
            _MilestoneTile(
              milestone: milestone,
              yearLabel: year.label,
              careerTitle: careerTitle,
              isChecked: goals.any((goal) => goal.milestoneRef == milestone),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _MilestoneTile extends StatelessWidget {
  final String milestone;
  final String yearLabel;
  final String careerTitle;
  final bool isChecked;

  const _MilestoneTile({
    required this.milestone,
    required this.yearLabel,
    required this.careerTitle,
    required this.isChecked,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          MilestoneSheet.show(
            context,
            milestoneText: milestone,
            yearLabel: yearLabel,
            careerTitle:
                careerTitle.isEmpty ? 'Roadmap milestone' : careerTitle,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isChecked
                ? NaviColors.primaryPale.withValues(alpha: 0.3)
                : const Color(0xFFFDFBFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isChecked
                  ? NaviColors.primary.withValues(alpha: 0.18)
                  : const Color(0xFFEAE4F8),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isChecked
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: isChecked ? NaviColors.matchHigh : NaviColors.textMuted,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      milestone,
                      style: NaviTextStyles.bodyMedium.copyWith(
                        color: NaviColors.textDark,
                        fontWeight: FontWeight.w800,
                        decoration:
                            isChecked ? TextDecoration.lineThrough : null,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isChecked ? 'Added to My Goals' : 'Tap to add as a goal',
                      style: NaviTextStyles.label.copyWith(
                        color: isChecked
                            ? NaviColors.matchHigh
                            : NaviColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: NaviColors.textDark.withValues(alpha: 0.55),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressPill extends StatelessWidget {
  final int progress;

  const _ProgressPill({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: NaviColors.matchHigh.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        '$progress%',
        style: NaviTextStyles.label.copyWith(
          color: NaviColors.matchHigh,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SkillGapTab extends ConsumerWidget {
  final RoadmapPlan plan;

  const _SkillGapTab({required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackedSkills = ref.watch(trackedSkillsProvider);
    final trackedNames = trackedSkills.map((s) => s.name).toSet();
    final untrackedGaps =
        plan.skillGaps.where((g) => !trackedNames.contains(g.skill)).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEAE4F8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Skill Gap Detector',
                style: NaviTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'The roadmap below highlights the strongest next steps to keep you moving.',
                style: NaviTextStyles.bodyMedium.copyWith(
                  color: NaviColors.textMid,
                ),
              ),
              const SizedBox(height: 12),
              if (untrackedGaps.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'All skill gaps are being tracked!',
                    style: NaviTextStyles.bodyMedium.copyWith(
                      color: NaviColors.textMid,
                    ),
                  ),
                )
              else
                for (final gap in untrackedGaps)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _SkillGapTile(
                      gap: gap,
                      onTrackSkill: () {
                        final skill = TrackedSkill(
                          id: DateTime.now().microsecondsSinceEpoch.toString(),
                          name: gap.skill,
                          level: 1,
                          status: SkillStatus.learning,
                        );
                        ref.read(trackedSkillsProvider.notifier).add(skill);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${gap.skill} added to My Skills'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SkillGapTile extends StatelessWidget {
  final SkillGap gap;
  final VoidCallback? onTrackSkill;

  const _SkillGapTile({required this.gap, this.onTrackSkill});

  @override
  Widget build(BuildContext context) {
    final color = switch (gap.priority) {
      'High Priority' => NaviColors.sparkPink,
      'Medium Priority' => NaviColors.sparkYellow,
      'Low Priority' => NaviColors.sparkGreen,
      _ => NaviColors.matchHigh,
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gap.skill,
                  style: NaviTextStyles.label.copyWith(
                    color: NaviColors.textDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  gap.action,
                  style: NaviTextStyles.label.copyWith(
                    color: NaviColors.textMid,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          if (onTrackSkill != null) ...[
            const SizedBox(width: 10),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTrackSkill,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: NaviColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Track',
                    style: NaviTextStyles.label.copyWith(
                      color: NaviColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
          if (onTrackSkill == null) ...[
            const SizedBox(width: 10),
            Icon(
              Icons.chevron_right_rounded,
              color: NaviColors.textDark.withValues(alpha: 0.65),
            ),
          ],
        ],
      ),
    );
  }
}

class _RoadmapEmptyState extends StatelessWidget {
  final VoidCallback onStartAssessment;

  const _RoadmapEmptyState({required this.onStartAssessment});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/mascots/orbit/orbit 5.png',
              width: 104,
              height: 104,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              'Your roadmap starts after the quiz.',
              textAlign: TextAlign.center,
              style: NaviTextStyles.heading2.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Answer 5 quick questions so Navi can build a career path tied to your top match.',
              textAlign: TextAlign.center,
              style: NaviTextStyles.bodyMedium,
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onStartAssessment,
              style: FilledButton.styleFrom(
                backgroundColor: NaviColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text('Start Assessment'),
            ),
          ],
        ),
      ),
    );
  }
}
