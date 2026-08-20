import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/exercises/application/exercise_completion_providers.dart';
import '../../features/games/application/game_completion_providers.dart';
import '../../features/home/application/emotion_providers.dart';
import '../utils/date_key.dart';
import 'streak_calculator.dart';

/// Distinct yyyy-MM-dd keys with at least one recorded activity, from
/// real emotion, exercise, and game data (no mock data).
final activeDateKeysProvider = Provider<Set<String>>((ref) {
  final emotionRecords = ref.watch(emotionRecordsProvider).valueOrNull ?? {};
  final completions = ref.watch(exerciseCompletionsProvider).valueOrNull ?? [];
  final games = ref.watch(gameCompletionsProvider).valueOrNull ?? [];
  return {
    ...emotionRecords.keys,
    ...completions.map((c) => dateKey(c.date)),
    ...games.map((g) => dateKey(g.date)),
  };
});

final currentStreakProvider = Provider<int>((ref) {
  return calculateStreak(ref.watch(activeDateKeysProvider));
});
