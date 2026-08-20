import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/xp_values.dart';
import '../../../core/gamification/gamification_refresh.dart';
import '../../../core/services/audio_providers.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/xp/xp_providers.dart';
import '../domain/letter_wheel_state.dart';
import 'game_completion_providers.dart';
import 'letter_wheel_providers.dart';

const String letterWheelGameId = 'letter_wheel';

final letterWheelControllerProvider = StateNotifierProvider.autoDispose<
    LetterWheelController, LetterWheelState>((ref) {
  return LetterWheelController(ref);
});

class LetterWheelController extends StateNotifier<LetterWheelState> {
  LetterWheelController(this._ref)
    : _audio = _ref.read(audioServiceProvider),
      super(const LetterWheelState.initial());

  final Ref _ref;
  // Captured once at construction rather than re-read via _ref during
  // dispose: once the whole container starts tearing down, other
  // providers' elements may already be gone, making ref.read unsafe at
  // that point.
  final AudioService _audio;
  final _random = math.Random();

  Future<void> spin() async {
    final items = await _ref.read(letterWheelItemsProvider.future);
    if (items.isEmpty || !mounted) return;
    state = const LetterWheelState.initial().copyWith(
      phase: LetterWheelPhase.spinning,
    );
    // Brief spin feel; reduced-motion users just see it resolve quickly.
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    final item = items[_random.nextInt(items.length)];
    state = state.copyWith(phase: LetterWheelPhase.ready, currentItem: item);
  }

  Future<void> startRecording() async {
    final granted = await _audio.requestPermission();
    if (!mounted) return;
    if (!granted) {
      state = state.copyWith(permissionDenied: true);
      return;
    }
    await _audio.startRecording();
    if (!mounted) return;
    state = state.copyWith(
      phase: LetterWheelPhase.recording,
      permissionDenied: false,
    );
  }

  Future<void> stopRecording() async {
    final path = await _audio.stopRecording();
    if (!mounted) return;
    state = state.copyWith(phase: LetterWheelPhase.recorded, recordingPath: path);
  }

  Future<void> playRecording() async {
    final path = state.recordingPath;
    if (path == null) return;
    await _audio.playRecording(path);
  }

  /// Discards the current recording and immediately starts a new one.
  Future<void> reRecord() async {
    final oldPath = state.recordingPath;
    if (oldPath != null) {
      await _audio.deleteRecording(oldPath);
    }
    if (!mounted) return;
    state = state.copyWith(clearRecordingPath: true);
    await startRecording();
  }

  Future<void> finish() async {
    final path = state.recordingPath;
    if (path != null) {
      await _audio.deleteRecording(path);
    }
    if (!mounted) return;
    state = state.copyWith(phase: LetterWheelPhase.completed, clearRecordingPath: true);

    await _ref
        .read(gameCompletionsProvider.notifier)
        .recordCompletion(letterWheelGameId);
    // Idempotent per day, same rule as exercises: replaying the game the
    // same day still records history but doesn't farm extra XP.
    await _ref.read(xpEventsProvider.notifier).award(
          activityType: 'game',
          sourceId: letterWheelGameId,
          amount: XpValues.miniGame,
        );
    final newlyUnlocked = await refreshGamification(_ref);
    if (!mounted) return;
    state = state.copyWith(newlyUnlockedBadgeIds: newlyUnlocked);
  }

  @override
  void dispose() {
    // Session ended (back navigation, screen disposed): never keep a
    // recording around beyond the session, regardless of how it ended.
    // Uses the captured _audio reference, not _ref, since other
    // providers may already be torn down by the time this runs.
    final path = state.recordingPath;
    if (path != null) {
      _audio.deleteRecording(path);
    } else if (state.phase == LetterWheelPhase.recording) {
      // stopRecording() finalizes and returns the file that was being
      // written; that path was never stored in state, so it must be
      // captured here or it leaks on disk.
      _audio.stopRecording().then((stoppedPath) {
        if (stoppedPath != null) _audio.deleteRecording(stoppedPath);
      });
    }
    super.dispose();
  }
}
