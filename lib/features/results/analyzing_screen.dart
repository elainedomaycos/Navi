import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/session_memory_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/app_providers.dart';
import '../quiz/quiz_session.dart';
import 'recommendation_engine.dart';
import 'results_screen.dart';
import '../../core/widgets/fade_slide_route.dart';

class AnalyzingScreen extends ConsumerStatefulWidget {
  final QuizSession session;

  const AnalyzingScreen({super.key, required this.session});

  @override
  ConsumerState<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends ConsumerState<AnalyzingScreen> {
  int _activeAgentIndex = 0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _runPipeline();
  }

  Future<void> _runPipeline() async {
    setState(() {
      _hasError = false;
      _activeAgentIndex = 0;
    });

    try {
      for (var i = 0; i < _agents.length; i++) {
        await Future.delayed(const Duration(milliseconds: 520));
        if (!mounted) return;
        setState(() {
          _activeAgentIndex = i;
        });
      }

      await Future.delayed(const Duration(milliseconds: 650));
      if (!mounted) return;

      final trackedSkills = ref.read(trackedSkillsProvider);
      final result = await RecommendationEngine.generateWithAI(
        widget.session,
        trackedSkills: trackedSkills,
      );
      if (!mounted) return;
      ref.read(recommendationResultProvider.notifier).setResult(result);
      SessionMemoryService.save(session: widget.session, result: result);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        FadeSlideRoute(
          child: ResultsScreen(
            session: widget.session,
            result: result,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NaviColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_hasError)
                _ErrorState(onRetry: _runPipeline)
              else ...[
                Text(
                  'Hang tight!',
                  style: NaviTextStyles.heading1.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(
                      begin: -0.08,
                      end: 0,
                      curve: Curves.easeOut,
                    ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    style: NaviTextStyles.heading2.copyWith(height: 1.2),
                    children: const [
                      TextSpan(text: 'Our '),
                      TextSpan(
                        text: 'AI agents',
                        style: TextStyle(color: NaviColors.primaryLight),
                      ),
                      TextSpan(text: ' are\nanalyzing your profile.'),
                    ],
                  ),
                ).animate(delay: 100.ms).fadeIn(duration: 500.ms),
                const SizedBox(height: 22),
                Expanded(
                  child: ListView.separated(
                    itemCount: _agents.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _AgentCard(
                        agent: _agents[index],
                        active: index <= _activeAgentIndex,
                      )
                          .animate(
                            delay: (150 + index * 60).ms,
                          )
                          .fadeIn(
                            duration: 500.ms,
                          )
                          .slideY(
                            begin: 0.06,
                            end: 0,
                            curve: Curves.easeOut,
                          );
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: NaviColors.primaryPale,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    'This usually takes 20-30 seconds.',
                    textAlign: TextAlign.center,
                    style: NaviTextStyles.label.copyWith(
                      color: NaviColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ).animate(delay: 400.ms).fadeIn(duration: 500.ms),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AgentCard extends StatelessWidget {
  final _AgentStep agent;
  final bool active;

  const _AgentCard({
    required this.agent,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: active ? NaviColors.primaryPale : const Color(0xFFEAE4F8),
          width: active ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: agent.tint.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Image.asset(agent.asset, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: agent.name,
                    style: const TextStyle(
                      color: NaviColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextSpan(text: ' ${agent.message}'),
                ],
              ),
              style: NaviTextStyles.bodyMedium.copyWith(
                color: NaviColors.textDark,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              value: active ? null : 0,
              color: NaviColors.primary,
              backgroundColor: NaviColors.primaryPale,
            ),
          ),
        ],
      ),
    );
  }
}

class _AgentStep {
  final String name;
  final String message;
  final String asset;
  final Color tint;

  const _AgentStep({
    required this.name,
    required this.message,
    required this.asset,
    required this.tint,
  });
}

// ── Error state ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: NaviColors.matchLow.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: NaviColors.matchLow,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: NaviTextStyles.heading2.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'We could not analyze your profile.\nPlease try again.',
              textAlign: TextAlign.center,
              style: NaviTextStyles.bodyMedium,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
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
            ),
          ],
        ),
      ),
    );
  }
}

const _agents = <_AgentStep>[
  _AgentStep(
    name: 'Byte',
    message: 'is analyzing your skills...',
    asset: 'assets/images/mascots/byte/byte 2.png',
    tint: NaviColors.sparkBlue,
  ),
  _AgentStep(
    name: 'Flux',
    message: 'is exploring job opportunities...',
    asset: 'assets/images/mascots/flux/flux 3.png',
    tint: NaviColors.sparkTeal,
  ),
  _AgentStep(
    name: 'Echo',
    message: 'is matching you with career paths...',
    asset: 'assets/images/mascots/echo/echo 2.png',
    tint: NaviColors.sparkGreen,
  ),
  _AgentStep(
    name: 'Orbit',
    message: 'is building your personalized roadmap...',
    asset: 'assets/images/mascots/orbit/orbit 2.png',
    tint: NaviColors.sparkYellow,
  ),
  _AgentStep(
    name: 'Nova',
    message: 'is refining recommendations...',
    asset: 'assets/images/mascots/nova/nova 2.png',
    tint: NaviColors.sparkPurple,
  ),
];
