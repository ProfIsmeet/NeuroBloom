import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neurobloom/core/constants/storage_keys.dart';
import 'package:neurobloom/features/onboarding/application/profile_providers.dart';
import 'package:neurobloom/features/onboarding/domain/user_profile.dart';
import 'package:neurobloom/main.dart';

import 'support/fake_storage_service.dart';

void main() {
  testWidgets('No saved profile: splash routes into onboarding greeting', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(FakeStorageService()),
        ],
        child: const NeuroBloomApp(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Merhaba! Ben NeuroBot 🌱'), findsOneWidget);
  });

  testWidgets(
    'Existing completed profile: splash skips onboarding and goes home',
    (WidgetTester tester) async {
      final storage = FakeStorageService();
      final profile = UserProfile(
        name: 'Ada',
        age: 7,
        gender: 'Kız',
        avatarId: 2,
        createdAt: DateTime(2026, 1, 1),
        onboardingCompleted: true,
      );
      storage.seedRaw(
        StorageKeys.userProfile,
        jsonEncode(profile.toJson()),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [storageServiceProvider.overrideWithValue(storage)],
          child: const NeuroBloomApp(),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.text('Merhaba, Ada!'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    },
  );

  testWidgets('Tapping each bottom nav destination does not crash', (
    WidgetTester tester,
  ) async {
    final storage = FakeStorageService();
    final profile = UserProfile(
      name: 'Ada',
      age: 7,
      gender: 'Kız',
      avatarId: 2,
      createdAt: DateTime(2026, 1, 1),
      onboardingCompleted: true,
    );
    storage.seedRaw(StorageKeys.userProfile, jsonEncode(profile.toJson()));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [storageServiceProvider.overrideWithValue(storage)],
        child: const NeuroBloomApp(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    for (final label in [
      'Egzersizler',
      'Oyunlar',
      'NeuroBot',
      'İlerleme',
      'Premium',
      'Ana Sayfa',
    ]) {
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
