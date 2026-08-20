import 'dart:convert';

import '../../../core/constants/storage_keys.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/utils/date_key.dart' as date_utils;

/// Persists at most one emotion per local calendar day, keyed by
/// 'yyyy-MM-dd'. Recording again on the same day overwrites (upsert),
/// it never appends a second entry for that date.
class EmotionRecordRepository {
  EmotionRecordRepository(this._storage);

  final StorageService _storage;

  static String dateKey(DateTime date) => date_utils.dateKey(date);

  Future<Map<String, String>> loadAll() async {
    final raw = await _storage.readString(StorageKeys.emotionRecords);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      return decoded.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    } catch (_) {
      return {};
    }
  }

  Future<Map<String, String>> recordEmotion(
    DateTime date,
    String emotionId,
  ) async {
    final records = await loadAll();
    records[dateKey(date)] = emotionId;
    await _storage.writeString(
      StorageKeys.emotionRecords,
      jsonEncode(records),
    );
    return records;
  }
}
