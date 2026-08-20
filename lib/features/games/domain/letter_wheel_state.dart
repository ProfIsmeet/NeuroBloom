import 'letter_wheel_item.dart';

enum LetterWheelPhase {
  idle,
  spinning,
  ready,
  recording,
  recorded,
  completed,
}

class LetterWheelState {
  const LetterWheelState({
    required this.phase,
    this.currentItem,
    this.recordingPath,
    this.permissionDenied = false,
    this.newlyUnlockedBadgeIds = const {},
  });

  const LetterWheelState.initial() : this(phase: LetterWheelPhase.idle);

  final LetterWheelPhase phase;
  final LetterWheelItem? currentItem;

  /// Path to the current recording (temp dir only, deleted on re-record,
  /// completion, or dispose — never persisted).
  final String? recordingPath;

  /// True after a requestPermission() call returns denied. The record
  /// controls hide; the game stays playable (spin + finish still work).
  final bool permissionDenied;

  final Set<String> newlyUnlockedBadgeIds;

  LetterWheelState copyWith({
    LetterWheelPhase? phase,
    LetterWheelItem? currentItem,
    String? recordingPath,
    bool clearRecordingPath = false,
    bool? permissionDenied,
    Set<String>? newlyUnlockedBadgeIds,
  }) {
    return LetterWheelState(
      phase: phase ?? this.phase,
      currentItem: currentItem ?? this.currentItem,
      recordingPath: clearRecordingPath
          ? null
          : (recordingPath ?? this.recordingPath),
      permissionDenied: permissionDenied ?? this.permissionDenied,
      newlyUnlockedBadgeIds: newlyUnlockedBadgeIds ?? this.newlyUnlockedBadgeIds,
    );
  }
}
