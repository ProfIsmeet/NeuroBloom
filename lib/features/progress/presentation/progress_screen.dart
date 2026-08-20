import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/streak/streak_providers.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/date_key.dart';
import '../../../core/widgets/today_goals_card.dart';
import '../../../core/xp/xp_event.dart';
import '../../../core/xp/xp_providers.dart';
import '../../exercises/application/exercise_completion_providers.dart';
import '../../exercises/application/exercise_providers.dart';
import '../../exercises/domain/exercise_completion.dart';
import '../../games/application/game_completion_providers.dart';
import '../../home/application/emotion_providers.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('İlerleme')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.spaceLg),
        children: const [
          _StatsGrid(),
          SizedBox(height: AppDimens.spaceLg),
          TodayGoalsCard(),
          SizedBox(height: AppDimens.spaceLg),
          Text('Geçmiş', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: AppDimens.spaceMd),
          _ExerciseHistorySection(),
          SizedBox(height: AppDimens.spaceLg),
          _XpHistorySection(),
          SizedBox(height: AppDimens.spaceLg),
          _EmotionHistorySection(),
        ],
      ),
    );
  }
}

class _StatsGrid extends ConsumerWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalXp = ref.watch(totalXpProvider);
    final streak = ref.watch(currentStreakProvider);
    final exerciseCount =
        (ref.watch(exerciseCompletionsProvider).valueOrNull ?? []).length;
    final gameCount = (ref.watch(gameCompletionsProvider).valueOrNull ?? []).length;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppDimens.spaceMd,
      crossAxisSpacing: AppDimens.spaceMd,
      childAspectRatio: 1.7,
      children: [
        _StatCard(icon: '⭐', label: 'Toplam XP', value: '$totalXp'),
        _StatCard(icon: '🔥', label: 'Seri', value: '$streak gün'),
        _StatCard(icon: '🧘', label: 'Egzersiz', value: '$exerciseCount'),
        _StatCard(icon: '🎮', label: 'Oyun', value: '$gameCount'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.label, required this.value});

  final String icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text('$icon $value', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}

class _ExerciseHistorySection extends ConsumerWidget {
  const _ExerciseHistorySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completions = ref.watch(exerciseCompletionsProvider).valueOrNull ?? [];
    final catalog = ref.watch(allExercisesProvider).valueOrNull ?? [];
    final titleById = {for (final e in catalog) e.id: e.title};

    final sorted = [...completions]..sort((a, b) => b.date.compareTo(a.date));

    return _HistorySection(
      title: 'Egzersiz Geçmişi',
      emptyText: 'Henüz egzersiz tamamlanmadı.',
      itemCount: sorted.length,
      itemBuilder: (context, i) {
        final ExerciseCompletion completion = sorted[i];
        final title = titleById[completion.exerciseId] ?? completion.exerciseId;
        return _HistoryRow(label: title, date: dateKey(completion.date));
      },
    );
  }
}

class _XpHistorySection extends ConsumerWidget {
  const _XpHistorySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(xpEventsProvider).valueOrNull ?? [];
    final sorted = [...events]..sort((a, b) => b.date.compareTo(a.date));

    return _HistorySection(
      title: 'XP Geçmişi',
      emptyText: 'Henüz XP kazanılmadı.',
      itemCount: sorted.length,
      itemBuilder: (context, i) {
        final XpEvent event = sorted[i];
        return _HistoryRow(
          label: '${_xpActivityLabel(event.activityType)} +${event.amount} XP',
          date: event.date,
        );
      },
    );
  }
}

String _xpActivityLabel(String activityType) {
  switch (activityType) {
    case 'login':
      return 'Giriş';
    case 'emotion':
      return 'Duygu';
    case 'exercise':
      return 'Egzersiz';
    case 'game':
      return 'Oyun';
    case 'streak_bonus':
      return 'Seri Bonusu';
    default:
      return activityType;
  }
}

class _EmotionHistorySection extends ConsumerWidget {
  const _EmotionHistorySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(emotionRecordsProvider).valueOrNull ?? {};
    final definitions = ref.watch(emotionDefinitionsProvider).valueOrNull ?? [];
    final emojiById = {for (final d in definitions) d.id: d.emoji};

    final entries = records.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return _HistorySection(
      title: 'Duygu Geçmişi',
      emptyText: 'Henüz duygu kaydedilmedi.',
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final entry = entries[i];
        final emoji = emojiById[entry.value] ?? '–';
        return _HistoryRow(label: emoji, date: entry.key);
      },
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({
    required this.title,
    required this.emptyText,
    required this.itemCount,
    required this.itemBuilder,
  });

  final String title;
  final String emptyText;
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppDimens.spaceSm),
        if (itemCount == 0)
          Text(emptyText, style: Theme.of(context).textTheme.bodyMedium)
        else
          Card(
            child: Column(
              children: List.generate(itemCount, (i) => itemBuilder(context, i)),
            ),
          ),
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.label, required this.date});

  final String label;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.spaceMd,
        vertical: AppDimens.spaceSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label)),
          Text(date, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
