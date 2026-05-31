import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/audio_service.dart';
import '../services/settings_service.dart';
import 'app_providers.dart';

class SettingsState {
  const SettingsState({
    required this.masterVolume,
    required this.musicVolume,
    required this.sfxVolume,
    required this.muted,
    required this.tapModeEnabled,
    required this.hapticEnabled,
    required this.reduceAnimations,
  });

  final double masterVolume;
  final double musicVolume;
  final double sfxVolume;
  final bool muted;
  final bool tapModeEnabled;
  final bool hapticEnabled;
  final bool reduceAnimations;

  SettingsState copyWith({
    double? masterVolume,
    double? musicVolume,
    double? sfxVolume,
    bool? muted,
    bool? tapModeEnabled,
    bool? hapticEnabled,
    bool? reduceAnimations,
  }) {
    return SettingsState(
      masterVolume: masterVolume ?? this.masterVolume,
      musicVolume: musicVolume ?? this.musicVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      muted: muted ?? this.muted,
      tapModeEnabled: tapModeEnabled ?? this.tapModeEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      reduceAnimations: reduceAnimations ?? this.reduceAnimations,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier(this._service, this._audio)
    : super(
        SettingsState(
          masterVolume: _service.masterVolume,
          musicVolume: _service.musicVolume,
          sfxVolume: _service.sfxVolume,
          muted: _service.muted,
          tapModeEnabled: _service.tapModeEnabled,
          hapticEnabled: _service.hapticEnabled,
          reduceAnimations: _service.reduceAnimations,
        ),
      ) {
    _syncAudio();
  }

  final SettingsService _service;
  final AudioService _audio;

  void _syncAudio() {
    _audio
      ..setVolumes(
        master: state.masterVolume,
        music: state.musicVolume,
        sfx: state.sfxVolume,
      )
      ..muted = state.muted;
  }

  void setMasterVolume(double v) {
    _service.masterVolume = v;
    state = state.copyWith(masterVolume: _service.masterVolume);
    _syncAudio();
  }

  void setMusicVolume(double v) {
    _service.musicVolume = v;
    state = state.copyWith(musicVolume: _service.musicVolume);
    _syncAudio();
  }

  void setSfxVolume(double v) {
    _service.sfxVolume = v;
    state = state.copyWith(sfxVolume: _service.sfxVolume);
    _syncAudio();
  }

  void setMuted(bool v) {
    _service.muted = v;
    state = state.copyWith(muted: v);
    _syncAudio();
  }

  void setTapModeEnabled(bool v) {
    _service.tapModeEnabled = v;
    state = state.copyWith(tapModeEnabled: v);
  }

  void setHapticEnabled(bool v) {
    _service.hapticEnabled = v;
    state = state.copyWith(hapticEnabled: v);
  }

  void setReduceAnimations(bool v) {
    _service.reduceAnimations = v;
    state = state.copyWith(reduceAnimations: v);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>(
      (ref) => SettingsNotifier(
        ref.watch(settingsServiceProvider),
        AudioService.instance,
      ),
    );
