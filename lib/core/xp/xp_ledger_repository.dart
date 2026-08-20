import 'dart:convert';

import '../constants/storage_keys.dart';
import '../storage/storage_service.dart';
import 'xp_event.dart';

/// Append-only, idempotent XP ledger. The total XP is the sum of all
/// recorded events — there is no separate running-total counter to drift
/// out of sync.
class XpLedgerRepository {
  XpLedgerRepository(this._storage);

  final StorageService _storage;

  Future<List<XpEvent>> loadAll() async {
    final raw = await _storage.readString(StorageKeys.xpEvents);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded.map(XpEvent.tryParse).whereType<XpEvent>().toList();
    } catch (_) {
      return [];
    }
  }

  /// Records an XP award unless an event with the same
  /// (activityType, sourceId, date) key already exists, in which case
  /// this is a no-op and the unchanged list is returned.
  Future<List<XpEvent>> record({
    required String activityType,
    required String sourceId,
    required String date,
    required int amount,
  }) async {
    final all = await loadAll();
    final key = '$activityType|$sourceId|$date';
    if (all.any((e) => e.dedupeKey == key)) return all;

    all.add(
      XpEvent(
        activityType: activityType,
        sourceId: sourceId,
        date: date,
        amount: amount,
      ),
    );
    await _storage.writeString(
      StorageKeys.xpEvents,
      jsonEncode(all.map((e) => e.toJson()).toList()),
    );
    return all;
  }

  int totalOf(List<XpEvent> events) =>
      events.fold(0, (sum, e) => sum + e.amount);
}
