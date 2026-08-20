import 'package:flutter_tts/flutter_tts.dart';

import 'tts_service.dart';

class FlutterTtsService implements TTSService {
  final FlutterTts _tts = FlutterTts();

  @override
  Future<void> speak(String text) async {
    try {
      await _tts.setLanguage('tr-TR');
      await _tts.speak(text);
    } catch (_) {
      // TTS engine or Turkish voice unavailable: fail silently, the
      // instruction text is always visible on screen regardless.
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
