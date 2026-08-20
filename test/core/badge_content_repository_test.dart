import 'package:flutter_test/flutter_test.dart';
import 'package:neurobloom/core/badges/badge_content_repository.dart';
import 'package:neurobloom/core/content/content_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads the real bundled badges.json into exactly 10 valid badges', () async {
    final repo = BadgeContentRepository(ContentLoader());
    final badges = await repo.loadBadges();

    expect(badges.length, 10);
    expect(badges.map((b) => b.id).toSet().length, 10, reason: 'ids are unique');
  });
}
