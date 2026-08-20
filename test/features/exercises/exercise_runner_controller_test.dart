import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neurobloom/core/services/noop_tts_service.dart';
import 'package:neurobloom/core/services/tts_providers.dart';
import 'package:neurobloom/features/exercises/application/exercise_completion_providers.dart';
import 'package:neurobloom/features/exercises/application/exercise_runner_controller.dart';
import 'package:neurobloom/features/exercises/domain/exercise.dart';
import 'package:neurobloom/features/exercises/domain/exercise_runner_state.dart';
import 'package:neurobloom/features/onboarding/application/profile_providers.dart';
import 'package:neurobloom/core/xp/xp_providers.dart';

import '../../support/fake_storage_service.dart';

Exercise _exercise({
  String id = 'test_ex',
  int duration = 1,
  int repetitions = 2,
  int xp = 20,
}) {
  return Exercise(
    id: id,
    category: 'tongue',
    title: 'title',
    description: 'desc',
    instruction: 'instr',
    duration: duration,
    repetitions: repetitions,
    tts: 'tts text',
    animation: 'tongue_out',
    xp: xp,
    difficulty: 'easy',
    ageMin: 3,
    ageMax: 13,
    enabled: true,
  );
}

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        storageServiceProvider.overrideWithValue(FakeStorageService()),
        // Force the silent TTS implementation so tests never touch a real
        // platform channel, and to exercise the "TTS disabled" path.
        flutterTtsServiceProvider.overrideWithValue(const NoopTtsService()),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('runs through all repetitions, completes, awards XP, records completion', () async {
    final exercise = _exercise(duration: 1, repetitions: 2, xp: 25);
    // autoDispose providers tear down (canceling the Timer) once nothing
    // is listening; a bare read() doesn't count, so hold a subscription.
    container.listen(exerciseRunnerControllerProvider(exercise), (_, _) {});
    final controller = container.read(
      exerciseRunnerControllerProvider(exercise).notifier,
    );

    expect(
      container.read(exerciseRunnerControllerProvider(exercise)).phase,
      ExerciseRunnerPhase.idle,
    );

    controller.start();
    expect(
      container.read(exerciseRunnerControllerProvider(exercise)).phase,
      ExerciseRunnerPhase.counting,
    );

    // 2 reps * 1s each, plus buffer for async completion side-effects.
    await Future.delayed(const Duration(milliseconds: 2500));

    final finalState = container.read(exerciseRunnerControllerProvider(exercise));
    expect(finalState.phase, ExerciseRunnerPhase.completed);
    expect(finalState.currentRep, 2);

    final xp = container.read(totalXpProvider);
    expect(xp, 25);

    final completions = await container.read(exerciseCompletionsProvider.future);
    expect(completions.any((c) => c.exerciseId == exercise.id), isTrue);
  });

  test('skip cancels the timer and does not award XP', () async {
    final exercise = _exercise(id: 'skip_ex', duration: 5, repetitions: 3, xp: 20);
    container.listen(exerciseRunnerControllerProvider(exercise), (_, _) {});
    final controller = container.read(
      exerciseRunnerControllerProvider(exercise).notifier,
    );

    controller.start();
    controller.skip();

    expect(
      container.read(exerciseRunnerControllerProvider(exercise)).phase,
      ExerciseRunnerPhase.skipped,
    );

    // Give any stray timer a chance to fire; it must not, since skip cancels it.
    await Future.delayed(const Duration(seconds: 2));

    final xp = container.read(totalXpProvider);
    expect(xp, 0);
    final completions = await container.read(exerciseCompletionsProvider.future);
    expect(completions.any((c) => c.exerciseId == exercise.id), isFalse);
  });

  test(
    'completing the same exercise twice the same day awards XP once, '
    'but still records both completions',
    () async {
      final exercise = _exercise(id: 'repeat_ex', duration: 1, repetitions: 1, xp: 15);

      container.listen(exerciseRunnerControllerProvider(exercise), (_, _) {});
      final firstController = container.read(
        exerciseRunnerControllerProvider(exercise).notifier,
      );
      firstController.start();
      await Future.delayed(const Duration(milliseconds: 1500));
      expect(container.read(totalXpProvider), 15);

      // A fresh runner instance for the same exercise (as if the child
      // re-opened it from the list), same day.
      final secondController = container.read(
        exerciseRunnerControllerProvider(exercise).notifier,
      );
      secondController.start();
      await Future.delayed(const Duration(milliseconds: 1500));

      expect(container.read(totalXpProvider), 15, reason: 'no duplicate XP');
      final completions = await container.read(exerciseCompletionsProvider.future);
      expect(
        completions.where((c) => c.exerciseId == exercise.id).length,
        2,
        reason: 'both completions still recorded for history/streak',
      );
    },
  );

  test('completes normally even when TTS is disabled (Noop implementation)', () async {
    final exercise = _exercise(id: 'tts_off_ex', duration: 1, repetitions: 1, xp: 10);
    container.listen(exerciseRunnerControllerProvider(exercise), (_, _) {});
    final controller = container.read(
      exerciseRunnerControllerProvider(exercise).notifier,
    );

    controller.start();
    await Future.delayed(const Duration(milliseconds: 1500));

    expect(
      container.read(exerciseRunnerControllerProvider(exercise)).phase,
      ExerciseRunnerPhase.completed,
    );
  });
}
