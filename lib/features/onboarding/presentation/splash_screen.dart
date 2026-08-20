import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../application/profile_providers.dart';
import 'widgets/splash_art_painter.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  static const Duration duration = Duration(milliseconds: 1800);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final reduceMotion = WidgetsBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations;

    _controller = AnimationController(
      vsync: this,
      duration: reduceMotion
          ? const Duration(milliseconds: 1)
          : SplashScreen.duration,
    )..forward();

    _navigateWhenReady();
  }

  Future<void> _navigateWhenReady() async {
    final profileFuture = ref.read(profileControllerProvider.future);
    await _controller.forward();
    final profile = await profileFuture;
    if (!mounted) return;
    final destination = (profile?.onboardingCompleted ?? false)
        ? '/home'
        : '/onboarding';
    context.go(destination);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            final textOpacity = ((t - 0.6) / 0.4).clamp(0.0, 1.0);
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CustomPaint(painter: SplashArtPainter(t)),
                ),
                const SizedBox(height: 24),
                Opacity(
                  opacity: textOpacity,
                  child: Column(
                    children: [
                      Text(
                        'NeuroBloom',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Konuşmayı birlikte güçlendirelim.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
