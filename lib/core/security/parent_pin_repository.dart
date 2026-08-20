import 'pbkdf2.dart';
import 'secure_credential_store.dart';

abstract final class _Keys {
  static const salt = 'parent_pin_salt';
  static const hash = 'parent_pin_hash';
}

/// Manages the parent PIN: created once, never stored or compared in
/// plaintext (PBKDF2-hashed with a random per-install salt, both kept in
/// secure storage — never in the general Hive-backed StorageService).
class ParentPinRepository {
  ParentPinRepository(this._store);

  final SecureCredentialStore _store;

  Future<bool> hasPin() async {
    final hash = await _store.read(_Keys.hash);
    return hash != null;
  }

  Future<void> createPin(String pin) async {
    final salt = generateSalt();
    final hash = pbkdf2(password: pin, salt: salt);
    await _store.write(_Keys.salt, bytesToHex(salt));
    await _store.write(_Keys.hash, bytesToHex(hash));
  }

  Future<bool> verifyPin(String pin) async {
    final saltHex = await _store.read(_Keys.salt);
    final storedHashHex = await _store.read(_Keys.hash);
    if (saltHex == null || storedHashHex == null) return false;

    final salt = hexToBytes(saltHex);
    final candidateHash = bytesToHex(pbkdf2(password: pin, salt: salt));
    return _constantTimeEquals(candidateHash, storedHashHex);
  }

  bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}
