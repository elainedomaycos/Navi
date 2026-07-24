import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/sound_effect_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../providers/app_providers.dart';

class AppSettingsSheet extends ConsumerWidget {
  const AppSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(appPreferencesProvider);
    final notifier = ref.read(appPreferencesProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 5,
                width: 54,
                decoration: BoxDecoration(
                  color: NaviColors.primaryPale,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'App Settings',
              style: NaviTextStyles.heading2.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Fine-tune the motion and feedback style for the app.',
              style: NaviTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFEAE4F8)),
              ),
              child: Column(
                children: [
                   SwitchListTile.adaptive(
                     tileColor: Colors.transparent,
                     value: preferences.soundsEnabled,
                     onChanged: (value) async {
                       await notifier.setSoundsEnabled(value);
                       SoundEffectService.setEnabled(value);
                     },
                     activeThumbColor: NaviColors.primary,
                     activeTrackColor: NaviColors.primaryPale,
                     title: Text(
                       'Sounds',
                       style: NaviTextStyles.bodyLarge.copyWith(
                         fontWeight: FontWeight.w800,
                       ),
                     ),
                     subtitle: const Text(
                       'Soft taps and confirmation feedback.',
                       style: NaviTextStyles.label,
                     ),
                   ),
                   const Divider(height: 1),
                   SwitchListTile.adaptive(
                     tileColor: Colors.transparent,
                     value: preferences.animationsEnabled,
                     onChanged: (value) {
                       notifier.setAnimationsEnabled(value);
                     },
                     activeThumbColor: NaviColors.primary,
                     activeTrackColor: NaviColors.primaryPale,
                     title: Text(
                       'Animations',
                       style: NaviTextStyles.bodyLarge.copyWith(
                         fontWeight: FontWeight.w800,
                       ),
                     ),
                     subtitle: const Text(
                       'Page transitions and screen motion.',
                       style: NaviTextStyles.label,
                     ),
                   ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Turning off animations keeps the app responsive while reducing motion across screens.',
              style: NaviTextStyles.label.copyWith(
                color: NaviColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
