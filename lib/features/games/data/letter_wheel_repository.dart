import '../../../core/content/content_loader.dart';
import '../domain/letter_wheel_item.dart';

class LetterWheelRepository {
  LetterWheelRepository(this._loader);

  final ContentLoader _loader;

  Future<List<LetterWheelItem>> loadAll() async {
    final raw = await _loader.loadJsonList('assets/data/games/letter_wheel.json');
    return raw.map(LetterWheelItem.tryParse).whereType<LetterWheelItem>().toList();
  }
}
