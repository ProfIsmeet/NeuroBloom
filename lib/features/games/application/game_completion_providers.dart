import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../onboarding/application/profile_providers.dart';
import '../data/game_completion_repository.dart';
import '../domain/game_completion.dart';

final gameCompletionRepositoryProvider = Provider<GameCompletionRepository>((
  ref,
) {
  return GameCompletionRepository(ref.watch(storageServiceProvider));
});

final gameCompletionsProvider =
    AsyncNotifierProvider<GameCompletionsController, List<GameCompletion>>(
      GameCompletionsController.new,
    );

class GameCompletionsController extends AsyncNotifier<List<GameCompletion>> {
  @override
  Future<List<GameCompletion>> build() {
    return ref.watch(gameCompletionRepositoryProvider).loadAll();
  }

  Future<void> recordCompletion(String gameId) async {
    final updated = await ref
        .read(gameCompletionRepositoryProvider)
        .recordCompletion(gameId, DateTime.now());
    state = AsyncData(updated);
  }
}
