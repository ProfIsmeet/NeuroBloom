import '../../../core/content/content_loader.dart';
import '../domain/emotion_definition.dart';

class EmotionContentRepository {
  EmotionContentRepository(this._loader);

  final ContentLoader _loader;

  static const String assetPath = 'assets/data/emotions.json';

  Future<List<EmotionDefinition>> loadEmotions() async {
    final raw = await _loader.loadJsonList(assetPath);
    return raw
        .map(EmotionDefinition.tryParse)
        .whereType<EmotionDefinition>()
        .toList();
  }
}
