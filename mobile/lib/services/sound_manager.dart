import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  bool _soundEnabled = true;
  double _volume = 0.6;

  bool get isSoundEnabled => _soundEnabled;
  double get volume => _volume;

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  void setVolume(double vol) {
    _volume = vol.clamp(0.0, 1.0);
  }

  /// Subtle glass click for button and chip taps
  void playTap() {
    if (!_soundEnabled) return;
    _synthesizeTone(frequency: 880, durationMs: 45, type: 'sine');
  }

  /// Soft progression sound for step advance
  void playStep() {
    if (!_soundEnabled) return;
    _synthesizeTone(frequency: 659.25, durationMs: 90, type: 'sine');
  }

  /// Harmonic ascending chime for successful verification / saved actions
  void playSuccess() {
    if (!_soundEnabled) return;
    _synthesizeChord([523.25, 659.25, 783.99], durationMs: 250);
  }

  /// Cinematic ethereal chime for Vibe matches
  void playMatch() {
    if (!_soundEnabled) return;
    _synthesizeChord([440.0, 554.37, 659.25, 880.0], durationMs: 400);
  }

  /// Gentle warm alert for safety notice
  void playAlert() {
    if (!_soundEnabled) return;
    _synthesizeTone(frequency: 440, durationMs: 160, type: 'triangle');
  }

  void _synthesizeTone({
    required double frequency,
    required int durationMs,
    String type = 'sine',
  }) {
    if (kIsWeb) {
      try {
        js.context.callMethod('vibePlaySynth', [frequency, durationMs, type, _volume]);
      } catch (_) {}
    } else {
      SystemSound.play(SystemSoundType.click);
    }
  }

  void _synthesizeChord(List<double> freqs, {required int durationMs}) {
    if (kIsWeb) {
      try {
        for (int i = 0; i < freqs.length; i++) {
          Future.delayed(Duration(milliseconds: i * 50), () {
            if (_soundEnabled) {
              js.context.callMethod('vibePlaySynth', [freqs[i], durationMs, 'sine', _volume]);
            }
          });
        }
      } catch (_) {}
    } else {
      HapticFeedback.mediumImpact();
      SystemSound.play(SystemSoundType.click);
    }
  }
}
