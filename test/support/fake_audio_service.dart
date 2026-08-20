import 'package:neurobloom/core/services/audio_service.dart';

/// Configurable fake for LetterWheelController tests: never touches a
/// platform channel, tracks calls, and can simulate permission denial.
class FakeAudioService implements AudioService {
  bool permissionGranted = true;
  int startCount = 0;
  int stopCount = 0;
  int playCount = 0;
  final List<String> deletedPaths = [];

  String? _nextRecordingPath;
  int _recordingSeq = 0;

  @override
  Future<bool> requestPermission() async => permissionGranted;

  @override
  Future<void> startRecording() async {
    startCount++;
    _nextRecordingPath = 'fake_recording_${_recordingSeq++}.m4a';
  }

  @override
  Future<String?> stopRecording() async {
    stopCount++;
    final path = _nextRecordingPath;
    _nextRecordingPath = null;
    return path;
  }

  @override
  Future<void> playRecording(String path) async {
    playCount++;
  }

  @override
  Future<void> stopPlayback() async {}

  @override
  Future<void> deleteRecording(String path) async {
    deletedPaths.add(path);
  }
}
