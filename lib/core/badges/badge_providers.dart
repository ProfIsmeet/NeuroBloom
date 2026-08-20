import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/exercises/application/exercise_completion_providers.dart';
import '../../features/exercises/application/exercise_providers.dart';
import '../../features/games/application/game_completion_providers.dart';
import '../../features/onboarding/application/profile_providers.dart';
import '../content/content_providers.dart';
import '../streak/streak_providers.dart';
import '../xp/xp_providers.dart';
import 'badge.dart';
import 'badge_content_repository.dart';
import 'badge_evaluator.dart';
import 'badge_stats.dart';
import 'badge_unlock_repository.dart';

final badgeContentRepositoryProvider = Provider<BadgeContentRepository>((ref) {
  return BadgeContentRepository(ref.watch(contentLoaderProvider));
});

final allBadgesProvider = FutureProvider<List<Badge>>((ref) {
  return ref.watch(badgeContentRepositoryProvider).loadBadges();
});

final badgeUnlockRepositoryProvider = Provider<BadgeUnlockRepository>((ref) {
  return BadgeUnlockRepository(ref.watch(storageServiceProvider));
});

/// Real, locally-derived stats — no mock data. exerciseCountByCategory is
/// built by joining recorded completions against the exercise catalog so
/// completions of exercises later removed from content still count.
final badgeStatsProvider = Provider<BadgeStats>((ref) {
  final completions = ref.watch(exerciseCompletionsProvider).valueOrNull ?? [];
  final catalog = ref.watch(allExercisesProvider).valueOrNull ?? [];
  final categoryById = {for (final e in catalog) e.id: e.category};

  final byCategory = <String, int>{};
  for (final completion in completions) {
    final category = categoryById[completion.exerciseId];
    if (category == null) continue;
    byCategory[category] = (byCategory[category] ?? 0) + 1;
  }

  return BadgeStats(
    totalXp: ref.watch(totalXpProvider),
    currentStreak: ref.watch(currentStreakProvider),
    totalExerciseCount: completions.length,
    exerciseCountByCategory: byCategory,
    gameCount: (ref.watch(gameCompletionsProvider).valueOrNull ?? []).length,
    activeDaysCount: ref.watch(activeDateKeysProvider).length,
  );
});

final unlockedBadgesProvider =
    AsyncNotifierProvider<UnlockedBadgesController, Set<String>>(
      UnlockedBadgesController.new,
    );

class UnlockedBadgesController extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() {
    return ref.watch(badgeUnlockRepositoryProvider).loadUnlocked();
  }

  /// Re-evaluates unlock rules against current stats, persists any newly
  /// unlocked badges, and returns just the ids unlocked by this call (so
  /// the UI can show an unlock animation only for what's new).
  Future<Set<String>> refresh() async {
    final badges = await ref.read(allBadgesProvider.future);
    final stats = ref.read(badgeStatsProvider);
    final before = state.valueOrNull ?? await future;

    final after = evaluateUnlockedBadges(
      badges: badges,
      stats: stats,
      alreadyUnlocked: before,
    );

    final newlyUnlocked = after.difference(before);
    if (newlyUnlocked.isNotEmpty) {
      await ref.read(badgeUnlockRepositoryProvider).saveUnlocked(after);
      state = AsyncData(after);
    }
    return newlyUnlocked;
  }
}

/// Re-evaluates badge unlocks once when first watched, so badges already
/// earned before this app session (e.g. from data present at launch) show
/// as unlocked without requiring a fresh activity first.
final badgeRefreshOnLoadProvider = FutureProvider<void>((ref) async {
  await ref.read(allExercisesProvider.future);
  await ref.read(unlockedBadgesProvider.notifier).refresh();
});
