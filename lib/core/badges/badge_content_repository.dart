import '../content/content_loader.dart';
import 'badge.dart';

class BadgeContentRepository {
  BadgeContentRepository(this._loader);

  final ContentLoader _loader;

  Future<List<Badge>> loadBadges() async {
    final raw = await _loader.loadJsonList('assets/data/badges.json');
    return raw.map(Badge.tryParse).whereType<Badge>().toList();
  }
}
