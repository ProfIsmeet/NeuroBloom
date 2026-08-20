enum ExerciseRunnerPhase { idle, counting, completed, skipped }

class ExerciseRunnerState {
  const ExerciseRunnerState({
    required this.phase,
    required this.currentRep,
    required this.secondsRemaining,
    this.newlyUnlockedBadgeIds = const {},
  });

  factory ExerciseRunnerState.initial(int duration) => ExerciseRunnerState(
    phase: ExerciseRunnerPhase.idle,
    currentRep: 1,
    secondsRemaining: duration,
  );

  final ExerciseRunnerPhase phase;
  final int currentRep;
  final int secondsRemaining;

  /// Badge ids unlocked by this exercise's completion, for the completed
  /// view to celebrate. Empty otherwise.
  final Set<String> newlyUnlockedBadgeIds;

  ExerciseRunnerState copyWith({
    ExerciseRunnerPhase? phase,
    int? currentRep,
    int? secondsRemaining,
    Set<String>? newlyUnlockedBadgeIds,
  }) {
    return ExerciseRunnerState(
      phase: phase ?? this.phase,
      currentRep: currentRep ?? this.currentRep,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      newlyUnlockedBadgeIds:
          newlyUnlockedBadgeIds ?? this.newlyUnlockedBadgeIds,
    );
  }
}
