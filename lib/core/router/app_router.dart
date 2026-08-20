import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/assistant/presentation/assistant_screen.dart';
import '../../features/exercises/presentation/exercise_runner_screen.dart';
import '../../features/exercises/presentation/exercises_screen.dart';
import '../../features/games/presentation/games_screen.dart';
import '../../features/games/presentation/letter_wheel_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/parent/presentation/parent_dashboard_screen.dart';
import '../../features/parent/presentation/parent_pin_screen.dart';
import '../../features/premium/presentation/premium_screen.dart';
import '../../features/progress/presentation/progress_screen.dart';
import '../security/parent_pin_providers.dart';
import '../widgets/app_shell.dart';

abstract final class AppRouter {
  /// Builds a fresh router. Must not be memoized as a static singleton:
  /// GoRouter carries live navigation state, so a shared instance would
  /// leak the current location across separate app instances (e.g. tests).
  /// [ref] is used only to guard '/parent/dashboard' — the child screen
  /// can never reach it without a correct PIN, even via deep link.
  static GoRouter createRouter(WidgetRef ref) => GoRouter(
    navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'root'),
    initialLocation: '/splash',
    redirect: (context, state) {
      final goingToDashboard = state.matchedLocation == '/parent/dashboard';
      final unlocked = ref.read(parentUnlockedProvider);
      if (goingToDashboard && !unlocked) return '/parent';
      return null;
    },
    routes: [
      GoRoute(path: '/parent', builder: (context, state) => const ParentPinScreen()),
      GoRoute(
        path: '/parent/dashboard',
        builder: (context, state) => const ParentDashboardScreen(),
      ),
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/exercises',
                builder: (context, state) => const ExercisesScreen(),
                routes: [
                  GoRoute(
                    path: 'run/:id',
                    builder: (context, state) => ExerciseRunnerScreen(
                      exerciseId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/games',
                builder: (context, state) => const GamesScreen(),
                routes: [
                  GoRoute(
                    path: 'letter-wheel',
                    builder: (context, state) => const LetterWheelScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/assistant',
                builder: (context, state) => const AssistantScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/progress',
                builder: (context, state) => const ProgressScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/premium',
                builder: (context, state) => const PremiumScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
