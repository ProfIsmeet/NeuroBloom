import 'package:flutter_test/flutter_test.dart';
import 'package:neurobloom/core/content/content_loader.dart';
import 'package:neurobloom/features/games/data/letter_wheel_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads the real bundled letter_wheel.json into unique, non-empty syllables', () async {
    final repo = LetterWheelRepository(ContentLoader());
    final items = await repo.loadAll();

    expect(items, isNotEmpty);
    expect(items.map((i) => i.id).toSet().length, items.length, reason: 'ids are unique');
    for (final item in items) {
      expect(item.syllable, isNotEmpty);
      expect(item.prompt, isNotEmpty);
    }
  });

  test('missing asset degrades to an empty list, never throws', () async {
    final loader = _MissingFileContentLoader();
    final repo = LetterWheelRepository(loader);
    expect(await repo.loadAll(), isEmpty);
  });
}

class _MissingFileContentLoader extends ContentLoader {
  @override
  Future<List<dynamic>> loadJsonList(String assetPath) async => const [];
}
