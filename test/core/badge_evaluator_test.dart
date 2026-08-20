import 'package:flutter_test/flutter_test.dart';
import 'package:neurobloom/core/badges/badge.dart' as domain;
import 'package:neurobloom/core/badges/badge_evaluator.dart';
import 'package:neurobloom/core/badges/badge_rule.dart';
import 'package:neurobloom/core/badges/badge_stats.dart';

domain.Badge _badge(String id, BadgeRule rule) {
  return domain.Badge(id: id, title: id, description: id, icon: 'star_rounded', rule: rule);
}

void main() {
  group('evaluateUnlockedBadges', () {
    test('unlocks exercise_count, streak, xp, active_days, category_count, game_count', () {
      final badges = [
        _badge('first_step', const BadgeRule(type: 'exercise_count', threshold: 1)),
        _badge('streak_3', const BadgeRule(type: 'streak', threshold: 3)),
        _badge('xp_500', const BadgeRule(type: 'xp', threshold: 500)),
        _badge('consistency', const BadgeRule(type: 'active_days', threshold: 14)),
        _badge(
          'sound_explorer',
          const BadgeRule(type: 'category_count', category: 'tongue', threshold: 5),
        ),
        _badge('game_lover', const BadgeRule(type: 'game_count', threshold: 5)),
      ];
      const stats = BadgeStats(
        totalXp: 500,
        currentStreak: 3,
        totalExerciseCount: 1,
        exerciseCountByCategory: {'tongue': 5},
        gameCount: 5,
        activeDaysCount: 14,
      );

      final unlocked = evaluateUnlockedBadges(
        badges: badges,
        stats: stats,
        alreadyUnlocked: {},
      );

      expect(unlocked, badges.map((b) => b.id).toSet());
    });

    test('does not unlock badges whose threshold is not yet met', () {
      final badges = [_badge('xp_1000', const BadgeRule(type: 'xp', threshold: 1000))];
      const stats = BadgeStats(
        totalXp: 999,
        currentStreak: 0,
        totalExerciseCount: 0,
        exerciseCountByCategory: {},
        gameCount: 0,
        activeDaysCount: 0,
      );

      final unlocked = evaluateUnlockedBadges(
        badges: badges,
        stats: stats,
        alreadyUnlocked: {},
      );

      expect(unlocked, isEmpty);
    });

    test('already-unlocked badges are preserved even if stats regress (streak reset)', () {
      final badges = [_badge('streak_7', const BadgeRule(type: 'streak', threshold: 7))];
      const stats = BadgeStats(
        totalXp: 0,
        currentStreak: 0, // streak broke after the badge was earned
        totalExerciseCount: 0,
        exerciseCountByCategory: {},
        gameCount: 0,
        activeDaysCount: 0,
      );

      final unlocked = evaluateUnlockedBadges(
        badges: badges,
        stats: stats,
        alreadyUnlocked: {'streak_7'},
      );

      expect(unlocked, {'streak_7'});
    });

    test('all_badges meta-rule unlocks only once every other badge is unlocked', () {
      final badges = [
        _badge('a', const BadgeRule(type: 'exercise_count', threshold: 1)),
        _badge('b', const BadgeRule(type: 'exercise_count', threshold: 2)),
        _badge('star', const BadgeRule(type: 'all_badges')),
      ];

      const partialStats = BadgeStats(
        totalXp: 0,
        currentStreak: 0,
        totalExerciseCount: 1,
        exerciseCountByCategory: {},
        gameCount: 0,
        activeDaysCount: 0,
      );
      final partial = evaluateUnlockedBadges(
        badges: badges,
        stats: partialStats,
        alreadyUnlocked: {},
      );
      expect(partial, {'a'});

      const fullStats = BadgeStats(
        totalXp: 0,
        currentStreak: 0,
        totalExerciseCount: 2,
        exerciseCountByCategory: {},
        gameCount: 0,
        activeDaysCount: 0,
      );
      final full = evaluateUnlockedBadges(
        badges: badges,
        stats: fullStats,
        alreadyUnlocked: {},
      );
      expect(full, {'a', 'b', 'star'});
    });
  });
}
