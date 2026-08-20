import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/date_key.dart';
import '../../exercises/application/exercise_completion_providers.dart';
import '../../onboarding/application/profile_providers.dart';
import '../../onboarding/presentation/widgets/avatar_painter.dart';
import '../application/emotion_providers.dart';
import '../data/emotion_record_repository.dart';

const List<String> _weekdayLabelsTr = ['Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct', 'Pz'];

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _openAvatarPicker(
    BuildContext context,
    WidgetRef ref,
    int currentAvatarId,
  ) async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppDimens.spaceLg),
          child: Wrap(
            spacing: AppDimens.spaceMd,
            runSpacing: AppDimens.spaceMd,
            children: List.generate(8, (index) {
              return GestureDetector(
                onTap: () => Navigator.of(context).pop(index),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: index == currentAvatarId
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: AvatarWidget(avatarId: index),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
    if (selected != null) {
      await ref.read(profileControllerProvider.notifier).updateAvatar(selected);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ana Sayfa')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Bir şeyler ters gitti.')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(AppDimens.spaceLg),
            children: [
              _ProfileHeader(
                name: profile.name,
                avatarId: profile.avatarId,
                onAvatarTap: () =>
                    _openAvatarPicker(context, ref, profile.avatarId),
              ),
              const SizedBox(height: AppDimens.spaceLg),
              const _NeuroBotPrompt(),
              const SizedBox(height: AppDimens.spaceLg),
              const _EmotionSelector(),
              const SizedBox(height: AppDimens.spaceLg),
              const _WeeklyEmotionCalendar(),
              const SizedBox(height: AppDimens.spaceLg),
              const _TodayGoals(),
              const SizedBox(height: AppDimens.spaceLg),
              const _WeeklyProgress(),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.avatarId,
    required this.onAvatarTap,
  });

  final String name;
  final int avatarId;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onAvatarTap,
          child: AvatarWidget(avatarId: avatarId, size: 64),
        ),
        const SizedBox(width: AppDimens.spaceMd),
        Expanded(
          child: Text(
            'Merhaba, $name!',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ],
    );
  }
}

class _NeuroBotPrompt extends StatelessWidget {
  const _NeuroBotPrompt();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.spaceMd),
        child: Row(
          children: [
            Icon(
              Icons.smart_toy_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: AppDimens.spaceMd),
            Expanded(
              child: Text(
                'Bugün nasılsın bakalım?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmotionSelector extends ConsumerWidget {
  const _EmotionSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final definitionsAsync = ref.watch(emotionDefinitionsProvider);
    final recordsAsync = ref.watch(emotionRecordsProvider);
    final todayKey = EmotionRecordRepository.dateKey(DateTime.now());

    return definitionsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (definitions) {
        if (definitions.isEmpty) {
          return const Text('Duygu listesi şu anda kullanılamıyor.');
        }
        final selectedId = recordsAsync.valueOrNull?[todayKey];
        return Wrap(
          spacing: AppDimens.spaceSm,
          runSpacing: AppDimens.spaceSm,
          children: definitions.map((emotion) {
            final isSelected = emotion.id == selectedId;
            return GestureDetector(
              onTap: () => ref
                  .read(emotionRecordsProvider.notifier)
                  .recordToday(emotion.id),
              child: Container(
                padding: const EdgeInsets.all(AppDimens.spaceSm),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Text(emotion.emoji, style: const TextStyle(fontSize: 28)),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _WeeklyEmotionCalendar extends ConsumerWidget {
  const _WeeklyEmotionCalendar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final definitionsAsync = ref.watch(emotionDefinitionsProvider);
    final recordsAsync = ref.watch(emotionRecordsProvider);
    final dates = weekDates(DateTime.now());
    final records = recordsAsync.valueOrNull ?? {};
    final definitions = definitionsAsync.valueOrNull ?? [];

    String emojiFor(String? emotionId) {
      if (emotionId == null) return '–';
      for (final d in definitions) {
        if (d.id == emotionId) return d.emoji;
      }
      return '–';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Haftalık Duygu Takvimi', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppDimens.spaceSm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            final date = dates[i];
            final key = EmotionRecordRepository.dateKey(date);
            return Column(
              children: [
                Text(_weekdayLabelsTr[i], style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(emojiFor(records[key]), style: const TextStyle(fontSize: 18)),
              ],
            );
          }),
        ),
      ],
    );
  }
}

class _TodayGoals extends ConsumerWidget {
  const _TodayGoals();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(emotionRecordsProvider);
    final todayKey = EmotionRecordRepository.dateKey(DateTime.now());
    final emotionDone = recordsAsync.valueOrNull?[todayKey] != null;

    final completionsAsync = ref.watch(exerciseCompletionsProvider);
    final exerciseDone =
        completionsAsync.valueOrNull?.any(
          (c) => dateKey(c.date) == todayKey,
        ) ??
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
            // Mini oyun tamamlama takibi Faz 7'de eklenecek.
            const _GoalRow(label: 'Mini oyun oyna', done: false),
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

class _WeeklyProgress extends ConsumerWidget {
  const _WeeklyProgress();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(emotionRecordsProvider);
    final records = recordsAsync.valueOrNull ?? {};
    final dates = weekDates(DateTime.now());
    final daysWithEmotion = dates
        .where((date) => records.containsKey(EmotionRecordRepository.dateKey(date)))
        .length;

    return Text(
      'Bu hafta $daysWithEmotion/7 gün duygu kaydedildi.',
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}
