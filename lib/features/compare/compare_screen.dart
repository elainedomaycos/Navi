import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../quiz/quiz_session.dart';
import '../results/recommendation_engine.dart';
import '../results/recommendation_result.dart';
import '../roadmap/models/tracked_skill.dart';

class CompareScreen extends StatefulWidget {
  final QuizSession session;
  final RecommendationResult result;
  final List<TrackedSkill> trackedSkills;

  const CompareScreen({
    super.key,
    required this.session,
    required this.result,
    this.trackedSkills = const [],
  });

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  List<CareerRecommendation> _allCareers = [];
  late CareerRecommendation _leftCareer;
  late CareerRecommendation _rightCareer;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await RecommendationEngine.compareCareers(
      widget.session,
      trackedSkills: widget.trackedSkills,
    );
    if (!mounted) return;
    setState(() {
      _allCareers = all;
      _leftCareer = _matchById(all, widget.result.matches[0].id) ?? all[0];
      _rightCareer = widget.result.matches.length > 1
          ? _matchById(all, widget.result.matches[1].id) ?? all[1]
          : all[1];
      _loading = false;
    });
  }

  CareerRecommendation? _matchById(List<CareerRecommendation> list, String id) {
    for (final c in list) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                    onPressed: () => Navigator.of(context).pop(),
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
                  Expanded(
                    child: Text(
                      'Compare two career paths side by side.',
                      style: NaviTextStyles.bodyMedium.copyWith(
                        color: NaviColors.textDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                child: Column(
                  children: [
                    // Career pickers row
                    Row(
                      children: [
                        Expanded(
                          child: _CareerPicker(
                            selected: _leftCareer,
                            allCareers: _allCareers,
                            exclude: _rightCareer,
                            onChanged: (c) => setState(() => _leftCareer = c),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: NaviColors.primaryPale,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.compare_arrows_rounded,
                              color: NaviColors.primary,
                              size: 20,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _CareerPicker(
                            selected: _rightCareer,
                            allCareers: _allCareers,
                            exclude: _leftCareer,
                            onChanged: (c) => setState(() => _rightCareer = c),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Comparison table
                    _CompareTable(
                      left: _leftCareer,
                      right: _rightCareer,
                    ),

                    const SizedBox(height: 16),

                    // Best for cards
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _BestForCard(career: _leftCareer),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _BestForCard(career: _rightCareer),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // CTA
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
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
                            Text('View Detailed Roadmap'),
                            SizedBox(width: 10),
                            Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Career dropdown picker ────────────────────────────────────────────────────

class _CareerPicker extends StatelessWidget {
  final CareerRecommendation selected;
  final List<CareerRecommendation> allCareers;
  final CareerRecommendation exclude;
  final ValueChanged<CareerRecommendation> onChanged;

  const _CareerPicker({
    required this.selected,
    required this.allCareers,
    required this.exclude,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = allCareers.where((c) => c.id != exclude.id).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAE4F8)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CareerRecommendation>(
          value: options.any((c) => c.id == selected.id)
              ? selected
              : options.first,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: NaviColors.primaryLight,
            size: 20,
          ),
          style: NaviTextStyles.bodyMedium.copyWith(
            color: NaviColors.textDark,
            fontWeight: FontWeight.w800,
          ),
          items: options
              .map(
                 (c) => DropdownMenuItem(
                   value: c,
                   child: Row(
                     children: [
                       Container(
                         height: 28,
                         width: 28,
                         decoration: BoxDecoration(
                           color: c.tint.withValues(alpha: 0.16),
                           shape: BoxShape.circle,
                         ),
                         child: Padding(
                           padding: const EdgeInsets.all(3),
                           child: Image.asset(
                             c.mascotAsset,
                             fit: BoxFit.contain,
                           ),
                         ),
                       ),
                       const SizedBox(width: 8),
                       Expanded(
                         child: Text(
                           c.title,
                           maxLines: 1,
                           overflow: TextOverflow.ellipsis,
                           style: NaviTextStyles.label.copyWith(
                             color: NaviColors.textDark,
                             fontWeight: FontWeight.w900,
                           ),
                         ),
                       ),
                     ],
                   ),
                 ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }
}

// ── Main comparison table ─────────────────────────────────────────────────────

class _CompareTable extends StatelessWidget {
  final CareerRecommendation left;
  final CareerRecommendation right;

  const _CompareTable({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    final rows = [
      _CompareRowData(
        label: 'Match',
        leftValue: '${left.confidence}%',
        rightValue: '${right.confidence}%',
        icon: Icons.percent_rounded,
        leftBetter: left.confidence >= right.confidence,
      ),
      _CompareRowData(
        label: 'Salary (PH)',
        leftValue: _shortSalary(left.salaryRange),
        rightValue: _shortSalary(right.salaryRange),
        icon: Icons.payments_rounded,
      ),
      _CompareRowData(
        label: 'Demand',
        leftValue: _demandLabel(left.demand),
        rightValue: _demandLabel(right.demand),
        icon: Icons.trending_up_rounded,
      ),
      _CompareRowData(
        label: 'Difficulty',
        leftValue: _difficulty(left.id),
        rightValue: _difficulty(right.id),
        icon: Icons.bar_chart_rounded,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAE4F8)),
      ),
      child: Column(
        children: [
          // Column headers with mascots
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
            child: Row(
              children: [
                 const SizedBox(width: 80), // label column space
                Expanded(child: _CareerHeader(career: left)),
                Expanded(child: _CareerHeader(career: right)),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0EBF8)),

          // Data rows
          ...rows.asMap().entries.map((entry) {
            final isLast = entry.key == rows.length - 1;
            return _CompareRow(
              data: entry.value,
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }

  String _shortSalary(String salary) {
    // "PHP 45K - 80K / month" → "₱45K–80K"
    final cleaned = salary
        .replaceAll('PHP ', '₱')
        .replaceAll(' / month', '')
        .replaceAll(' - ', '–');
    return cleaned;
  }

  String _demandLabel(String demand) {
    if (demand.toLowerCase().contains('high')) return 'High';
    if (demand.toLowerCase().contains('medium')) return 'Medium';
    return 'Low';
  }

  String _difficulty(String id) {
    switch (id) {
      case 'data_analyst':
      case 'service_manager':
      case 'business_analyst':
      case 'project_manager':
      case 'scrum_master':
      case 'product_owner':
      case 'qa_analyst':
      case 'it_auditor':
      case 'erp_consultant':
        return 'Medium';
      case 'systems_analyst':
      case 'data_scientist':
      case 'cybersecurity_analyst':
        return 'High';
      case 'ux_designer':
        return 'Medium';
      default:
        return 'Medium';
    }
  }
}

class _CareerHeader extends StatelessWidget {
  final CareerRecommendation career;

  const _CareerHeader({required this.career});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: career.tint.withValues(alpha: 0.16),
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Image.asset(career.mascotAsset, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          career.title,
          textAlign: TextAlign.center,
          style: NaviTextStyles.label.copyWith(
            color: NaviColors.textDark,
            fontWeight: FontWeight.w900,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _CompareRowData {
  final String label;
  final String leftValue;
  final String rightValue;
  final IconData icon;
  final bool? leftBetter;

  const _CompareRowData({
    required this.label,
    required this.leftValue,
    required this.rightValue,
    required this.icon,
    this.leftBetter,
  });
}

class _CompareRow extends StatelessWidget {
  final _CompareRowData data;
  final bool isLast;

  const _CompareRow({required this.data, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFF0EBF8)),
              ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Row(
                children: [
                  Icon(data.icon, size: 16, color: NaviColors.primaryLight),
                  const SizedBox(width: 6),
                  Text(
                    data.label,
                    style: NaviTextStyles.label.copyWith(
                      color: NaviColors.textDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _CompareCell(
                value: data.leftValue,
                highlight: data.leftBetter == true,
              ),
            ),
            Expanded(
              child: _CompareCell(
                value: data.rightValue,
                highlight: data.leftBetter == false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompareCell extends StatelessWidget {
  final String value;
  final bool highlight;

  const _CompareCell({required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: highlight
            ? NaviColors.matchHigh.withValues(alpha: 0.10)
            : NaviColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        value,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: NaviTextStyles.bodyMedium.copyWith(
          color: highlight ? NaviColors.matchHigh : NaviColors.textDark,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }
}

// ── Best for card ─────────────────────────────────────────────────────────────

class _BestForCard extends StatelessWidget {
  final CareerRecommendation career;

  const _BestForCard({required this.career});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAE4F8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Best for',
            style: NaviTextStyles.label.copyWith(
              color: NaviColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            career.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: NaviTextStyles.label.copyWith(
              color: NaviColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            career.summary,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: NaviTextStyles.bodyMedium.copyWith(
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
