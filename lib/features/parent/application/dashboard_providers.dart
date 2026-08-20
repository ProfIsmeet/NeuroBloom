import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/xp/xp_providers.dart';
import '../../exercises/application/exercise_completion_providers.dart';
import '../../games/application/game_completion_providers.dart';
import '../../home/application/emotion_providers.dart';
import '../domain/dashboard_stats.dart';

final weeklyActivityProvider = Provider<Map<String, int>>((ref) {
  final emotionRecords = ref.watch(emotionRecordsProvider).valueOrNull ?? {};
  final exerciseDates =
      (ref.watch(exerciseCompletionsProvider).valueOrNull ?? [])
          .map((c) => c.date)
          .toList();
  final gameDates = (ref.watch(gameCompletionsProvider).valueOrNull ?? [])
      .map((g) => g.date)
      .toList();

  return weeklyActivityCounts(
    weekDates: weekDates(DateTime.now()),
    emotionRecords: emotionRecords,
    exerciseDates: exerciseDates,
    gameDates: gameDates,
  );
});

final emotionDistributionProvider = Provider<Map<String, int>>((ref) {
  final emotionRecords = ref.watch(emotionRecordsProvider).valueOrNull ?? {};
  return emotionDistribution(emotionRecords);
});

final dailyXpTotalsProvider = Provider<List<MapEntry<String, int>>>((ref) {
  final events = ref.watch(xpEventsProvider).valueOrNull ?? [];
  return dailyXpTotals([
    for (final e in events) (date: e.date, amount: e.amount),
  ]);
});
