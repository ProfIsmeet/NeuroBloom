import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Short calm success animation: a scaling star plus a few confetti bits.
/// When the platform requests reduced motion, everything renders in its
/// final resting state instantly instead of animating.
class SuccessCelebration extends StatefulWidget {
  const SuccessCelebration({super.key});

  @override
  State<SuccessCelebration> createState() => _SuccessCelebrationState();
}

class _SuccessCelebrationState extends State<SuccessCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    final reduceMotion =
        WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations;
    if (reduceMotion) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final color = Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (!reduceMotion)
                CustomPaint(
                  size: const Size(140, 140),
                  painter: _ConfettiPainter(progress: t, color: color),
                ),
              Transform.scale(
                scale: reduceMotion ? 1 : Curves.elasticOut.transform(t),
                child: Icon(Icons.star_rounded, size: 72, color: color),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  static const _particleCount = 8;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()..color = color.withValues(alpha: 1 - progress);

    for (var i = 0; i < _particleCount; i++) {
      final angle = (2 * math.pi / _particleCount) * i;
      final distance = 55 * progress;
      final offset = center + Offset(math.cos(angle), math.sin(angle)) * distance;
      canvas.drawCircle(offset, 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
