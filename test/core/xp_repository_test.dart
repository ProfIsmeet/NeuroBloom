import 'package:flutter_test/flutter_test.dart';
import 'package:neurobloom/core/xp/xp_repository.dart';

import '../support/fake_storage_service.dart';

void main() {
  group('XpRepository', () {
    test('starts at zero when nothing stored', () async {
      final repo = XpRepository(FakeStorageService());
      expect(await repo.getTotal(), 0);
    });

    test('accumulates XP across multiple awards', () async {
      final repo = XpRepository(FakeStorageService());
      await repo.addXp(20);
      final total = await repo.addXp(30);
      expect(total, 50);
      expect(await repo.getTotal(), 50);
    });

    test('corrupted stored value degrades to zero, never throws', () async {
      final storage = FakeStorageService()..seedRaw('total_xp', 'not a number');
      final repo = XpRepository(storage);
      expect(await repo.getTotal(), 0);
    });
  });
}
