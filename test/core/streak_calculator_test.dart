import 'package:flutter_test/flutter_test.dart';
import 'package:neurobloom/core/streak/streak_calculator.dart';
import 'package:neurobloom/core/utils/date_key.dart';

void main() {
  group('calculateStreak', () {
    test('zero when no active days', () {
      expect(calculateStreak({}), 0);
    });

    test('counts consecutive days ending today', () {
      final today = DateTime(2026, 3, 10);
      final keys = {
        dateKey(today),
        dateKey(today.subtract(const Duration(days: 1))),
        dateKey(today.subtract(const Duration(days: 2))),
      };
      expect(calculateStreak(keys, today: today), 3);
    });

    test('still counts the streak if today has no activity yet, using yesterday', () {
      final today = DateTime(2026, 3, 10);
      final keys = {
        dateKey(today.subtract(const Duration(days: 1))),
        dateKey(today.subtract(const Duration(days: 2))),
      };
      expect(calculateStreak(keys, today: today), 2);
    });

    test('breaks on a gap', () {
      final today = DateTime(2026, 3, 10);
      final keys = {
        dateKey(today),
        dateKey(today.subtract(const Duration(days: 2))), // gap at day-1
      };
      expect(calculateStreak(keys, today: today), 1);
    });

    test('zero when the most recent activity is more than a day old', () {
      final today = DateTime(2026, 3, 10);
      final keys = {dateKey(today.subtract(const Duration(days: 3)))};
      expect(calculateStreak(keys, today: today), 0);
    });
  });
}
