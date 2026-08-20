import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/content/content_providers.dart';
import '../../onboarding/application/profile_providers.dart';
import '../data/exercise_repository.dart';
import '../domain/exercise.dart';

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepository(ref.watch(contentLoaderProvider));
});

final allExercisesProvider = FutureProvider<List<Exercise>>((ref) {
  return ref.watch(exerciseRepositoryProvider).loadAll();
});

/// Enabled + age-range filtered exercises for the current profile.
final visibleExercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final all = await ref.watch(allExercisesProvider.future);
  final profile = await ref.watch(profileControllerProvider.future);
  final age = profile?.age ?? 6;
  return visibleExercises(all, age: age);
});

List<Exercise> visibleExercises(List<Exercise> all, {required int age}) {
  return all.where((exercise) => exercise.isVisibleForAge(age)).toList();
}
