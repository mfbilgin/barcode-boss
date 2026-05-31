import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/tutorial_service.dart';
import '../state/tutorial_state.dart';
import '../theme/app_theme.dart';

/// Drip-feed tutorial banner (GDD §4). Verilen [step] henüz görülmediyse
/// göster; "Anladım" tap'lenince seen olarak işaretle ve gizle.
class TutorialBanner extends ConsumerWidget {
  const TutorialBanner({
    required this.step,
    required this.title,
    required this.body,
    super.key,
  });

  final TutorialStep step;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seen = ref.watch(tutorialProvider).contains(step);
    if (seen) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Material(
        color: AppColors.primary.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () =>
                    ref.read(tutorialProvider.notifier).markSeen(step),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
                child: const Text('Anladım'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
