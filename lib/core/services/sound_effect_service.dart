import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class SoundEffectService {
  SoundEffectService._();

  static final AudioPlayer _player = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop)
    ..setVolume(0.18);

  static bool _enabled = true;
  static bool _isPlaying = false;

  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  static Future<void> playTap() async {
    if (!_enabled || _isPlaying) return;

    _isPlaying = true;
    try {
      await HapticFeedback.selectionClick();
      await _player.stop();
      await _player.setVolume(0.18);
      await _player.play(AssetSource('audio/soft_tap.wav'));
    } catch (_) {
      // Silently ignore audio errors; haptics still provide feedback.
    } finally {
      _isPlaying = false;
    }
  }

  static Future<void> playConfirm() async {
    if (!_enabled || _isPlaying) return;

    _isPlaying = true;
    try {
      await HapticFeedback.lightImpact();
      await _player.stop();
      await _player.setVolume(0.22);
      await _player.play(AssetSource('audio/soft_tap.wav'));
    } catch (_) {
      // Silently ignore audio errors; haptics still provide feedback.
    } finally {
      _isPlaying = false;
    }
  }
}
