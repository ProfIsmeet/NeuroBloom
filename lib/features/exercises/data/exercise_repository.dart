import '../../../core/content/content_loader.dart';
import '../domain/exercise.dart';

class ExerciseRepository {
  ExerciseRepository(this._loader);

  final ContentLoader _loader;

  static const List<String> categoryAssetPaths = [
    'assets/data/exercises/tongue.json',
    'assets/data/exercises/lips.json',
    'assets/data/exercises/speech.json',
  ];

  Future<List<Exercise>> loadAll() async {
    final exercises = <Exercise>[];
    for (final path in categoryAssetPaths) {
      final raw = await _loader.loadJsonList(path);
      exercises.addAll(raw.map(Exercise.tryParse).whereType<Exercise>());
    }
    return exercises;
  }
}
