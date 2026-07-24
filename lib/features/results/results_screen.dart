import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../compare/compare_screen.dart';
import '../export/pdf_export_sheet.dart';
import '../feedback/feedback_screen.dart';
import '../quiz/quiz_session.dart';
import '../roadmap/roadmap_engine.dart';
import '../../providers/app_providers.dart';
import 'recommendation_result.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  final QuizSession session;
  final RecommendationResult result;

  const ResultsScreen({
    super.key,
    required this.session,
    required this.result,
  });

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  late RecommendationResult _result;

  @override
  void initState() {
    super.initState();
    _result = widget.result;
  }

  Future<void> _openFeedback() async {
    final trackedSkills = ref.read(trackedSkillsProvider);
    final refined = await Navigator.of(context).push<RecommendationResult>(
      MaterialPageRoute(
        builder: (_) => FeedbackScreen(
          session: widget.session,
          currentResult: _result,
          trackedSkills: trackedSkills,
        ),
      ),
    );

    if (!mounted || refined == null) return;

    setState(() => _result = refined);
  }

  void _openCompare() {
    final trackedSkills = ref.read(trackedSkillsProvider);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CompareScreen(
          session: widget.session,
          result: _result,
          trackedSkills: trackedSkills,
        ),
      ),
    );
  }

  Future<void> _openExportPdf() async {
    final plan = await RoadmapEngine.generate(
      session: widget.session,
      recommendation: _result.topMatch,
    );
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PdfExportSheet(
        match: _result.topMatch,
        roadmap: plan,
        session: widget.session,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topMatch = _result.topMatch;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          Navigator.of(context).pop(_result);
        }
      },
      child: Scaffold(
        backgroundColor: NaviColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ResultsHeader(
                  onClose: () => Navigator.of(context).pop(_result),
                ).animate().fadeIn(duration: 500.ms).slideY(
                      begin: -0.08,
                      end: 0,
                      curve: Curves.easeOut,
                    ),
                const SizedBox(height: 18),
                Text(
                  'Your Top Career Matches',
                  style: NaviTextStyles.heading1.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ).animate(delay: 100.ms).fadeIn(duration: 500.ms),
                const SizedBox(height: 4),
                const Text(
                  'Based on your profile and PH job market data',
                  style: NaviTextStyles.label,
                ).animate(delay: 150.ms).fadeIn(duration: 500.ms),
                const SizedBox(height: 16),
                _TopMatchCard(match: topMatch)
                    .animate(delay: 200.ms)
                    .fadeIn(
                      duration: 600.ms,
                    )
                    .slideY(begin: 0.06, end: 0, curve: Curves.easeOut),
                const SizedBox(height: 12),
                ..._result.matches.skip(1).toList().asMap().entries.map(
                  (entry) {
                    final delay = 300 + entry.key * 80;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _CompactMatchTile(
                        match: entry.value,
                        rank: _result.matches.indexOf(entry.value) + 1,
                      )
                          .animate(delay: delay.ms)
                          .fadeIn(
                            duration: 500.ms,
                          )
                          .slideY(
                            begin: 0.06,
                            end: 0,
                            curve: Curves.easeOut,
                          ),
                    );
                  },
                ),
                const SizedBox(height: 6),
                _MarketIntelligenceCard(match: topMatch)
                    .animate(
                      delay: 450.ms,
                    )
                    .fadeIn(duration: 600.ms)
                    .slideY(
                      begin: 0.06,
                      end: 0,
                      curve: Curves.easeOut,
                    ),
                const SizedBox(height: 12),
                _WhyMatchCard(match: topMatch)
                    .animate(delay: 530.ms)
                    .fadeIn(
                      duration: 600.ms,
                    )
                    .slideY(begin: 0.06, end: 0, curve: Curves.easeOut),
                const SizedBox(height: 16),
                _ActionRow(
                  onRefine: _openFeedback,
                  onCompare: _openCompare,
                  onExportPdf: _openExportPdf,
                ).animate(delay: 620.ms).fadeIn(duration: 500.ms),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop(_result);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: NaviColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('View My Roadmap'),
                        SizedBox(width: 10),
                        Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                ).animate(delay: 700.ms).fadeIn(duration: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultsHeader extends StatelessWidget {
  final VoidCallback onClose;

  const _ResultsHeader({required this.onClose});

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
        IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close_rounded),
          color: NaviColors.textDark,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }
}

class _TopMatchCard extends StatelessWidget {
  final CareerRecommendation match;

  const _TopMatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5DEF8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _RankBadge(rank: 1),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match.title,
                      style: NaviTextStyles.heading2.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Badge(
                          label: '${match.confidence}% Match',
                          color: NaviColors.matchHigh,
                        ),
                        _Badge(
                          label: match.demand,
                          color: NaviColors.primaryLight,
                        ),
                        if (match.discoverable)
                          const _Badge(
                            label: 'Discoverable',
                            color: NaviColors.sparkPurple,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Image.asset(
                match.mascotAsset,
                width: 88,
                height: 88,
                fit: BoxFit.contain,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.payments_rounded,
                size: 18,
                color: NaviColors.textMid,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  match.salaryRange,
                  style: NaviTextStyles.label.copyWith(
                    color: NaviColors.textDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Top Employers',
            style: NaviTextStyles.label.copyWith(
              color: NaviColors.textDark,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: match.topEmployers
                .map(
                  (employer) => _EmployerChip(label: employer),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _CompactMatchTile extends StatelessWidget {
  final CareerRecommendation match;
  final int rank;

  const _CompactMatchTile({
    required this.match,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAE4F8)),
      ),
      child: Row(
        children: [
          _SmallRankBadge(rank: rank),
          const SizedBox(width: 12),
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: match.tint.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Image.asset(match.mascotAsset, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              match.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: NaviTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          _Badge(
            label: '${match.confidence}% Match',
            color: NaviColors.matchHigh,
            compact: true,
          ),
        ],
      ),
    );
  }
}

class _MarketIntelligenceCard extends StatelessWidget {
  final CareerRecommendation match;

  const _MarketIntelligenceCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final confidenceSeries = _sparklineValues(
      seed: match.id.hashCode ^ 11,
      base: match.confidence / 100,
    );
    final demandSeries = _sparklineValues(
      seed: match.id.hashCode ^ 23,
      base: _metricBaseFromText(match.demand),
    );
    final trendSeries = _sparklineValues(
      seed: match.id.hashCode ^ 37,
      base: _metricBaseFromText(match.trend),
    );

    return _InfoCard(
      title: 'PH Market Intelligence',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _MetricSparklineCard(
                  label: 'Confidence',
                  value: '${match.confidence}%',
                  icon: Icons.shield_rounded,
                  tint: NaviColors.matchHigh,
                  series: confidenceSeries,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricSparklineCard(
                  label: 'Demand',
                  value: match.demand,
                  icon: Icons.trending_up_rounded,
                  tint: NaviColors.sparkBlue,
                  series: demandSeries,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricSparklineCard(
                  label: 'Momentum',
                  value: match.trend,
                  icon: Icons.auto_graph_rounded,
                  tint: NaviColors.sparkPurple,
                  series: trendSeries,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.payments_rounded,
                  size: 18, color: NaviColors.primaryLight),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  match.salaryRange,
                  style: NaviTextStyles.bodyMedium.copyWith(
                    color: NaviColors.textDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.auto_graph_rounded,
                  size: 18, color: NaviColors.primaryLight),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      match.trend.toLowerCase().contains('up')
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_forward_rounded,
                      color: match.trend.toLowerCase().contains('up')
                          ? NaviColors.matchHigh
                          : NaviColors.textMuted,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        match.trend,
                        style: NaviTextStyles.bodyMedium.copyWith(
                          color: NaviColors.textDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricSparklineCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color tint;
  final List<double> series;

  const _MetricSparklineCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.tint,
    required this.series,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tint.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 28,
                width: 28,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: tint),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: NaviTextStyles.label.copyWith(
                    color: NaviColors.textDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: NaviTextStyles.bodyMedium.copyWith(
              color: NaviColors.textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          _Sparkline(series: series, color: tint),
        ],
      ),
    );
  }
}

class _Sparkline extends StatelessWidget {
  final List<double> series;
  final Color color;

  const _Sparkline({
    required this.series,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: series
            .map(
              (value) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.5),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: value.clamp(0.16, 1.0),
                      widthFactor: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

double _metricBaseFromText(String value) {
  final lower = value.toLowerCase();
  if (lower.contains('high') ||
      lower.contains('up') ||
      lower.contains('strong')) {
    return 0.84;
  }
  if (lower.contains('moderate') || lower.contains('stable')) {
    return 0.64;
  }
  if (lower.contains('low') ||
      lower.contains('down') ||
      lower.contains('soft')) {
    return 0.42;
  }
  return 0.58;
}

List<double> _sparklineValues({required int seed, required double base}) {
  final random = math.Random(seed);
  return List<double>.generate(7, (index) {
    final wave = math.sin((index / 6) * math.pi);
    final jitter = (random.nextDouble() - 0.5) * 0.16;
    return (0.22 + (base * 0.56) + (wave * 0.18) + jitter).clamp(0.16, 0.98);
  });
}

class _WhyMatchCard extends StatelessWidget {
  final CareerRecommendation match;

  const _WhyMatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Why this match',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(match.summary, style: NaviTextStyles.bodyMedium),
          const SizedBox(height: 10),
          ...match.reasons.map(
            (reason) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: NaviColors.matchHigh,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reason,
                      style: NaviTextStyles.bodyMedium.copyWith(
                        color: NaviColors.textDark,
                      ),
                    ),
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

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCard({
    required this.title,
    required this.child,
  });

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
          Text(
            title,
            style: NaviTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;

  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: NaviColors.sparkYellow,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$rank',
        style: NaviTextStyles.heading2.copyWith(
          fontWeight: FontWeight.w900,
          color: NaviColors.textDark,
        ),
      ),
    );
  }
}

class _SmallRankBadge extends StatelessWidget {
  final int rank;

  const _SmallRankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      width: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: NaviColors.primaryPale,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$rank',
        style: NaviTextStyles.label.copyWith(
          color: NaviColors.primary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final bool compact;

  const _Badge({
    required this.label,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: NaviTextStyles.label.copyWith(
          color: color,
          fontSize: compact ? 11 : 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _EmployerChip extends StatelessWidget {
  final String label;

  const _EmployerChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4FF),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: NaviTextStyles.label.copyWith(
          color: NaviColors.textDark,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ── Action row for refine + compare ───────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  final VoidCallback onRefine;
  final VoidCallback onCompare;
  final VoidCallback onExportPdf;

  const _ActionRow({
    required this.onRefine,
    required this.onCompare,
    required this.onExportPdf,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            icon: Icons.tune_rounded,
            label: 'Refine Results',
            subtitle: 'Tell us what you think',
            color: NaviColors.sparkPurple,
            onTap: onRefine,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionTile(
            icon: Icons.compare_arrows_rounded,
            label: 'Compare',
            subtitle: 'Side-by-side view',
            color: NaviColors.sparkBlue,
            onTap: onCompare,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionTile(
            icon: Icons.picture_as_pdf_rounded,
            label: 'Export PDF',
            subtitle: 'Save or share your report',
            color: NaviColors.sparkGreen,
            onTap: onExportPdf,
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEAE4F8)),
          ),
          child: Column(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: NaviTextStyles.label.copyWith(
                  color: NaviColors.textDark,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: NaviTextStyles.label.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
