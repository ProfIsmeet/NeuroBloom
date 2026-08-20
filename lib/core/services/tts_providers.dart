import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/onboarding/application/profile_providers.dart';
import '../constants/storage_keys.dart';
import 'flutter_tts_service.dart';
import 'noop_tts_service.dart';
import 'tts_service.dart';

final flutterTtsServiceProvider = Provider<TTSService>((ref) => FlutterTtsService());

final ttsEnabledProvider = AsyncNotifierProvider<TtsEnabledController, bool>(
  TtsEnabledController.new,
);

class TtsEnabledController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final raw = await ref
        .watch(storageServiceProvider)
        .readString(StorageKeys.ttsEnabled);
    return raw != 'false';
  }

  Future<void> setEnabled(bool value) async {
    await ref
        .read(storageServiceProvider)
        .writeString(StorageKeys.ttsEnabled, value.toString());
    state = AsyncData(value);
  }
}

/// Resolves to the real TTS engine when enabled, or a silent no-op
/// implementation when the user has disabled TTS.
final ttsServiceProvider = Provider<TTSService>((ref) {
  final enabled = ref.watch(ttsEnabledProvider).valueOrNull ?? true;
  return enabled ? ref.watch(flutterTtsServiceProvider) : const NoopTtsService();
});
