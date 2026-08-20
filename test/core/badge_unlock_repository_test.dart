import 'package:flutter_test/flutter_test.dart';
import 'package:neurobloom/core/badges/badge_unlock_repository.dart';

import '../support/fake_storage_service.dart';

void main() {
  group('BadgeUnlockRepository', () {
    test('starts with no unlocked badges', () async {
      final repo = BadgeUnlockRepository(FakeStorageService());
      expect(await repo.loadUnlocked(), isEmpty);
    });

    test('saved unlocks survive a reload (persistence)', () async {
      final storage = FakeStorageService();
      final repo = BadgeUnlockRepository(storage);
      await repo.saveUnlocked({'first_step', 'xp_500'});

      final reloaded = BadgeUnlockRepository(storage);
      expect(await reloaded.loadUnlocked(), {'first_step', 'xp_500'});
    });

    test('corrupted stored JSON degrades to empty set, never throws', () async {
      final storage = FakeStorageService()
        ..seedRaw('unlocked_badges', '{not valid json');
      final repo = BadgeUnlockRepository(storage);
      expect(await repo.loadUnlocked(), isEmpty);
    });
  });
}
