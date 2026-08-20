import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/tts_providers.dart';
import '../../../core/theme/app_dimens.dart';
import '../application/exercise_providers.dart';
import '../application/exercise_runner_controller.dart';
import '../domain/exercise.dart';
import '../domain/exercise_runner_state.dart';
import 'widgets/exercise_animation_fallback.dart';

class ExerciseRunnerScreen extends ConsumerWidget {
  const ExerciseRunnerScreen({super.key, required this.exerciseId});

  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(allExercisesProvider);
    final visibleAsync = ref.watch(visibleExercisesProvider);

    return allAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) =>
          const Scaffold(body: Center(child: Text('Egzersizler yüklenemedi.'))),
      data: (all) {
        Exercise? exercise;
        for (final e in all) {
          if (e.id == exerciseId) {
            exercise = e;
            break;
          }
        }
        if (exercise == null) {
          return const Scaffold(body: Center(child: Text('Egzersiz bulunamadı.')));
        }

        final categoryExercises = (visibleAsync.valueOrNull ?? [])
            .where((e) => e.category == exercise!.category)
            .toList();
        final indexInCategory = categoryExercises.indexWhere(
          (e) => e.id == exercise!.id,
        );
        final position = indexInCategory >= 0 ? indexInCategory + 1 : 1;
        final total = categoryExercises.isEmpty ? 1 : categoryExercises.length;

        return _ExerciseRunnerBody(
          exercise: exercise,
          position: position,
          total: total,
        );
      },
    );
  }
}

class _ExerciseRunnerBody extends ConsumerWidget {
  const _ExerciseRunnerBody({
    required this.exercise,
    required this.position,
    required this.total,
  });

  final Exercise exercise;
  final int position;
  final int total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exerciseRunnerControllerProvider(exercise));
    final controller = ref.read(
      exerciseRunnerControllerProvider(exercise).notifier,
    );
    final ttsEnabled = ref.watch(ttsEnabledProvider).valueOrNull ?? true;

    return Scaffold(
      appBar: AppBar(
        title: Text('Egzersiz $position / $total'),
        actions: [
          IconButton(
            tooltip: ttsEnabled ? 'Sesi kapat' : 'Sesi aç',
            icon: Icon(ttsEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded),
            onPressed: () => ref
                .read(ttsEnabledProvider.notifier)
                .setEnabled(!ttsEnabled),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.spaceLg),
          child: Column(
            children: [
              LinearProgressIndicator(value: position / total),
              const SizedBox(height: AppDimens.spaceLg),
              Text(exercise.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppDimens.spaceLg),
              Expanded(
                child: switch (state.phase) {
                  ExerciseRunnerPhase.completed => _CompletedView(exercise: exercise),
                  ExerciseRunnerPhase.skipped => const _SkippedView(),
                  _ => _ActiveView(exercise: exercise, state: state),
                },
              ),
              if (state.phase == ExerciseRunnerPhase.idle)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.start,
                    child: const Text('BAŞLA'),
                  ),
                ),
              if (state.phase == ExerciseRunnerPhase.counting)
                TextButton(
                  onPressed: controller.skip,
                  child: const Text('Atla'),
                ),
              if (state.phase == ExerciseRunnerPhase.completed ||
                  state.phase == ExerciseRunnerPhase.skipped)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Listeye Dön'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveView extends StatelessWidget {
  const _ActiveView({required this.exercise, required this.state});

  final Exercise exercise;
  final ExerciseRunnerState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ExerciseAnimationFallback(category: exercise.category),
        const SizedBox(height: AppDimens.spaceLg),
        Text(exercise.instruction, textAlign: TextAlign.center),
        const SizedBox(height: AppDimens.spaceLg),
        Text(
          '${state.currentRep} / ${exercise.repetitions}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppDimens.spaceMd),
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: state.secondsRemaining / exercise.duration,
                strokeWidth: 8,
              ),
              Text(
                '${state.secondsRemaining}',
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompletedView extends StatelessWidget {
  const _CompletedView({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.celebration_rounded,
            size: 72,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: AppDimens.spaceMd),
          Text('Harika!', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppDimens.spaceSm),
          Text('+${exercise.xp} XP'),
        ],
      ),
    );
  }
}

class _SkippedView extends StatelessWidget {
  const _SkippedView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Egzersiz atlandı.'));
  }
}
