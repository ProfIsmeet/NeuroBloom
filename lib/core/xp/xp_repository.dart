import '../constants/storage_keys.dart';
import '../storage/storage_service.dart';

/// Running XP total. This is intentionally minimal for Phase 5 (award on
/// exercise completion); Phase 6 replaces/extends this with an idempotent
/// per-activity XpEvent ledger for duplicate-prevention.
class XpRepository {
  XpRepository(this._storage);

  final StorageService _storage;

  Future<int> getTotal() async {
    final raw = await _storage.readString(StorageKeys.totalXp);
    return int.tryParse(raw ?? '') ?? 0;
  }

  Future<int> addXp(int amount) async {
    final updated = (await getTotal()) + amount;
    await _storage.writeString(StorageKeys.totalXp, updated.toString());
    return updated;
  }
}
