import 'dart:convert';

import '../../../core/constants/storage_keys.dart';
import '../../../core/storage/storage_service.dart';
import '../domain/exercise_completion.dart';

class ExerciseCompletionRepository {
  ExerciseCompletionRepository(this._storage);

  final StorageService _storage;

  Future<List<ExerciseCompletion>> loadAll() async {
    final raw = await _storage.readString(StorageKeys.exerciseCompletions);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .map(ExerciseCompletion.tryParse)
          .whereType<ExerciseCompletion>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<ExerciseCompletion>> recordCompletion(
    String exerciseId,
    DateTime date,
  ) async {
    final all = await loadAll();
    all.add(ExerciseCompletion(exerciseId: exerciseId, date: date));
    await _storage.writeString(
      StorageKeys.exerciseCompletions,
      jsonEncode(all.map((c) => c.toJson()).toList()),
    );
    return all;
  }
}
