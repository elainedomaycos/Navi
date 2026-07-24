import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/services/career_data_service.dart';
import 'core/services/sound_effect_service.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'providers/app_providers.dart';

Future<void> main() async {
  await dotenv.load();
  await CareerDataService.load();
  final sharedPreferences = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const NaviApp(),
    ),
  );
}

class NaviApp extends ConsumerWidget {
  const NaviApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(appPreferencesProvider);
    SoundEffectService.setEnabled(preferences.soundsEnabled);
    ref.listen(appPreferencesProvider, (_, next) {
      SoundEffectService.setEnabled(next.soundsEnabled);
    });

    return MaterialApp(
      title: 'Navi',
      debugShowCheckedModeBanner: false,
      theme: NaviTheme.theme,
      builder: (context, child) {
        return TickerMode(
          enabled: preferences.animationsEnabled,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const SplashScreen(),
    );
  }
}
