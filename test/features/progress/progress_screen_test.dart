import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neurobloom/features/onboarding/application/profile_providers.dart';
import 'package:neurobloom/features/progress/presentation/progress_screen.dart';

import '../../support/fake_storage_service.dart';

void main() {
  testWidgets(
    'renders stats computed from real seeded data, not mock/hardcoded values',
    (tester) async {
      final storage = FakeStorageService();
      storage.seedRaw(
        'xp_events',
        jsonEncode([
          {
            'activityType': 'exercise',
            'sourceId': 'tongue_out',
            'date': '2026-03-01',
            'amount': 20,
          },
          {
            'activityType': 'emotion',
            'sourceId': 'daily',
            'date': '2026-03-01',
            'amount': 5,
          },
        ]),
      );
      storage.seedRaw(
        'exercise_completions',
        jsonEncode([
          {'exerciseId': 'tongue_out', 'date': '2026-03-01T10:00:00.000'},
        ]),
      );
      storage.seedRaw(
        'game_completions',
        jsonEncode([
          {'gameId': 'letter_wheel', 'date': '2026-03-01T10:00:00.000'},
        ]),
      );
      storage.seedRaw('emotion_records', jsonEncode({'2026-03-01': 'happy'}));

      // Matches the physical test device's width (720 logical px) — the
      // default wider test surface hid a real stat-card overflow that
      // only appeared at phone width.
      tester.view.physicalSize = const Size(720, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [storageServiceProvider.overrideWithValue(storage)],
          child: const MaterialApp(home: ProgressScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // Total XP is the sum of seeded events (25), not a hardcoded number.
      expect(find.text('⭐ 25'), findsOneWidget);
      // Exactly one exercise and one game completion were seeded.
      expect(find.text('🧘 1'), findsOneWidget);
      expect(find.text('🎮 1'), findsOneWidget);

      // History sections are further down the ListView, off the default
      // test-surface viewport.
      await tester.dragUntilVisible(
        find.text('Egzersiz +20 XP'),
        find.byType(ListView),
        const Offset(0, -300),
      );
      expect(find.text('Egzersiz +20 XP'), findsOneWidget);
      expect(find.text('Duygu +5 XP'), findsOneWidget);
    },
  );

  testWidgets('shows friendly empty state with no recorded activity', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(FakeStorageService()),
        ],
        child: const MaterialApp(home: ProgressScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('⭐ 0'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Henüz duygu kaydedilmedi.'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    expect(find.text('Henüz egzersiz tamamlanmadı.'), findsOneWidget);
    expect(find.text('Henüz XP kazanılmadı.'), findsOneWidget);
    expect(find.text('Henüz duygu kaydedilmedi.'), findsOneWidget);
  });
}
