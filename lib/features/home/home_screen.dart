import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/session_memory_service.dart';
import '../../core/services/sound_effect_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_settings_sheet.dart';
import '../../core/widgets/bottom_nav_bar.dart';
import '../../core/widgets/fade_slide_route.dart';
import '../../providers/app_providers.dart';
import '../explore/explore_screen.dart';
import '../profile/profile_screen.dart';
import '../quiz/quiz_screen.dart';
import '../quiz/quiz_session.dart';
import '../results/analyzing_screen.dart';
import '../roadmap/roadmap_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _restoreSession();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _restoreSession() async {
    final data = await SessionMemoryService.load();
    if (!mounted) return;
    ref.read(quizSessionProvider.notifier).setSession(data.session);
    ref.read(recommendationResultProvider.notifier).setResult(data.result);
  }

  Future<void> _handleStartAssessment() async {
    await SessionMemoryService.clear();
    if (!mounted) return;

    final session = await Navigator.of(context).push<QuizSession>(
      FadeSlideRoute(
        child: const QuizScreen(),
      ),
    );

    if (!mounted || session == null) return;

    ref.read(quizSessionProvider.notifier).setSession(session);

    await Navigator.of(context).push(
      FadeSlideRoute(
        child: AnalyzingScreen(session: session),
      ),
    );

    if (!mounted) return;

    final saved = ref.read(recommendationResultProvider);
    if (saved != null) {
      setState(() => _selectedIndex = 1);
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _openSettings() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFFF8F4FF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (_) => const AppSettingsSheet(),
    );
  }

    Future<void> _goToTab(int index) async {
      if (index == _selectedIndex) return;
      setState(() => _selectedIndex = index);
      await _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    }

  @override
  Widget build(BuildContext context) {
    final quizSession = ref.watch(quizSessionProvider);
    final result = ref.watch(recommendationResultProvider);

    final pages = <Widget>[
      KeyedSubtree(
        key: const PageStorageKey('home-tab-home'),
        child: _HomeTab(
          onStartAssessment: _handleStartAssessment,
          onOpenSettings: _openSettings,
        ),
      ),
      KeyedSubtree(
        key: const PageStorageKey('home-tab-roadmap'),
        child: RoadmapScreen(
          session: quizSession,
          result: result,
          onStartAssessment: _handleStartAssessment,
        ),
      ),
      KeyedSubtree(
        key: const PageStorageKey('home-tab-explore'),
        child: ExploreScreen(
          session: quizSession,
          result: result,
        ),
      ),
      KeyedSubtree(
        key: const PageStorageKey('home-tab-profile'),
        child: ProfileScreen(
          session: quizSession,
          result: result,
          onStartAssessment: _handleStartAssessment,
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: NaviColors.background,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            if (_selectedIndex != index) {
              setState(() => _selectedIndex = index);
            }
          },
          children: pages,
        ),
      ),
      bottomNavigationBar: NaviBottomNavBar(
        currentIndex: _selectedIndex,
        onChanged: _goToTab,
        onCenterAction: _handleStartAssessment,
      ),
    )
        .animate()
        .fadeIn(duration: 420.ms)
        .slideY(begin: 0.06, end: 0, curve: Curves.easeOut);
  }
}

// ── Home Tab ──────────────────────────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  final VoidCallback onStartAssessment;
  final VoidCallback onOpenSettings;

  const _HomeTab({
    required this.onStartAssessment,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TopBar(
            onStartAssessment: onStartAssessment,
            onOpenSettings: onOpenSettings,
          ),
          const SizedBox(height: 18),
          _HeroCard(onStartAssessment: onStartAssessment),
          const SizedBox(height: 18),
          const _QuickStatsRow(),
          const SizedBox(height: 26),
          const _SectionHeader(
            title: 'Everything in one place',
            subtitle: 'A clearer path from discovery to decision.',
          ),
          const SizedBox(height: 14),
          const _FeatureGrid(),
          const SizedBox(height: 28),
          const _SectionHeader(title: 'How it works'),
          const SizedBox(height: 12),
          const _HowItWorksList(),
          const SizedBox(height: 28),
          const _SectionHeader(title: 'Your AI Crew'),
          const SizedBox(height: 14),
          const _CrewSection(),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.05, end: 0, curve: Curves.easeOut);
  }
}

// ── Top Navigation ────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final VoidCallback onStartAssessment;
  final VoidCallback onOpenSettings;

  const _TopBar({
    required this.onStartAssessment,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/navi_logo.png',
              height: 40,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 4),
            Text(
              'navigate your future',
              style: NaviTextStyles.label.copyWith(
                color: NaviColors.textLight,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const Spacer(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                SoundEffectService.playTap();
                onOpenSettings();
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: NaviColors.textDark,
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                SoundEffectService.playTap();
                onStartAssessment();
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.menu_rounded,
                  color: NaviColors.textDark,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final VoidCallback onStartAssessment;

  const _HeroCard({required this.onStartAssessment});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF4F0FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: NaviColors.primaryPale.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              'For Filipino IT students',
              style: NaviTextStyles.label.copyWith(
                color: NaviColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text.rich(
            TextSpan(
              style: NaviTextStyles.heading1.copyWith(height: 1.2),
              children: const [
                TextSpan(text: 'Not just a quiz.\nYour '),
                TextSpan(
                  text: 'career',
                  style: TextStyle(color: NaviColors.primaryLight),
                ),
                TextSpan(text: ' journey, powered by AI.'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI-powered career matching for Filipino IT students, grounded in Philippine job market data.',
            style: NaviTextStyles.bodyMedium.copyWith(
              color: NaviColors.textMid,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              _MiniMetric(
                label: 'Top matches',
                value: '3',
                tint: NaviColors.sparkBlue,
              ),
              SizedBox(width: 10),
              _MiniMetric(
                label: 'Roadmap',
                value: 'Yearly',
                tint: NaviColors.sparkGreen,
              ),
              SizedBox(width: 10),
              _MiniMetric(
                label: 'Based on',
                value: 'PH data',
                tint: NaviColors.sparkYellow,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Center(
            child: Image.asset(
              'assets/images/navi_characters.png',
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                SoundEffectService.playConfirm();
                onStartAssessment();
              },
              style: FilledButton.styleFrom(
                backgroundColor: NaviColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Start Assessment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Fast assessment',
            value: '5 questions',
            icon: Icons.bolt_rounded,
            color: NaviColors.sparkYellow,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Personalized path',
            value: 'Roadmap + matches',
            icon: Icons.route_rounded,
            color: NaviColors.sparkTeal,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: NaviColors.primaryPale.withValues(alpha: 0.65)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: NaviTextStyles.bodyLarge.copyWith(
              color: NaviColors.textDark,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: NaviTextStyles.label.copyWith(
              color: NaviColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.08, end: 0);
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color tint;

  const _MiniMetric({
    required this.label,
    required this.value,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tint.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: NaviTextStyles.bodyMedium.copyWith(
                color: NaviColors.textDark,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: NaviTextStyles.label.copyWith(
                color: NaviColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: NaviTextStyles.heading2.copyWith(fontWeight: FontWeight.w900),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style:
                NaviTextStyles.bodyMedium.copyWith(color: NaviColors.textMid),
          ),
        ],
      ],
    );
  }
}

// ── Feature Grid ──────────────────────────────────────────────────────────────

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  static const _features = <_FeatureItem>[
    _FeatureItem(
      icon: Icons.psychology_alt_rounded,
      title: 'AI-powered Matching',
      subtitle: 'Turns quiz answers into ranked career paths.',
      color: NaviColors.primary,
    ),
    _FeatureItem(
      icon: Icons.bar_chart_rounded,
      title: 'PH Market Intelligence',
      subtitle: 'Salary ranges, demand, trends, and top employers.',
      color: NaviColors.matchHigh,
    ),
    _FeatureItem(
      icon: Icons.route_rounded,
      title: 'Personalized Roadmap',
      subtitle: 'A year-by-year career development plan.',
      color: NaviColors.sparkBlue,
    ),
    _FeatureItem(
      icon: Icons.details_rounded,
      title: 'Skill Gap Detector',
      subtitle: 'Finds missing competencies and learning resources.',
      color: NaviColors.sparkYellow,
    ),
    _FeatureItem(
      icon: Icons.tune_rounded,
      title: 'Adaptive Recommendations',
      subtitle: 'Improves suggestions based on your feedback.',
      color: NaviColors.sparkPink,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _features
          .map(
            (f) => SizedBox(
              width: (MediaQuery.of(context).size.width - 48) / 2,
              child: _FeatureCard(item: f),
            ),
          )
          .toList(),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final _FeatureItem item;

  const _FeatureCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: NaviColors.primaryPale.withValues(alpha: 0.55)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x07000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: item.color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: NaviTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.subtitle,
            style: NaviTextStyles.bodyMedium.copyWith(
              color: NaviColors.textMid,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

// ── How It Works ──────────────────────────────────────────────────────────────

class _HowItWorksList extends StatelessWidget {
  const _HowItWorksList();

  static const _steps = <_HowItWorksStep>[
    _HowItWorksStep(
      number: '01',
      title: 'Take the quiz',
      subtitle:
          'Answer 5 quick questions about your major, interests, skills, work style, and goals.',
    ),
    _HowItWorksStep(
      number: '02',
      title: 'Get your matches',
      subtitle:
          'See your top 3 career paths ranked by alignment, with salary data and market trends.',
    ),
    _HowItWorksStep(
      number: '03',
      title: 'Explore your roadmap',
      subtitle:
          'Receive a year-by-year plan with milestones, skill gaps, and learning resources.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _steps
          .map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _HowItWorksTile(step: s),
            ),
          )
          .toList(),
    );
  }
}

class _HowItWorksTile extends StatelessWidget {
  final _HowItWorksStep step;

  const _HowItWorksTile({required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: NaviColors.primaryPale,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              step.number,
              style: NaviTextStyles.label.copyWith(
                color: NaviColors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: NaviTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  step.subtitle,
                  style: NaviTextStyles.bodyMedium.copyWith(
                    color: NaviColors.textMid,
                    height: 1.3,
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

class _HowItWorksStep {
  final String number;
  final String title;
  final String subtitle;

  const _HowItWorksStep({
    required this.number,
    required this.title,
    required this.subtitle,
  });
}

// ── AI Crew Section ───────────────────────────────────────────────────────────

class _CrewSection extends StatelessWidget {
  const _CrewSection();

  static const _crew = <_CrewMember>[
    _CrewMember(
      name: 'Brit',
      asset: 'assets/images/mascots/brit/brit 3.png',
      tint: NaviColors.sparkPink,
      role: 'Creative strategist',
    ),
    _CrewMember(
      name: 'Byte',
      asset: 'assets/images/mascots/byte/byte 3.png',
      tint: NaviColors.sparkBlue,
      role: 'Data analyst',
    ),
    _CrewMember(
      name: 'Echo',
      asset: 'assets/images/mascots/echo/echo 4.png',
      tint: NaviColors.sparkGreen,
      role: 'Career matchmaker',
    ),
    _CrewMember(
      name: 'Flux',
      asset: 'assets/images/mascots/flux/flux 3.png',
      tint: NaviColors.sparkTeal,
      role: 'Market researcher',
    ),
    _CrewMember(
      name: 'Nova',
      asset: 'assets/images/mascots/nova/nova 3.png',
      tint: NaviColors.sparkPurple,
      role: 'Roadmap guide',
    ),
    _CrewMember(
      name: 'Orbit',
      asset: 'assets/images/mascots/orbit/orbit 3.png',
      tint: NaviColors.sparkYellow,
      role: 'Big-picture thinker',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Meet your six AI career guides. Each specializes in a different part of your career journey and works together to build your personalized roadmap.',
            style: NaviTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ...List.generate((_crew.length + 1) ~/ 2, (rowIndex) {
            final i = rowIndex * 2;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Expanded(child: _CrewCard(member: _crew[i])),
                  if (i + 1 < _crew.length) ...[
                    const SizedBox(width: 10),
                    Expanded(child: _CrewCard(member: _crew[i + 1])),
                  ] else
                    const Expanded(child: SizedBox.shrink()),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CrewCard extends StatelessWidget {
  final _CrewMember member;

  const _CrewCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: member.tint.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: member.tint.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Image.asset(member.asset, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            member.name,
            style: NaviTextStyles.label.copyWith(
              color: NaviColors.textDark,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            member.role,
            style: NaviTextStyles.label.copyWith(
              color: NaviColors.textMid,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CrewMember {
  final String name;
  final String asset;
  final Color tint;
  final String role;

  const _CrewMember({
    required this.name,
    required this.asset,
    required this.tint,
    required this.role,
  });
}

// ── Page transition ───────────────────────────────────────────────────────────

// Use shared FadeSlideRoute from core widgets (kept in separate file).
