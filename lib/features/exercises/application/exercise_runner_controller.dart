import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/gamification/gamification_refresh.dart';
import '../../../core/services/tts_providers.dart';
import '../../../core/xp/xp_providers.dart';
import '../domain/exercise.dart';
import '../domain/exercise_runner_state.dart';
import 'exercise_completion_providers.dart';

final exerciseRunnerControllerProvider = StateNotifierProvider.autoDispose
    .family<ExerciseRunnerController, ExerciseRunnerState, Exercise>((
      ref,
      exercise,
    ) {
      return ExerciseRunnerController(exercise, ref);
    });

class ExerciseRunnerController extends StateNotifier<ExerciseRunnerState> {
  ExerciseRunnerController(this.exercise, this._ref)
    : super(ExerciseRunnerState.initial(exercise.duration));

  final Exercise exercise;
  final Ref _ref;
  Timer? _timer;

  void start() {
    if (state.phase == ExerciseRunnerPhase.counting) return;
    state = ExerciseRunnerState(
      phase: ExerciseRunnerPhase.counting,
      currentRep: 1,
      secondsRemaining: exercise.duration,
    );
    _ref.read(ttsServiceProvider).speak(exercise.tts);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (state.secondsRemaining > 1) {
      state = state.copyWith(secondsRemaining: state.secondsRemaining - 1);
      return;
    }
    if (state.currentRep >= exercise.repetitions) {
      _timer?.cancel();
      _complete();
    } else {
      state = state.copyWith(
        currentRep: state.currentRep + 1,
        secondsRemaining: exercise.duration,
      );
    }
  }

  Future<void> _complete() async {
    state = state.copyWith(phase: ExerciseRunnerPhase.completed);
    await _ref
        .read(exerciseCompletionsProvider.notifier)
        .recordCompletion(exercise.id);
    // Keyed by exerciseId + day: repeating the same exercise on the same
    // day still records the completion (for history/streak) but only the
    // first run of the day awards XP, so spamming BAŞLA can't farm XP.
    await _ref
        .read(xpEventsProvider.notifier)
        .award(
          activityType: 'exercise',
          sourceId: exercise.id,
          amount: exercise.xp,
        );
    final newlyUnlocked = await refreshGamification(_ref);
    if (!mounted) return;
    state = state.copyWith(newlyUnlockedBadgeIds: newlyUnlocked);
  }

  void skip() {
    _timer?.cancel();
    state = state.copyWith(phase: ExerciseRunnerPhase.skipped);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
