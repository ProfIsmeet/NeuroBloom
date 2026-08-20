enum ExerciseRunnerPhase { idle, counting, completed, skipped }

class ExerciseRunnerState {
  const ExerciseRunnerState({
    required this.phase,
    required this.currentRep,
    required this.secondsRemaining,
  });

  factory ExerciseRunnerState.initial(int duration) => ExerciseRunnerState(
    phase: ExerciseRunnerPhase.idle,
    currentRep: 1,
    secondsRemaining: duration,
  );

  final ExerciseRunnerPhase phase;
  final int currentRep;
  final int secondsRemaining;

  ExerciseRunnerState copyWith({
    ExerciseRunnerPhase? phase,
    int? currentRep,
    int? secondsRemaining,
  }) {
    return ExerciseRunnerState(
      phase: phase ?? this.phase,
      currentRep: currentRep ?? this.currentRep,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
    );
  }
}
