import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app.dart';
import '../l10n/gen/app_localizations.dart';
import '../services/audio_service.dart';
import '../state/settings_state.dart';
import '../state/tutorial_state.dart';
import '../theme/app_theme.dart';

/// Ayarlar ekranı (GDD §6.1, §8.6, §18). Ses + erişilebilirlik.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(l.settingsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.home),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(title: l.sectionSound),
          _VolumeRow(
            label: l.labelMasterVolume,
            value: s.masterVolume,
            onChanged: n.setMasterVolume,
            onTest: () => AudioService.instance.playSfx(SfxId.beep),
          ),
          _VolumeRow(
            label: l.labelMusicVolume,
            value: s.musicVolume,
            onChanged: n.setMusicVolume,
          ),
          _VolumeRow(
            label: l.labelSfxVolume,
            value: s.sfxVolume,
            onChanged: n.setSfxVolume,
            onTest: () => AudioService.instance.playSfx(SfxId.coin),
          ),
          SwitchListTile(
            title: Text(l.labelMute),
            value: s.muted,
            onChanged: n.setMuted,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          _Section(title: l.sectionAccessibility),
          SwitchListTile(
            title: Text(l.labelTapMode),
            subtitle: Text(l.subtitleTapMode),
            value: s.tapModeEnabled,
            onChanged: n.setTapModeEnabled,
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: Text(l.labelHaptic),
            value: s.hapticEnabled,
            onChanged: n.setHapticEnabled,
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: Text(l.labelReduceAnimations),
            value: s.reduceAnimations,
            onChanged: n.setReduceAnimations,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          _Section(title: l.sectionProgress),
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(tutorialProvider.notifier).reset();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l.snackTutorialReset),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.replay),
            label: Text(l.buttonResetTutorial),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.inkSoft,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _VolumeRow extends StatelessWidget {
  const _VolumeRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.onTest,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final VoidCallback? onTest;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(label, style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            child: Slider(
              value: value.clamp(0, 1),
              activeColor: AppColors.primary,
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 38,
            child: Text(
              '%${(value * 100).round()}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.inkSoft,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          if (onTest != null)
            IconButton(
              icon: const Icon(Icons.play_circle_outline),
              onPressed: onTest,
              tooltip: 'Test',
            ),
        ],
      ),
    );
  }
}
