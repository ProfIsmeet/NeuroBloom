import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/exercises/application/exercise_completion_providers.dart';
import '../../features/home/application/emotion_providers.dart';
import '../utils/date_key.dart';
import 'streak_calculator.dart';

/// Distinct yyyy-MM-dd keys with at least one recorded activity, from
/// real emotion and exercise data (no mock data).
final activeDateKeysProvider = Provider<Set<String>>((ref) {
  final emotionRecords = ref.watch(emotionRecordsProvider).valueOrNull ?? {};
  final completions = ref.watch(exerciseCompletionsProvider).valueOrNull ?? [];
  return {
    ...emotionRecords.keys,
    ...completions.map((c) => dateKey(c.date)),
  };
});

final currentStreakProvider = Provider<int>((ref) {
  return calculateStreak(ref.watch(activeDateKeysProvider));
});
