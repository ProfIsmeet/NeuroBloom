import 'package:flutter_test/flutter_test.dart';
import 'package:neurobloom/core/xp/xp_ledger_repository.dart';

import '../support/fake_storage_service.dart';

void main() {
  group('XpLedgerRepository', () {
    test('starts empty, total is zero', () async {
      final repo = XpLedgerRepository(FakeStorageService());
      final events = await repo.loadAll();
      expect(events, isEmpty);
      expect(repo.totalOf(events), 0);
    });

    test('records distinct events and sums their amounts', () async {
      final repo = XpLedgerRepository(FakeStorageService());
      await repo.record(
        activityType: 'exercise',
        sourceId: 'ex1',
        date: '2026-03-01',
        amount: 20,
      );
      final events = await repo.record(
        activityType: 'emotion',
        sourceId: 'daily',
        date: '2026-03-01',
        amount: 5,
      );
      expect(events.length, 2);
      expect(repo.totalOf(events), 25);
    });

    test('duplicate (activityType, sourceId, date) is a no-op', () async {
      final repo = XpLedgerRepository(FakeStorageService());
      await repo.record(
        activityType: 'exercise',
        sourceId: 'ex1',
        date: '2026-03-01',
        amount: 20,
      );
      final events = await repo.record(
        activityType: 'exercise',
        sourceId: 'ex1',
        date: '2026-03-01',
        amount: 20,
      );
      expect(events.length, 1);
      expect(repo.totalOf(events), 20);
    });

    test('same sourceId on a different date awards again', () async {
      final repo = XpLedgerRepository(FakeStorageService());
      await repo.record(
        activityType: 'exercise',
        sourceId: 'ex1',
        date: '2026-03-01',
        amount: 20,
      );
      final events = await repo.record(
        activityType: 'exercise',
        sourceId: 'ex1',
        date: '2026-03-02',
        amount: 20,
      );
      expect(events.length, 2);
      expect(repo.totalOf(events), 40);
    });

    test('corrupted stored JSON degrades to empty list, never throws', () async {
      final storage = FakeStorageService()..seedRaw('xp_events', '{not valid json');
      final repo = XpLedgerRepository(storage);
      expect(await repo.loadAll(), isEmpty);
    });
  });
}
