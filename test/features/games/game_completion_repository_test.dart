import 'package:flutter_test/flutter_test.dart';
import 'package:neurobloom/features/games/data/game_completion_repository.dart';

import '../../support/fake_storage_service.dart';

void main() {
  group('GameCompletionRepository', () {
    test('starts empty', () async {
      final repo = GameCompletionRepository(FakeStorageService());
      expect(await repo.loadAll(), isEmpty);
    });

    test('records completions and keeps history (does not overwrite)', () async {
      final repo = GameCompletionRepository(FakeStorageService());
      await repo.recordCompletion('letter_wheel', DateTime(2026, 3, 5));
      final all = await repo.recordCompletion('letter_wheel', DateTime(2026, 3, 6));

      expect(all.length, 2);
      expect(all.every((c) => c.gameId == 'letter_wheel'), isTrue);
    });

    test('corrupted stored JSON degrades to empty list, never throws', () async {
      final storage = FakeStorageService()
        ..seedRaw('game_completions', '{not valid json');
      final repo = GameCompletionRepository(storage);
      expect(await repo.loadAll(), isEmpty);
    });
  });
}
