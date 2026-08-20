import 'package:flutter/material.dart';

import '../../../core/theme/app_dimens.dart';

const List<({String emoji, String label})> _upcomingFeatures = [
  (emoji: '🎮', label: 'Daha fazla oyun'),
  (emoji: '👄', label: 'Daha fazla egzersiz'),
  (emoji: '📊', label: 'Detaylı gelişim raporları'),
  (emoji: '🎨', label: 'Özel avatarlar'),
  (emoji: '👨‍👩‍👧', label: 'Gelişmiş ebeveyn özellikleri'),
];

/// Static preview of the future Premium tier. No payment SDK, no
/// subscription request, no network call — every action here is a
/// disabled no-op by design (Faz 10 gate: "hiçbir ödeme/abonelik isteği
/// oluşturmuyor").
class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.spaceLg),
          children: [
            Text(
              '✨ NeuroBloom Premium',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppDimens.spaceSm),
            Text(
              'Daha fazla oyun, egzersiz ve gelişim özelliği yakında!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppDimens.spaceXl),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.spaceMd),
                child: Column(
                  children: [
                    for (final feature in _upcomingFeatures)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimens.spaceSm,
                        ),
                        child: Row(
                          children: [
                            Text(feature.emoji, style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: AppDimens.spaceMd),
                            Expanded(child: Text(feature.label)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimens.spaceXl),
            SizedBox(
              height: AppDimens.buttonHeight,
              child: ElevatedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.lock_rounded),
                label: const Text('Yakında Kullanıma Açılacak'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
