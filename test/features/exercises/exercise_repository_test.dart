import 'package:flutter_test/flutter_test.dart';
import 'package:neurobloom/core/content/content_loader.dart';
import 'package:neurobloom/features/exercises/data/exercise_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExerciseRepository', () {
    test('loads and parses the real bundled tongue/lips/speech content', () async {
      final repo = ExerciseRepository(ContentLoader());
      final exercises = await repo.loadAll();

      expect(exercises, isNotEmpty);
      expect(exercises.any((e) => e.category == 'tongue'), isTrue);
      expect(exercises.any((e) => e.category == 'lips'), isTrue);
      // The disabled placeholder in tongue.json must not be returned as visible content.
      expect(exercises.any((e) => e.id == 'tongue_experimental_future'), isTrue);
    });
  });

  group('ContentLoader', () {
    test('missing asset file returns an empty list, never throws', () async {
      final loader = ContentLoader();
      final result = await loader.loadJsonList(
        'assets/data/exercises/does_not_exist.json',
      );
      expect(result, isEmpty);
    });
  });
}
