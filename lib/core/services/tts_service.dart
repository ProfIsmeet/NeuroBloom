/// Abstract text-to-speech interface. The app must remain fully usable
/// (instructions are always readable on screen) whether or not a real
/// TTS engine/voice is available.
abstract class TTSService {
  Future<void> speak(String text);
  Future<void> stop();
}
