import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:neurobloom/core/router/app_router.dart';
import 'package:neurobloom/core/security/parent_pin_providers.dart';
import 'package:neurobloom/features/onboarding/application/profile_providers.dart';
import 'package:neurobloom/features/parent/presentation/parent_dashboard_screen.dart';
import 'package:neurobloom/features/parent/presentation/parent_pin_screen.dart';

import '../../support/fake_secure_credential_store.dart';
import '../../support/fake_storage_service.dart';

class _TestApp extends ConsumerStatefulWidget {
  const _TestApp({super.key});

  @override
  ConsumerState<_TestApp> createState() => _TestAppState();
}

class _TestAppState extends ConsumerState<_TestApp> {
  late final GoRouter router = AppRouter.createRouter(ref);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: router);
  }
}

/// Taps each digit's on-screen keypad button in turn, exactly as a real
/// parent would (no OS soft keyboard involved).
Future<void> _tapPin(WidgetTester tester, String pin) async {
  for (final digit in pin.split('')) {
    await tester.tap(find.text(digit));
    await tester.pump();
  }
}

void main() {
  testWidgets(
    'the dashboard route redirects to the PIN screen when locked, even via direct navigation',
    (tester) async {
      final key = GlobalKey<_TestAppState>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageServiceProvider.overrideWithValue(FakeStorageService()),
            secureCredentialStoreProvider.overrideWithValue(
              FakeSecureCredentialStore(),
            ),
          ],
          child: _TestApp(key: key),
        ),
      );
      await tester.pumpAndSettle();

      key.currentState!.router.go('/parent/dashboard');
      await tester.pumpAndSettle();

      expect(find.byType(ParentDashboardScreen), findsNothing);
      expect(find.byType(ParentPinScreen), findsOneWidget);
    },
  );

  testWidgets(
    'creating a PIN unlocks the dashboard, which shows real seeded stats',
    (tester) async {
      final storage = FakeStorageService();
      storage.seedRaw(
        'xp_events',
        jsonEncode([
          {
            'activityType': 'exercise',
            'sourceId': 'ex1',
            'date': '2026-03-01',
            'amount': 20,
          },
        ]),
      );
      storage.seedRaw(
        'exercise_completions',
        jsonEncode([
          {'exerciseId': 'ex1', 'date': '2026-03-01T10:00:00.000'},
        ]),
      );

      final key = GlobalKey<_TestAppState>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageServiceProvider.overrideWithValue(storage),
            secureCredentialStoreProvider.overrideWithValue(
              FakeSecureCredentialStore(),
            ),
          ],
          child: _TestApp(key: key),
        ),
      );
      await tester.pumpAndSettle();

      key.currentState!.router.go('/parent');
      await tester.pumpAndSettle();

      // First-time flow: create the PIN, then confirm it.
      await _tapPin(tester, '1234');
      await tester.pump();
      expect(find.text('PIN\'i tekrar gir'), findsOneWidget);

      await _tapPin(tester, '1234');
      await tester.pumpAndSettle();

      expect(find.byType(ParentDashboardScreen), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('stat_totalXp')),
          matching: find.text('20'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('stat_exerciseCount')),
          matching: find.text('1'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('a wrong PIN on an existing PIN is rejected', (tester) async {
    final secureStore = FakeSecureCredentialStore();
    final key = GlobalKey<_TestAppState>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(FakeStorageService()),
          secureCredentialStoreProvider.overrideWithValue(secureStore),
        ],
        child: _TestApp(key: key),
      ),
    );
    await tester.pumpAndSettle();

    // Pre-create a PIN directly through the repository the screen will use.
    final container = ProviderScope.containerOf(
      key.currentContext!,
      listen: false,
    );
    await container.read(parentPinRepositoryProvider).createPin('1234');

    key.currentState!.router.go('/parent');
    await tester.pumpAndSettle();

    await _tapPin(tester, '9999');
    await tester.pumpAndSettle();

    expect(find.text('Yanlış PIN.'), findsOneWidget);
    expect(find.byType(ParentDashboardScreen), findsNothing);
  });

  testWidgets(
    'after a wrong PIN, the keypad still accepts a correct retry without any extra tap',
    (tester) async {
      final secureStore = FakeSecureCredentialStore();
      final key = GlobalKey<_TestAppState>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageServiceProvider.overrideWithValue(FakeStorageService()),
            secureCredentialStoreProvider.overrideWithValue(secureStore),
          ],
          child: _TestApp(key: key),
        ),
      );
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        key.currentContext!,
        listen: false,
      );
      await container.read(parentPinRepositoryProvider).createPin('1234');

      key.currentState!.router.go('/parent');
      await tester.pumpAndSettle();

      await _tapPin(tester, '9999');
      await tester.pumpAndSettle();
      expect(find.text('Yanlış PIN.'), findsOneWidget);

      // Immediately retry with the correct PIN — no keypad is ever
      // "disconnected" the way a hidden-TextField's IME could be, so
      // this must work with the exact same tap sequence as any attempt.
      await _tapPin(tester, '1234');
      await tester.pumpAndSettle();

      expect(find.byType(ParentDashboardScreen), findsOneWidget);
    },
  );
}
