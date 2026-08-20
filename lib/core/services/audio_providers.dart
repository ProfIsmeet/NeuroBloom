import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'audio_service.dart';
import 'record_audio_service.dart';

/// Real by default (mirrors flutterTtsServiceProvider); tests override
/// with NoopAudioService so they never touch a platform channel.
final audioServiceProvider = Provider<AudioService>((ref) {
  return RecordAudioService();
});
