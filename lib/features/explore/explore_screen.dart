import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/models/ph_career.dart';
import '../../core/services/career_data_service.dart';
import '../../core/services/sound_effect_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../compare/compare_screen.dart';
import '../quiz/quiz_session.dart';
import '../results/recommendation_result.dart';

class ExploreScreen extends StatefulWidget {
  final QuizSession? session;
  final RecommendationResult? result;

  const ExploreScreen({
    super.key,
    this.session,
    this.result,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  List<PhCareer> _allCareers = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await CareerDataService.load();
    if (!mounted) return;
    setState(() {
      _allCareers = data.careers;
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PhCareer> get _filtered {
    if (_query.isEmpty) return _allCareers;
    final q = _query.toLowerCase();
    return _allCareers.where((c) {
      return c.title.toLowerCase().contains(q) ||
          c.interestTags.any((t) => t.toLowerCase().contains(q)) ||
          c.workStyleTags.any((t) => t.toLowerCase().contains(q)) ||
          c.relatedSkills.any((s) => s.toLowerCase().contains(q)) ||
          c.topEmployers.any((e) => e.toLowerCase().contains(q));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final filtered = _filtered;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore Careers',
            style: NaviTextStyles.heading1.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Browse IT career paths in the Philippine market',
            style: NaviTextStyles.label,
          ),
          const SizedBox(height: 16),
          _SearchBar(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 20),
          if (filtered.isEmpty)
            _EmptySearch(query: _query)
          else
            ...filtered.map(
              (career) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ExploreCareerCard(
                  career: career,
                  onTap: () {
                    SoundEffectService.playTap();
                    _showCareerDetail(context, career);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showCareerDetail(BuildContext context, PhCareer career) {
    final session = widget.session;
    final result = widget.result;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _CareerDetailSheet(
        career: career,
        session: session,
        result: result,
      ),
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAE4F8)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: NaviTextStyles.bodyMedium.copyWith(
          color: NaviColors.textDark,
        ),
        decoration: InputDecoration(
          hintText: 'Search careers, skills, or employers...',
          hintStyle: NaviTextStyles.bodyMedium,
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: NaviColors.textMuted,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear_rounded,
                    size: 18,
                    color: NaviColors.textMuted,
                  ),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

// ── Empty search state ────────────────────────────────────────────────────────

class _EmptySearch extends StatelessWidget {
  final String query;

  const _EmptySearch({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 48,
              color: NaviColors.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              'No careers match "$query"',
              textAlign: TextAlign.center,
              style: NaviTextStyles.bodyMedium.copyWith(
                color: NaviColors.textDark,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Try a different search term',
              style: NaviTextStyles.label,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Career card ───────────────────────────────────────────────────────────────

class _ExploreCareerCard extends StatelessWidget {
  final PhCareer career;
  final VoidCallback onTap;

  const _ExploreCareerCard({
    required this.career,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final demandColor = switch (career.demandLevel.toLowerCase()) {
      'high' => NaviColors.matchHigh,
      'medium' => NaviColors.matchMed,
      _ => NaviColors.matchLow,
    };

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEAE4F8)),
          ),
          child: Row(
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: career.tint.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Image.asset(
                    career.mascotAsset,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      career.title,
                      style: NaviTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      career.salaryRange.display,
                      style: NaviTextStyles.label.copyWith(
                        color: NaviColors.textDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: demandColor.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            career.demandLabel,
                            style: NaviTextStyles.label.copyWith(
                              color: demandColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        if (career.discoverable)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: NaviColors.sparkPurple
                                  .withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              'Discoverable',
                              style: NaviTextStyles.label.copyWith(
                                color: NaviColors.sparkPurple,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: NaviColors.textMuted,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 380.ms)
        .slideY(begin: 0.05, end: 0, curve: Curves.easeOut);
  }
}

// ── Career detail bottom sheet ────────────────────────────────────────────────

class _CareerDetailSheet extends StatelessWidget {
  final PhCareer career;
  final QuizSession? session;
  final RecommendationResult? result;

  const _CareerDetailSheet({
    required this.career,
    this.session,
    this.result,
  });

  @override
  Widget build(BuildContext context) {
    final demandColor = switch (career.demandLevel.toLowerCase()) {
      'high' => NaviColors.matchHigh,
      'medium' => NaviColors.matchMed,
      _ => NaviColors.matchLow,
    };

    return Container(
      decoration: const BoxDecoration(
        color: NaviColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: NaviColors.textMuted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      color: career.tint.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        career.mascotAsset,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          career.title,
                          style: NaviTextStyles.heading2.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: demandColor.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                career.demandLabel,
                                style: NaviTextStyles.label.copyWith(
                                  color: demandColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            Text(
                              career.salaryRange.display,
                              style: NaviTextStyles.label.copyWith(
                                color: NaviColors.textDark,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (career.interestTags.isNotEmpty) ...[
                Text(
                  career.interestTags.join(' · '),
                  style: NaviTextStyles.bodyMedium.copyWith(
                    color: NaviColors.textDark,
                  ),
                  softWrap: true,
                ),
                const SizedBox(height: 14),
              ],
              Row(
                children: [
                  const Icon(
                    Icons.business_rounded,
                    size: 16,
                    color: NaviColors.primaryLight,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Top employers: ',
                    style: NaviTextStyles.label.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      career.topEmployers.join(', '),
                      style: NaviTextStyles.label.copyWith(
                        color: NaviColors.textDark,
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (career.relatedSkills.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.build_rounded,
                      size: 16,
                      color: NaviColors.primaryLight,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Skills: ',
                      style: NaviTextStyles.label.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        career.relatedSkills.join(', '),
                        style: NaviTextStyles.label.copyWith(
                          color: NaviColors.textDark,
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    final s = session;
                    final r = result;
                    if (s != null && r != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CompareScreen(
                            session: s,
                            result: r,
                          ),
                        ),
                      );
                    }
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
                      Text('Compare with Other Careers'),
                      SizedBox(width: 10),
                      Icon(Icons.compare_arrows_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
