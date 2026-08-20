import 'tts_service.dart';

/// Used when the user has disabled TTS. speak()/stop() are no-ops.
class NoopTtsService implements TTSService {
  const NoopTtsService();

  @override
  Future<void> speak(String text) async {}

  @override
  Future<void> stop() async {}
}
