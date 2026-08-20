/// Real, locally-derived stats a BadgeRule is evaluated against. No mock
/// data — every field is computed from actual persisted activity.
class BadgeStats {
  const BadgeStats({
    required this.totalXp,
    required this.currentStreak,
    required this.totalExerciseCount,
    required this.exerciseCountByCategory,
    required this.gameCount,
    required this.activeDaysCount,
  });

  final int totalXp;
  final int currentStreak;
  final int totalExerciseCount;
  final Map<String, int> exerciseCountByCategory;

  /// Mini-game plays. Always 0 until Faz 7 ships the first game — the
  /// "Game Lover" badge simply stays locked until then.
  final int gameCount;
  final int activeDaysCount;
}
