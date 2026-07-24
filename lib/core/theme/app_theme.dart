import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class NaviTheme {
  NaviTheme._();

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        fontFamily: 'Nunito',
        scaffoldBackgroundColor: NaviColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: NaviColors.primary,
          surface: NaviColors.surface,
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        textTheme: const TextTheme(
          displayLarge: NaviTextStyles.displayLarge,
          headlineLarge: NaviTextStyles.heading1,
          headlineMedium: NaviTextStyles.heading2,
          bodyLarge: NaviTextStyles.bodyLarge,
          bodyMedium: NaviTextStyles.bodyMedium,
          labelLarge: NaviTextStyles.button,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: NaviColors.primary,
          linearTrackColor: NaviColors.primaryPale,
        ),
      );
}
