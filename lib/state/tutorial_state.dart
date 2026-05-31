import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/tutorial_service.dart';
import 'app_providers.dart';

class TutorialNotifier extends StateNotifier<Set<TutorialStep>> {
  TutorialNotifier(this._service)
    : super({
        for (final s in TutorialStep.values)
          if (_service.seen(s)) s,
      });

  final TutorialService _service;

  bool seen(TutorialStep step) => state.contains(step);

  void markSeen(TutorialStep step) {
    if (state.contains(step)) return;
    _service.markSeen(step);
    state = {...state, step};
  }

  Future<void> reset() async {
    await _service.reset();
    state = const {};
  }
}

final tutorialProvider =
    StateNotifierProvider<TutorialNotifier, Set<TutorialStep>>(
      (ref) => TutorialNotifier(ref.watch(tutorialServiceProvider)),
    );
