import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/content/content_providers.dart';
import '../data/letter_wheel_repository.dart';
import '../domain/letter_wheel_item.dart';

final letterWheelRepositoryProvider = Provider<LetterWheelRepository>((ref) {
  return LetterWheelRepository(ref.watch(contentLoaderProvider));
});

final letterWheelItemsProvider = FutureProvider<List<LetterWheelItem>>((ref) {
  return ref.watch(letterWheelRepositoryProvider).loadAll();
});
