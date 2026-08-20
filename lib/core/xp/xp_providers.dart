import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/onboarding/application/profile_providers.dart';
import 'xp_repository.dart';

final xpRepositoryProvider = Provider<XpRepository>((ref) {
  return XpRepository(ref.watch(storageServiceProvider));
});

final totalXpProvider = AsyncNotifierProvider<TotalXpController, int>(
  TotalXpController.new,
);

class TotalXpController extends AsyncNotifier<int> {
  @override
  Future<int> build() => ref.watch(xpRepositoryProvider).getTotal();

  Future<void> addXp(int amount) async {
    final updated = await ref.read(xpRepositoryProvider).addXp(amount);
    state = AsyncData(updated);
  }
}
