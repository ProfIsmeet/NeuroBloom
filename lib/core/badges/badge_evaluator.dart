import 'badge.dart';
import 'badge_stats.dart';

/// Evaluates which badges are unlocked right now given [stats] and the
/// set already unlocked (badges never re-lock, so [alreadyUnlocked] is
/// always a subset of the result). Pure and side-effect free — callers
/// persist the result themselves.
Set<String> evaluateUnlockedBadges({
  required List<Badge> badges,
  required BadgeStats stats,
  required Set<String> alreadyUnlocked,
}) {
  final unlocked = {...alreadyUnlocked};

  bool satisfiesRule(Badge badge) {
    final rule = badge.rule;
    switch (rule.type) {
      case 'exercise_count':
        return stats.totalExerciseCount >= rule.threshold;
      case 'streak':
        return stats.currentStreak >= rule.threshold;
      case 'category_count':
        final count = stats.exerciseCountByCategory[rule.category] ?? 0;
        return count >= rule.threshold;
      case 'game_count':
        return stats.gameCount >= rule.threshold;
      case 'xp':
        return stats.totalXp >= rule.threshold;
      case 'active_days':
        return stats.activeDaysCount >= rule.threshold;
      case 'all_badges':
        final others = badges.where((b) => b.id != badge.id).map((b) => b.id);
        return others.every(unlocked.contains);
      default:
        return false;
    }
  }

  // Two passes so the "all_badges" meta-badge sees this run's other
  // unlocks before it is evaluated, without depending on list order.
  for (final badge in badges) {
    if (unlocked.contains(badge.id)) continue;
    if (badge.rule.type == 'all_badges') continue;
    if (satisfiesRule(badge)) unlocked.add(badge.id);
  }
  for (final badge in badges) {
    if (unlocked.contains(badge.id)) continue;
    if (badge.rule.type != 'all_badges') continue;
    if (satisfiesRule(badge)) unlocked.add(badge.id);
  }

  return unlocked;
}
