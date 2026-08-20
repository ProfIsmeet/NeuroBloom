import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/exercises/application/exercise_completion_providers.dart';
import '../../features/games/application/game_completion_providers.dart';
import '../../features/home/application/emotion_providers.dart';
import '../../features/home/data/emotion_record_repository.dart';
import '../theme/app_dimens.dart';
import '../utils/date_key.dart';

/// Today's task checklist, driven entirely by real recorded activity.
/// Shown on both Home and Progress (Faz 8 lists it under Progress too).
/// Never penalizes incomplete tasks — it's just a reflection of the day.
class TodayGoalsCard extends ConsumerWidget {
  const TodayGoalsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayKey = EmotionRecordRepository.dateKey(DateTime.now());

    final recordsAsync = ref.watch(emotionRecordsProvider);
    final emotionDone = recordsAsync.valueOrNull?[todayKey] != null;

    final completionsAsync = ref.watch(exerciseCompletionsProvider);
    final exerciseDone =
        completionsAsync.valueOrNull?.any(
          (c) => dateKey(c.date) == todayKey,
        ) ??
        false;

    final gamesAsync = ref.watch(gameCompletionsProvider);
    final gameDone =
        gamesAsync.valueOrNull?.any((g) => dateKey(g.date) == todayKey) ??
        false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🌟 Bugünkü Görev', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppDimens.spaceSm),
            _GoalRow(label: 'Duygunu seç', done: emotionDone),
            _GoalRow(label: 'Egzersiz yap', done: exerciseDone),
            _GoalRow(label: 'Mini oyun oyna', done: gameDone),
          ],
        ),
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({required this.label, required this.done});

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: AppDimens.iconSizeSm,
            color: done ? Theme.of(context).colorScheme.primary : Colors.grey,
          ),
          const SizedBox(width: AppDimens.spaceSm),
          Text(label),
        ],
      ),
    );
  }
}
