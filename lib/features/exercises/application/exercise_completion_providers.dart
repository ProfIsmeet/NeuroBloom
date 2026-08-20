import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../onboarding/application/profile_providers.dart';
import '../data/exercise_completion_repository.dart';
import '../domain/exercise_completion.dart';

final exerciseCompletionRepositoryProvider =
    Provider<ExerciseCompletionRepository>((ref) {
      return ExerciseCompletionRepository(ref.watch(storageServiceProvider));
    });

final exerciseCompletionsProvider =
    AsyncNotifierProvider<ExerciseCompletionsController, List<ExerciseCompletion>>(
      ExerciseCompletionsController.new,
    );

class ExerciseCompletionsController
    extends AsyncNotifier<List<ExerciseCompletion>> {
  @override
  Future<List<ExerciseCompletion>> build() {
    return ref.watch(exerciseCompletionRepositoryProvider).loadAll();
  }

  Future<void> recordCompletion(String exerciseId) async {
    final updated = await ref
        .read(exerciseCompletionRepositoryProvider)
        .recordCompletion(exerciseId, DateTime.now());
    state = AsyncData(updated);
  }
}
