import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/onboarding/application/profile_providers.dart';
import '../constants/xp_values.dart';
import '../utils/date_key.dart';
import 'xp_event.dart';
import 'xp_ledger_repository.dart';

final xpLedgerRepositoryProvider = Provider<XpLedgerRepository>((ref) {
  return XpLedgerRepository(ref.watch(storageServiceProvider));
});

final xpEventsProvider =
    AsyncNotifierProvider<XpEventsController, List<XpEvent>>(
      XpEventsController.new,
    );

class XpEventsController extends AsyncNotifier<List<XpEvent>> {
  @override
  Future<List<XpEvent>> build() {
    return ref.watch(xpLedgerRepositoryProvider).loadAll();
  }

  /// Idempotent: awarding the same (activityType, sourceId, today) more
  /// than once is a no-op, so callers never need to guard against
  /// double-taps or repeat calls themselves.
  Future<void> award({
    required String activityType,
    required String sourceId,
    required int amount,
    DateTime? date,
  }) async {
    final updated = await ref
        .read(xpLedgerRepositoryProvider)
        .record(
          activityType: activityType,
          sourceId: sourceId,
          date: dateKey(date ?? DateTime.now()),
          amount: amount,
        );
    state = AsyncData(updated);
  }
}

/// Total XP, derived from the ledger rather than stored separately.
final totalXpProvider = Provider<int>((ref) {
  final events = ref.watch(xpEventsProvider).valueOrNull ?? [];
  return ref.watch(xpLedgerRepositoryProvider).totalOf(events);
});

/// Awards the once-per-day login XP the first time this provider is
/// watched (e.g. from Home after onboarding). Idempotent via the ledger,
/// so re-watching or app restarts within the same day never double-award.
final dailyLoginAwardProvider = FutureProvider<void>((ref) async {
  await ref
      .read(xpEventsProvider.notifier)
      .award(activityType: 'login', sourceId: 'daily', amount: XpValues.dailyLogin);
});
