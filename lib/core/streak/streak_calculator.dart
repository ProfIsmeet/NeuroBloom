import '../utils/date_key.dart';

/// Current streak = number of consecutive distinct-active days ending
/// today (or yesterday, so the streak isn't lost purely because the
/// child hasn't done anything yet today). [activeDateKeys] are yyyy-MM-dd
/// strings (see core/utils/date_key.dart) for any day with at least one
/// recorded activity (emotion, exercise, game). Not designed to reward
/// checking in multiple times a day — only distinct days count.
int calculateStreak(Set<String> activeDateKeys, {DateTime? today}) {
  final now = today ?? DateTime.now();
  var cursor = DateTime(now.year, now.month, now.day);

  if (!activeDateKeys.contains(dateKey(cursor))) {
    cursor = cursor.subtract(const Duration(days: 1));
    if (!activeDateKeys.contains(dateKey(cursor))) return 0;
  }

  var streak = 0;
  while (activeDateKeys.contains(dateKey(cursor))) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}
