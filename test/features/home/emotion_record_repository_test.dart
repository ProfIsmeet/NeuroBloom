import 'package:flutter_test/flutter_test.dart';
import 'package:neurobloom/features/home/application/emotion_providers.dart';
import 'package:neurobloom/features/home/data/emotion_record_repository.dart';

import '../../support/fake_storage_service.dart';

void main() {
  group('EmotionRecordRepository', () {
    test('loadAll returns empty map when nothing recorded', () async {
      final repo = EmotionRecordRepository(FakeStorageService());
      expect(await repo.loadAll(), isEmpty);
    });

    test('records an emotion for a given day', () async {
      final repo = EmotionRecordRepository(FakeStorageService());
      final date = DateTime(2026, 3, 5);

      final records = await repo.recordEmotion(date, 'happy');

      expect(records['2026-03-05'], 'happy');
    });

    test('recording again on the same day overwrites, not appends', () async {
      final repo = EmotionRecordRepository(FakeStorageService());
      final date = DateTime(2026, 3, 5, 9);
      final laterSameDay = DateTime(2026, 3, 5, 20);

      await repo.recordEmotion(date, 'sad');
      final records = await repo.recordEmotion(laterSameDay, 'happy');

      expect(records.length, 1);
      expect(records['2026-03-05'], 'happy');
    });

    test('different days are recorded separately', () async {
      final repo = EmotionRecordRepository(FakeStorageService());

      await repo.recordEmotion(DateTime(2026, 3, 5), 'happy');
      final records = await repo.recordEmotion(
        DateTime(2026, 3, 6),
        'neutral',
      );

      expect(records.length, 2);
      expect(records['2026-03-05'], 'happy');
      expect(records['2026-03-06'], 'neutral');
    });

    test('corrupted stored JSON degrades to empty map, never throws', () async {
      final storage = FakeStorageService()
        ..seedRaw('emotion_records', '{not valid json');
      final repo = EmotionRecordRepository(storage);

      expect(await repo.loadAll(), isEmpty);
    });
  });

  group('weekDates', () {
    test('returns Monday-start 7 consecutive days', () {
      // 2026-03-05 is a Thursday.
      final dates = weekDates(DateTime(2026, 3, 5));

      expect(dates.length, 7);
      expect(dates.first.weekday, DateTime.monday);
      expect(dates.last.weekday, DateTime.sunday);
      expect(dates.first, DateTime(2026, 3, 2));
      expect(dates.last, DateTime(2026, 3, 8));
    });

    test('a week with no records maps to all-empty lookups', () {
      final dates = weekDates(DateTime(2026, 3, 5));
      final records = <String, String>{};

      final hits = dates
          .where((d) => records.containsKey(EmotionRecordRepository.dateKey(d)))
          .length;

      expect(hits, 0);
    });
  });
}
