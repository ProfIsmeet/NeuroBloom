import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'audio_service.dart';

/// Real microphone/playback implementation. All platform-channel errors
/// (no mic hardware, permission race, unsupported codec, ...) are
/// swallowed rather than thrown, matching FlutterTtsService's "must never
/// crash the app" contract.
class RecordAudioService implements AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  @override
  Future<bool> requestPermission() async {
    try {
      return await _recorder.hasPermission();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> startRecording() async {
    try {
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/neurobloom_${DateTime.now().microsecondsSinceEpoch}.m4a';
      await _recorder.start(const RecordConfig(), path: path);
    } catch (_) {
      // Recording never started; stopRecording() will return null.
    }
  }

  @override
  Future<String?> stopRecording() async {
    try {
      return await _recorder.stop();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> playRecording(String path) async {
    try {
      await _player.setFilePath(path);
      await _player.play();
    } catch (_) {
      // Missing/corrupted file: fail silently, nothing to play.
    }
  }

  @override
  Future<void> stopPlayback() async {
    try {
      await _player.stop();
    } catch (_) {}
  }

  @override
  Future<void> deleteRecording(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }
}
