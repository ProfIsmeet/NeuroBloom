import 'dart:convert';

import '../constants/storage_keys.dart';
import '../storage/storage_service.dart';

/// Persists the set of unlocked badge ids. Append-only by convention —
/// callers should union with the previous result rather than shrink it,
/// since badges never re-lock.
class BadgeUnlockRepository {
  BadgeUnlockRepository(this._storage);

  final StorageService _storage;

  Future<Set<String>> loadUnlocked() async {
    final raw = await _storage.readString(StorageKeys.unlockedBadges);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return {};
      return decoded.whereType<String>().toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> saveUnlocked(Set<String> unlocked) async {
    await _storage.writeString(
      StorageKeys.unlockedBadges,
      jsonEncode(unlocked.toList()),
    );
  }
}
