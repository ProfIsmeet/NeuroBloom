import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../badges/badge_providers.dart';
import '../constants/xp_values.dart';
import '../streak/streak_providers.dart';
import '../xp/xp_providers.dart';

/// Called after any activity that can move XP/streak/badges (exercise
/// completion, emotion recorded): awards the 7-day-streak bonus if a new
/// multiple of 7 was just reached, then re-evaluates badges. Returns any
/// newly unlocked badge ids so the caller can show an unlock animation.
Future<Set<String>> refreshGamification(Ref ref) async {
  final streak = ref.read(currentStreakProvider);
  if (streak > 0 && streak % 7 == 0) {
    await ref
        .read(xpEventsProvider.notifier)
        .award(
          activityType: 'streak_bonus',
          sourceId: 'streak_$streak',
          amount: XpValues.streakBonus,
        );
  }
  return ref.read(unlockedBadgesProvider.notifier).refresh();
}
