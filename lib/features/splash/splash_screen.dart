import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/sparkle_widget.dart';
import '../home/home_screen.dart';
import '../../core/widgets/fade_slide_route.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0.0;
  int _messageIndex = 0;

  final List<String> _messages = [
    'Charting your best path...',
    'Analyzing career data...',
    'Preparing your journey...',
  ];

  @override
  void initState() {
    super.initState();
    _runLoading();
  }

  Future<void> _runLoading() async {
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 280));
      if (!mounted) return;
      setState(() {
        _progress = i / 10;
        if (i == 4) _messageIndex = 1;
        if (i == 7) _messageIndex = 2;
      });
    }
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      FadeSlideRoute<void>(
        child: const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: NaviColors.background,
      body: Stack(
        children: [
          // Background layer
          Positioned.fill(
            child: Image.asset(
              'assets/images/navi_background.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),

          // Foreground content
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.10),

                // Logo
                Image.asset(
                  'assets/images/navi_logo.png',
                  width: size.width * 0.52,
                  fit: BoxFit.contain,
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.12, end: 0, curve: Curves.easeOut),

                const SizedBox(height: 10),

                // Tagline row
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SparkleWidget(color: NaviColors.sparkPurple, size: 12),
                    SizedBox(width: 8),
                    Text(
                      'navigate your future',
                      style: NaviTextStyles.tagline,
                    ),
                    SizedBox(width: 8),
                    SparkleWidget(color: NaviColors.sparkTeal, size: 12),
                  ],
                ).animate(delay: 300.ms).fadeIn(duration: 500.ms),

                const Spacer(),

                // Characters
                Image.asset(
                  'assets/images/navi_characters.png',
                  width: size.width * 0.92,
                  fit: BoxFit.contain,
                )
                    .animate(delay: 500.ms)
                    .fadeIn(duration: 700.ms)
                    .slideY(begin: 0.08, end: 0, curve: Curves.easeOut),

                const SizedBox(height: 32),

                // Loading message
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    _messages[_messageIndex],
                    key: ValueKey(_messageIndex),
                    style: NaviTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: NaviColors.textDark,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Progress bar with sparkles
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Row(
                    children: [
                      const SparkleWidget(
                          color: NaviColors.sparkPink, size: 10),
                      const SizedBox(width: 8),
                      Transform.translate(
                        offset: const Offset(0, -4),
                        child: const SparkleWidget(
                            color: NaviColors.sparkBlue, size: 13),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            value: _progress,
                            minHeight: 10,
                            backgroundColor: NaviColors.primaryPale,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              NaviColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Transform.translate(
                        offset: const Offset(0, -4),
                        child: const SparkleWidget(
                            color: NaviColors.sparkYellow, size: 10),
                      ),
                      const SizedBox(width: 8),
                      const SparkleWidget(
                          color: NaviColors.sparkGreen, size: 13),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Loading...',
                  style: NaviTextStyles.label.copyWith(
                    color: NaviColors.textMuted,
                  ),
                ),

                const SizedBox(height: 36),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
