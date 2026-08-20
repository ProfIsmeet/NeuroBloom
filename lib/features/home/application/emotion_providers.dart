import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/content/content_providers.dart';
import '../../onboarding/application/profile_providers.dart';
import '../data/emotion_content_repository.dart';
import '../data/emotion_record_repository.dart';
import '../domain/emotion_definition.dart';

final emotionContentRepositoryProvider = Provider<EmotionContentRepository>((
  ref,
) {
  return EmotionContentRepository(ref.watch(contentLoaderProvider));
});

final emotionDefinitionsProvider = FutureProvider<List<EmotionDefinition>>((
  ref,
) {
  return ref.watch(emotionContentRepositoryProvider).loadEmotions();
});

final emotionRecordRepositoryProvider = Provider<EmotionRecordRepository>((
  ref,
) {
  return EmotionRecordRepository(ref.watch(storageServiceProvider));
});

final emotionRecordsProvider =
    AsyncNotifierProvider<EmotionRecordsController, Map<String, String>>(
      EmotionRecordsController.new,
    );

class EmotionRecordsController extends AsyncNotifier<Map<String, String>> {
  @override
  Future<Map<String, String>> build() {
    return ref.watch(emotionRecordRepositoryProvider).loadAll();
  }

  Future<void> recordToday(String emotionId) async {
    final updated = await ref
        .read(emotionRecordRepositoryProvider)
        .recordEmotion(DateTime.now(), emotionId);
    state = AsyncData(updated);
  }
}

/// Monday-start dates for the week containing [reference].
List<DateTime> weekDates(DateTime reference) {
  final monday = reference.subtract(Duration(days: reference.weekday - 1));
  return List.generate(
    7,
    (i) => DateTime(monday.year, monday.month, monday.day + i),
  );
}
