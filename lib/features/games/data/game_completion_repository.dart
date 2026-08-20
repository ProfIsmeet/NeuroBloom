import 'dart:convert';

import '../../../core/constants/storage_keys.dart';
import '../../../core/storage/storage_service.dart';
import '../domain/game_completion.dart';

class GameCompletionRepository {
  GameCompletionRepository(this._storage);

  final StorageService _storage;

  Future<List<GameCompletion>> loadAll() async {
    final raw = await _storage.readString(StorageKeys.gameCompletions);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .map(GameCompletion.tryParse)
          .whereType<GameCompletion>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<GameCompletion>> recordCompletion(
    String gameId,
    DateTime date,
  ) async {
    final all = await loadAll();
    all.add(GameCompletion(gameId: gameId, date: date));
    await _storage.writeString(
      StorageKeys.gameCompletions,
      jsonEncode(all.map((c) => c.toJson()).toList()),
    );
    return all;
  }
}
