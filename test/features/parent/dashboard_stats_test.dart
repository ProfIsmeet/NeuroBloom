import 'package:flutter_test/flutter_test.dart';
import 'package:neurobloom/features/parent/domain/dashboard_stats.dart';

void main() {
  group('weeklyActivityCounts', () {
    test('counts emotion + exercise + game activity per day', () {
      final monday = DateTime(2026, 3, 2); // a Monday
      final tuesday = DateTime(2026, 3, 3);
      final weekDates = List.generate(7, (i) => monday.add(Duration(days: i)));

      final counts = weeklyActivityCounts(
        weekDates: weekDates,
        emotionRecords: {'2026-03-02': 'happy'},
        exerciseDates: [monday, monday, tuesday],
        gameDates: [tuesday],
      );

      expect(counts['2026-03-02'], 3); // 1 emotion + 2 exercises
      expect(counts['2026-03-03'], 2); // 1 exercise + 1 game
      expect(counts['2026-03-04'], 0);
    });

    test('every date in the week appears, even with zero activity', () {
      final monday = DateTime(2026, 3, 2);
      final weekDates = List.generate(7, (i) => monday.add(Duration(days: i)));

      final counts = weeklyActivityCounts(
        weekDates: weekDates,
        emotionRecords: {},
        exerciseDates: [],
        gameDates: [],
      );

      expect(counts.length, 7);
      expect(counts.values.every((v) => v == 0), isTrue);
    });
  });

  group('emotionDistribution', () {
    test('tallies each emotion id across all recorded days', () {
      final dist = emotionDistribution({
        '2026-03-01': 'happy',
        '2026-03-02': 'happy',
        '2026-03-03': 'sad',
      });

      expect(dist['happy'], 2);
      expect(dist['sad'], 1);
    });

    test('empty history yields an empty distribution', () {
      expect(emotionDistribution({}), isEmpty);
    });
  });

  group('dailyXpTotals', () {
    test('sums multiple same-day events and sorts chronologically', () {
      final totals = dailyXpTotals([
        (date: '2026-03-02', amount: 20),
        (date: '2026-03-01', amount: 10),
        (date: '2026-03-01', amount: 5),
      ]);

      expect(totals.map((e) => e.key).toList(), ['2026-03-01', '2026-03-02']);
      expect(totals[0].value, 15);
      expect(totals[1].value, 20);
    });

    test('empty event list yields an empty result', () {
      expect(dailyXpTotals(const []), isEmpty);
    });
  });
}
