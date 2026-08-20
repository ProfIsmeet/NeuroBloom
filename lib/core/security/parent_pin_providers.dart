import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'flutter_secure_credential_store.dart';
import 'parent_pin_repository.dart';
import 'secure_credential_store.dart';

final secureCredentialStoreProvider = Provider<SecureCredentialStore>((ref) {
  return FlutterSecureCredentialStore();
});

final parentPinRepositoryProvider = Provider<ParentPinRepository>((ref) {
  return ParentPinRepository(ref.watch(secureCredentialStoreProvider));
});

/// Session-only unlock flag (never persisted): true only after a correct
/// PIN is verified this app session. Resets on app restart, so every
/// launch requires the PIN again. This is the actual gate the dashboard
/// route checks — see AppRouter's redirect for '/parent/dashboard'.
final parentUnlockedProvider = StateProvider<bool>((ref) => false);

class ParentAuthController {
  ParentAuthController(this._ref);

  final Ref _ref;

  Future<bool> hasPin() => _ref.read(parentPinRepositoryProvider).hasPin();

  Future<void> createPin(String pin) async {
    await _ref.read(parentPinRepositoryProvider).createPin(pin);
    _ref.read(parentUnlockedProvider.notifier).state = true;
  }

  Future<bool> attemptUnlock(String pin) async {
    final correct = await _ref.read(parentPinRepositoryProvider).verifyPin(pin);
    if (correct) {
      _ref.read(parentUnlockedProvider.notifier).state = true;
    }
    return correct;
  }

  void lock() {
    _ref.read(parentUnlockedProvider.notifier).state = false;
  }
}

final parentAuthControllerProvider = Provider<ParentAuthController>((ref) {
  return ParentAuthController(ref);
});
