import 'audio_service.dart';

/// No-op implementation for widget tests, so they never touch a real
/// platform channel. Always "succeeds" with a fake path.
class NoopAudioService implements AudioService {
  const NoopAudioService();

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> startRecording() async {}

  @override
  Future<String?> stopRecording() async => 'noop-recording.m4a';

  @override
  Future<void> playRecording(String path) async {}

  @override
  Future<void> stopPlayback() async {}

  @override
  Future<void> deleteRecording(String path) async {}
}
