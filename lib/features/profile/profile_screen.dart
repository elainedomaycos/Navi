import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_settings_sheet.dart';
import '../../core/services/sound_effect_service.dart';
import '../../providers/app_providers.dart';
import '../export/pdf_export_sheet.dart';
import '../quiz/quiz_session.dart';
import '../results/recommendation_result.dart';
import '../roadmap/roadmap_engine.dart';
import '../roadmap/roadmap_plan.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final QuizSession? session;
  final RecommendationResult? result;
  final VoidCallback onStartAssessment;

  const ProfileScreen({
    super.key,
    required this.session,
    required this.result,
    required this.onStartAssessment,
  });

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  RoadmapPlan? _plan;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.session != null &&
        widget.result != null &&
        (oldWidget.session == null || oldWidget.result == null)) {
      _load();
    }
  }

  Future<void> _load() async {
    final session = widget.session;
    final result = widget.result;
    if (session == null || result == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    final plan = await RoadmapEngine.generate(
      session: session,
      recommendation: result.topMatch,
    );
    if (!mounted) return;
    setState(() {
      _plan = plan;
      _loading = false;
    });
  }

  void _openExportPdf(RoadmapPlan plan) {
    final session = widget.session;
    final result = widget.result;
    if (session == null || result == null) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PdfExportSheet(
        match: result.topMatch,
        roadmap: plan,
        session: session,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final result = widget.result;
    final goals = ref.watch(goalsProvider);
    final skills = ref.watch(trackedSkillsProvider);

    if (session == null || result == null) {
      return _ProfileEmptyState(onStartAssessment: widget.onStartAssessment);
    }

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final plan = _plan!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileHeader(
            onStartAssessment: widget.onStartAssessment,
            onOpenSettings: () {
              showModalBottomSheet<void>(
                context: context,
                backgroundColor: const Color(0xFFF8F4FF),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                isScrollControlled: true,
                builder: (_) => const AppSettingsSheet(),
              );
            },
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: -0.08, end: 0, curve: Curves.easeOut),
          const SizedBox(height: 18),
          _TopMatchProfileCard(match: result.topMatch)
              .animate(delay: 150.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.06, end: 0, curve: Curves.easeOut),
          const SizedBox(height: 14),
          _QuizSummaryCard(session: session)
              .animate(delay: 300.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.06, end: 0, curve: Curves.easeOut),
          const SizedBox(height: 14),
          _RoadmapProgressCard(plan: plan)
              .animate(delay: 450.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.06, end: 0, curve: Curves.easeOut),
          const SizedBox(height: 14),
          _GoalsSummaryCard(goals: goals)
              .animate(delay: 500.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.06, end: 0, curve: Curves.easeOut),
          const SizedBox(height: 14),
          _SkillsSummaryCard(skills: skills)
              .animate(delay: 550.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.06, end: 0, curve: Curves.easeOut),
          const SizedBox(height: 14),
          _AnalyticsCard(result: result)
              .animate(delay: 600.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.06, end: 0, curve: Curves.easeOut),
          const SizedBox(height: 16),
          _QuickActions(
            onRetake: widget.onStartAssessment,
            onExportPdf: _plan != null ? () => _openExportPdf(_plan!) : null,
          )
              .animate(delay: 650.ms)
              .fadeIn(duration: 500.ms),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _ProfileEmptyState extends StatelessWidget {
  final VoidCallback onStartAssessment;

  const _ProfileEmptyState({required this.onStartAssessment});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 96,
              width: 96,
              decoration: const BoxDecoration(
                color: NaviColors.primaryPale,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  'assets/images/mascots/nova/nova 5.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Your profile is empty',
              style: NaviTextStyles.heading2.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Take the assessment to see your career matches, roadmap, and progress here.',
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

// ── Profile header ────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final VoidCallback onStartAssessment;
  final VoidCallback onOpenSettings;

  const _ProfileHeader({
    required this.onStartAssessment,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/images/navi_logo.png',
          height: 38,
          fit: BoxFit.contain,
        ),
        const Spacer(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                SoundEffectService.playTap();
                onOpenSettings();
              },
              icon: const Icon(Icons.tune_rounded),
              color: NaviColors.textDark,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onStartAssessment,
              icon: const Icon(Icons.refresh_rounded),
              color: NaviColors.textDark,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Top match profile card ────────────────────────────────────────────────────

class _TopMatchProfileCard extends StatelessWidget {
  final CareerRecommendation match;

  const _TopMatchProfileCard({required this.match});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            match.tint.withValues(alpha: 0.10),
            match.tint.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: match.tint.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            height: 68,
            width: 68,
            decoration: BoxDecoration(
              color: match.tint.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(match.mascotAsset, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Top Match',
                  style: NaviTextStyles.label.copyWith(
                    color: NaviColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  match.title,
                  style: NaviTextStyles.heading1.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: NaviColors.matchHigh.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '${match.confidence}% Match',
                    style: NaviTextStyles.label.copyWith(
                      color: NaviColors.matchHigh,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quiz summary card ─────────────────────────────────────────────────────────

class _QuizSummaryCard extends StatelessWidget {
  final QuizSession session;

  const _QuizSummaryCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Row(
            children: [
              const Icon(
                Icons.quiz_rounded,
                size: 18,
                color: NaviColors.primaryLight,
              ),
              const SizedBox(width: 8),
              Text(
                'Assessment Summary',
                style: NaviTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < session.answers.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      '${i + 1}.',
                      style: NaviTextStyles.label.copyWith(
                        color: NaviColors.primaryLight,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.answers[i].question,
                          style: NaviTextStyles.label.copyWith(
                            color: NaviColors.textDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          session.answers[i].answer,
                          style: NaviTextStyles.bodyMedium.copyWith(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Roadmap progress card ─────────────────────────────────────────────────────

class _RoadmapProgressCard extends StatelessWidget {
  final RoadmapPlan plan;

  const _RoadmapProgressCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final completedMilestones = plan.years.expand((y) => y.milestones).length;
    final highPriorityGaps =
        plan.skillGaps.where((g) => g.priority == 'High Priority').length;

    return Container(
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
          Row(
            children: [
              const Icon(
                Icons.map_rounded,
                size: 18,
                color: NaviColors.primaryLight,
              ),
              const SizedBox(width: 8),
              Text(
                'Roadmap Progress',
                style: NaviTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _StatTile(
                icon: Icons.flag_rounded,
                value: '${plan.years.length}',
                label: 'Milestones',
                color: NaviColors.sparkBlue,
              ),
              _StatTile(
                icon: Icons.checklist_rounded,
                value: '$completedMilestones',
                label: 'Steps',
                color: NaviColors.matchHigh,
              ),
              _StatTile(
                icon: Icons.trending_up_rounded,
                value: '$highPriorityGaps',
                label: 'Focus areas',
                color: NaviColors.sparkPink,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalsSummaryCard extends StatelessWidget {
  final List<dynamic> goals;

  const _GoalsSummaryCard({required this.goals});

  @override
  Widget build(BuildContext context) {
    final inProgress = goals.where((g) => g.progressFromTasks > 0 && g.progressFromTasks < 100).length;
    final completed = goals.where((g) => g.progressFromTasks >= 100).length;

    return Container(
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
          Row(
            children: [
              const Icon(
                Icons.flag_rounded,
                size: 18,
                color: NaviColors.primaryLight,
              ),
              const SizedBox(width: 8),
              Text(
                'My Goals',
                style: NaviTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _StatTile(
                icon: Icons.list_alt_rounded,
                value: '${goals.length}',
                label: 'Total goals',
                color: NaviColors.sparkBlue,
              ),
              _StatTile(
                icon: Icons.pending_rounded,
                value: '$inProgress',
                label: 'In progress',
                color: NaviColors.sparkYellow,
              ),
              _StatTile(
                icon: Icons.check_circle_rounded,
                value: '$completed',
                label: 'Completed',
                color: NaviColors.matchHigh,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkillsSummaryCard extends StatelessWidget {
  final List<dynamic> skills;

  const _SkillsSummaryCard({required this.skills});

  @override
  Widget build(BuildContext context) {
    final proficient = skills.where((s) => s.status.toString() == 'SkillStatus.proficient' || s.status.toString() == 'SkillStatus.mastered').length;

    return Container(
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
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                size: 18,
                color: NaviColors.primaryLight,
              ),
              const SizedBox(width: 8),
              Text(
                'My Skills',
                style: NaviTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _StatTile(
                icon: Icons.person_rounded,
                value: '${skills.length}',
                label: 'Tracked',
                color: NaviColors.sparkBlue,
              ),
              _StatTile(
                icon: Icons.emoji_events_rounded,
                value: '$proficient',
                label: 'Proficient+',
                color: NaviColors.sparkYellow,
              ),
              _StatTile(
                icon: Icons.school_rounded,
                value: skills.isEmpty ? '0' : '${(skills.length - proficient).clamp(0, skills.length)}',
                label: 'Learning',
                color: NaviColors.sparkPink,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: NaviTextStyles.heading2.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: NaviTextStyles.label.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ── Quick actions ─────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  final VoidCallback onRetake;
  final VoidCallback? onExportPdf;

  const _QuickActions({
    required this.onRetake,
    this.onExportPdf,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (onExportPdf != null) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onExportPdf,
              icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
              label: const Text('Export Results as PDF'),
              style: FilledButton.styleFrom(
                backgroundColor: NaviColors.sparkGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onRetake,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retake Assessment'),
            style: OutlinedButton.styleFrom(
              foregroundColor: NaviColors.primary,
              side: const BorderSide(
                color: NaviColors.primaryPale,
                width: 1.5,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Analytics card ─────────────────────────────────────────────────────────────

class _AnalyticsCard extends StatelessWidget {
  final RecommendationResult result;

  const _AnalyticsCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final matches = result.matches;

    return Container(
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
          Row(
            children: [
              const Icon(
                Icons.analytics_rounded,
                size: 18,
                color: NaviColors.primaryLight,
              ),
              const SizedBox(width: 8),
              Text(
                'Match Analytics',
                style: NaviTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < matches.length; i++) ...[
            _MatchStrengthBar(
              rank: i + 1,
              title: matches[i].title,
              confidence: matches[i].confidence,
              tint: matches[i].tint,
            ),
            if (i < matches.length - 1) const SizedBox(height: 10),
          ],
          if (matches.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFEAE4F8)),
          ],
        ],
      ),
    );
  }
}

class _MatchStrengthBar extends StatelessWidget {
  final int rank;
  final String title;
  final int confidence;
  final Color tint;

  const _MatchStrengthBar({
    required this.rank,
    required this.title,
    required this.confidence,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          child: Text(
            '$rank',
            style: NaviTextStyles.label.copyWith(
              color: NaviColors.textMuted,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: NaviTextStyles.label.copyWith(
                  color: NaviColors.textDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: confidence / 100,
                  backgroundColor: tint.withValues(alpha: 0.14),
                  color: tint,
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$confidence%',
          style: NaviTextStyles.label.copyWith(
            color: NaviColors.textDark,
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
