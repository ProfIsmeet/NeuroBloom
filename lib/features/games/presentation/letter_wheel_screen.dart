import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/badges/badge_icon.dart';
import '../../../core/badges/badge_providers.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/success_celebration.dart';
import '../application/letter_wheel_controller.dart';
import '../domain/letter_wheel_state.dart';

class LetterWheelScreen extends ConsumerWidget {
  const LetterWheelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(letterWheelControllerProvider);
    final controller = ref.read(letterWheelControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Harf Çarkı')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.spaceLg),
          child: Center(
            child: switch (state.phase) {
              LetterWheelPhase.completed => _CompletedView(state: state),
              _ => _PlayView(state: state, controller: controller),
            },
          ),
        ),
      ),
    );
  }
}

class _PlayView extends StatelessWidget {
  const _PlayView({required this.state, required this.controller});

  final LetterWheelState state;
  final LetterWheelController controller;

  @override
  Widget build(BuildContext context) {
    final item = state.currentItem;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('🎡', style: const TextStyle(fontSize: 96)),
        const SizedBox(height: AppDimens.spaceLg),
        if (item != null) ...[
          Text(item.syllable, style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: AppDimens.spaceSm),
          Text(item.prompt, textAlign: TextAlign.center),
          const SizedBox(height: AppDimens.spaceLg),
        ],
        if (state.phase == LetterWheelPhase.idle ||
            state.phase == LetterWheelPhase.spinning)
          ElevatedButton(
            onPressed: state.phase == LetterWheelPhase.spinning
                ? null
                : controller.spin,
            child: const Text('DÖNDÜR'),
          ),
        if (state.phase == LetterWheelPhase.ready ||
            state.phase == LetterWheelPhase.recording ||
            state.phase == LetterWheelPhase.recorded)
          _RecordingControls(state: state, controller: controller),
      ],
    );
  }
}

class _RecordingControls extends StatelessWidget {
  const _RecordingControls({required this.state, required this.controller});

  final LetterWheelState state;
  final LetterWheelController controller;

  @override
  Widget build(BuildContext context) {
    if (state.permissionDenied) {
      return Column(
        children: [
          const Text(
            'Mikrofon izni verilmedi. Kayıt yapmadan devam edebilirsin.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimens.spaceMd),
          ElevatedButton(
            onPressed: controller.finish,
            child: const Text('Bitir'),
          ),
        ],
      );
    }

    return switch (state.phase) {
      LetterWheelPhase.ready => Column(
        children: [
          ElevatedButton(
            onPressed: controller.startRecording,
            child: const Text('KAYDET'),
          ),
          const SizedBox(height: AppDimens.spaceSm),
          TextButton(onPressed: controller.finish, child: const Text('Bitir')),
        ],
      ),
      LetterWheelPhase.recording => Column(
        children: [
          Icon(
            Icons.mic_rounded,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: AppDimens.spaceSm),
          ElevatedButton(
            onPressed: controller.stopRecording,
            child: const Text('DURDUR'),
          ),
        ],
      ),
      LetterWheelPhase.recorded => Column(
        children: [
          ElevatedButton(
            onPressed: controller.playRecording,
            child: const Text('DİNLE'),
          ),
          const SizedBox(height: AppDimens.spaceSm),
          OutlinedButton(
            onPressed: controller.reRecord,
            child: const Text('TEKRAR KAYDET'),
          ),
          const SizedBox(height: AppDimens.spaceSm),
          TextButton(onPressed: controller.finish, child: const Text('Bitir')),
        ],
      ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _CompletedView extends ConsumerWidget {
  const _CompletedView({required this.state});

  final LetterWheelState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allBadges = ref.watch(allBadgesProvider).valueOrNull ?? [];
    final unlockedBadges = allBadges
        .where((b) => state.newlyUnlockedBadgeIds.contains(b.id))
        .toList();

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SuccessCelebration(),
          Text('Harika!', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppDimens.spaceSm),
          const Text('+30 XP'),
          if (unlockedBadges.isNotEmpty) ...[
            const SizedBox(height: AppDimens.spaceLg),
            Text('Yeni Rozet!', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppDimens.spaceSm),
            Wrap(
              spacing: AppDimens.spaceMd,
              alignment: WrapAlignment.center,
              children: unlockedBadges.map((badge) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      badgeIconFor(badge.icon),
                      color: Theme.of(context).colorScheme.secondary,
                      size: 36,
                    ),
                    Text(badge.title, textAlign: TextAlign.center),
                  ],
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: AppDimens.spaceLg),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Listeye Dön'),
          ),
        ],
      ),
    );
  }
}
