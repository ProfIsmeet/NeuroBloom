import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neurobloom/core/services/audio_providers.dart';
import 'package:neurobloom/core/xp/xp_providers.dart';
import 'package:neurobloom/features/games/application/game_completion_providers.dart';
import 'package:neurobloom/features/games/application/letter_wheel_controller.dart';
import 'package:neurobloom/features/games/domain/letter_wheel_state.dart';
import 'package:neurobloom/features/onboarding/application/profile_providers.dart';

import '../../support/fake_audio_service.dart';
import '../../support/fake_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late FakeAudioService audio;

  setUp(() {
    audio = FakeAudioService();
    container = ProviderContainer(
      overrides: [
        storageServiceProvider.overrideWithValue(FakeStorageService()),
        audioServiceProvider.overrideWithValue(audio),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('spin loads the real content and lands on a syllable', () async {
    container.listen(letterWheelControllerProvider, (_, _) {});
    final controller = container.read(letterWheelControllerProvider.notifier);

    await controller.spin();

    final state = container.read(letterWheelControllerProvider);
    expect(state.phase, LetterWheelPhase.ready);
    expect(state.currentItem, isNotNull);
    expect(state.currentItem!.syllable, isNotEmpty);
  });

  test(
    'record -> stop -> play -> finish: awards XP, records completion, deletes the recording',
    () async {
      container.listen(letterWheelControllerProvider, (_, _) {});
      final controller = container.read(letterWheelControllerProvider.notifier);

      await controller.spin();
      await controller.startRecording();
      expect(container.read(letterWheelControllerProvider).phase, LetterWheelPhase.recording);
      expect(audio.startCount, 1);

      await controller.stopRecording();
      final recordedState = container.read(letterWheelControllerProvider);
      expect(recordedState.phase, LetterWheelPhase.recorded);
      expect(recordedState.recordingPath, isNotNull);
      expect(audio.stopCount, 1);

      await controller.playRecording();
      expect(audio.playCount, 1);

      await controller.finish();

      final finalState = container.read(letterWheelControllerProvider);
      expect(finalState.phase, LetterWheelPhase.completed);
      expect(finalState.recordingPath, isNull);
      expect(audio.deletedPaths, hasLength(1), reason: 'recording deleted on finish');

      expect(container.read(totalXpProvider), 30);
      final games = await container.read(gameCompletionsProvider.future);
      expect(games.any((g) => g.gameId == letterWheelGameId), isTrue);
    },
  );

  test('re-record deletes the old recording and starts a fresh one', () async {
    container.listen(letterWheelControllerProvider, (_, _) {});
    final controller = container.read(letterWheelControllerProvider.notifier);

    await controller.spin();
    await controller.startRecording();
    await controller.stopRecording();
    final firstPath = container.read(letterWheelControllerProvider).recordingPath;

    await controller.reRecord();

    expect(audio.deletedPaths, contains(firstPath));
    expect(
      container.read(letterWheelControllerProvider).phase,
      LetterWheelPhase.recording,
      reason: 'reRecord immediately starts a new recording',
    );
  });

  test(
    'denied microphone permission degrades to a playable no-recording mode',
    () async {
      audio.permissionGranted = false;
      container.listen(letterWheelControllerProvider, (_, _) {});
      final controller = container.read(letterWheelControllerProvider.notifier);

      await controller.spin();
      await controller.startRecording();

      final state = container.read(letterWheelControllerProvider);
      expect(state.permissionDenied, isTrue);
      expect(state.phase, LetterWheelPhase.ready, reason: 'never entered recording phase');
      expect(audio.startCount, 0);

      // The game must still be completable without ever recording.
      await controller.finish();
      expect(container.read(letterWheelControllerProvider).phase, LetterWheelPhase.completed);
      expect(container.read(totalXpProvider), 30);
    },
  );

  test(
    'completing the game twice the same day awards XP once, but records both plays',
    () async {
      container.listen(letterWheelControllerProvider, (_, _) {});
      final first = container.read(letterWheelControllerProvider.notifier);
      await first.spin();
      await first.finish();
      expect(container.read(totalXpProvider), 30);

      // A fresh session, as if the child re-opened the game the same day.
      container.invalidate(letterWheelControllerProvider);
      container.listen(letterWheelControllerProvider, (_, _) {});
      final second = container.read(letterWheelControllerProvider.notifier);
      await second.spin();
      await second.finish();

      expect(container.read(totalXpProvider), 30, reason: 'no duplicate XP');
      final games = await container.read(gameCompletionsProvider.future);
      expect(
        games.where((g) => g.gameId == letterWheelGameId).length,
        2,
        reason: 'both plays still recorded for history/streak',
      );
    },
  );

  test('disposing mid-recording stops and discards the in-progress recording', () async {
    final localContainer = ProviderContainer(
      overrides: [
        storageServiceProvider.overrideWithValue(FakeStorageService()),
        audioServiceProvider.overrideWithValue(audio),
      ],
    );
    final sub = localContainer.listen(letterWheelControllerProvider, (_, _) {});
    final controller = localContainer.read(letterWheelControllerProvider.notifier);

    await controller.spin();
    await controller.startRecording();
    expect(localContainer.read(letterWheelControllerProvider).phase, LetterWheelPhase.recording);

    sub.close();
    localContainer.dispose();
    // dispose()'s cleanup awaits stopRecording() internally (fire-and-forget
    // from the caller's perspective); let that microtask complete.
    await Future.delayed(Duration.zero);

    expect(audio.stopCount, 1, reason: 'in-progress recording is stopped on dispose');
    expect(
      audio.deletedPaths,
      isNotEmpty,
      reason: 'the file stopRecording() finalizes must not be left on disk',
    );
  });

  test(
    'disposing after stopping with an unfinished (un-played, un-finished) recording deletes it',
    () async {
      final localContainer = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(FakeStorageService()),
          audioServiceProvider.overrideWithValue(audio),
        ],
      );
      final sub = localContainer.listen(letterWheelControllerProvider, (_, _) {});
      final controller = localContainer.read(letterWheelControllerProvider.notifier);

      await controller.spin();
      await controller.startRecording();
      await controller.stopRecording();
      final path = localContainer.read(letterWheelControllerProvider).recordingPath;
      expect(path, isNotNull);

      sub.close();
      localContainer.dispose();

      expect(audio.deletedPaths, contains(path));
    },
  );
}
