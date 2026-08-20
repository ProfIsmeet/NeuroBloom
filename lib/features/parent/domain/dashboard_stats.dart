import '../../../core/utils/date_key.dart';

/// Per-day activity count (emotion recorded + exercises + games) for each
/// of the 7 given dates, in the same order — a full week's bar chart.
Map<String, int> weeklyActivityCounts({
  required List<DateTime> weekDates,
  required Map<String, String> emotionRecords,
  required List<DateTime> exerciseDates,
  required List<DateTime> gameDates,
}) {
  final counts = <String, int>{};
  for (final date in weekDates) {
    final key = dateKey(date);
    var count = emotionRecords.containsKey(key) ? 1 : 0;
    count += exerciseDates.where((d) => dateKey(d) == key).length;
    count += gameDates.where((d) => dateKey(d) == key).length;
    counts[key] = count;
  }
  return counts;
}

/// How many times each emotion id was recorded, across all history.
Map<String, int> emotionDistribution(Map<String, String> emotionRecords) {
  final distribution = <String, int>{};
  for (final emotionId in emotionRecords.values) {
    distribution[emotionId] = (distribution[emotionId] ?? 0) + 1;
  }
  return distribution;
}

/// XP earned per day (yyyy-MM-dd), summed and sorted chronologically.
List<MapEntry<String, int>> dailyXpTotals(
  List<({String date, int amount})> events,
) {
  final totals = <String, int>{};
  for (final event in events) {
    totals[event.date] = (totals[event.date] ?? 0) + event.amount;
  }
  final sortedKeys = totals.keys.toList()..sort();
  return [for (final key in sortedKeys) MapEntry(key, totals[key]!)];
}
