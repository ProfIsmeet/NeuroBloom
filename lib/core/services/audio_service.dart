/// Abstraction over microphone recording + playback so the real platform
/// implementation is swappable and the game logic stays testable without
/// touching platform channels. Never persists recordings beyond the
/// session — see deleteRecording.
abstract class AudioService {
  /// Requests microphone permission (only ever called at the moment the
  /// child taps the record button, never on screen load). Returns false
  /// on denial rather than throwing — the game must keep working.
  Future<bool> requestPermission();

  Future<void> startRecording();

  /// Stops recording and returns the file path, or null if nothing was
  /// recorded (e.g. permission was never granted).
  Future<String?> stopRecording();

  Future<void> playRecording(String path);

  Future<void> stopPlayback();

  /// Permanently deletes a recorded file. Safe to call even if the file
  /// no longer exists.
  Future<void> deleteRecording(String path);
}
