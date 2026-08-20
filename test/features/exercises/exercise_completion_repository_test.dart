import 'package:flutter_test/flutter_test.dart';
import 'package:neurobloom/features/exercises/data/exercise_completion_repository.dart';

import '../../support/fake_storage_service.dart';

void main() {
  group('ExerciseCompletionRepository', () {
    test('starts empty', () async {
      final repo = ExerciseCompletionRepository(FakeStorageService());
      expect(await repo.loadAll(), isEmpty);
    });

    test('records completions and keeps history (does not overwrite)', () async {
      final repo = ExerciseCompletionRepository(FakeStorageService());
      await repo.recordCompletion('ex1', DateTime(2026, 3, 5));
      final all = await repo.recordCompletion('ex2', DateTime(2026, 3, 5));

      expect(all.length, 2);
      expect(all.map((c) => c.exerciseId), containsAll(['ex1', 'ex2']));
    });

    test('corrupted stored JSON degrades to empty list, never throws', () async {
      final storage = FakeStorageService()
        ..seedRaw('exercise_completions', '{not valid json');
      final repo = ExerciseCompletionRepository(storage);
      expect(await repo.loadAll(), isEmpty);
    });
  });
}
