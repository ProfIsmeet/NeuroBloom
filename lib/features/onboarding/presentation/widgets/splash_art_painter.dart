import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Draws a blooming flower that morphs into a speech bubble, driven by a
/// single 0..1 animation value (t):
///   0.00 - 0.45  flower bloom (petals scale in)
///   0.45 - 0.75  crossfade flower -> speech bubble
///   0.75 - 1.00  speech bubble fully settled
class SplashArtPainter extends CustomPainter {
  SplashArtPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final bloom = Curves.easeOutBack.transform((t / 0.45).clamp(0.0, 1.0));
    final morph = ((t - 0.45) / 0.3).clamp(0.0, 1.0);

    if (morph < 1.0) {
      _paintFlower(canvas, center, size.width * 0.4 * bloom, 1 - morph);
    }
    if (morph > 0.0) {
      _paintSpeechBubble(canvas, center, size.width * 0.42, morph);
    }
  }

  void _paintFlower(
    Canvas canvas,
    Offset center,
    double radius,
    double opacity,
  ) {
    if (radius <= 0 || opacity <= 0) return;
    final petalPaint = Paint()
      ..color = AppColors.accentPurple.withValues(alpha: 0.85 * opacity);
    const petalCount = 6;
    for (var i = 0; i < petalCount; i++) {
      final angle = (2 * math.pi / petalCount) * i;
      final petalCenter = Offset(
        center.dx + radius * 0.55 * math.cos(angle),
        center.dy + radius * 0.55 * math.sin(angle),
      );
      canvas.drawCircle(petalCenter, radius * 0.4, petalPaint);
    }
    canvas.drawCircle(
      center,
      radius * 0.45,
      Paint()..color = AppColors.accentAmber.withValues(alpha: opacity),
    );
  }

  void _paintSpeechBubble(
    Canvas canvas,
    Offset center,
    double radius,
    double opacity,
  ) {
    final rect = Rect.fromCenter(
      center: center.translate(0, -radius * 0.1),
      width: radius * 1.9,
      height: radius * 1.3,
    );
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(radius * 0.4),
    );
    final paint = Paint()
      ..color = AppColors.accentBlue.withValues(alpha: opacity);
    canvas.drawRRect(rrect, paint);

    final tail = Path()
      ..moveTo(center.dx - radius * 0.15, rect.bottom - 2)
      ..lineTo(center.dx, rect.bottom + radius * 0.35)
      ..lineTo(center.dx + radius * 0.15, rect.bottom - 2)
      ..close();
    canvas.drawPath(tail, paint);
  }

  @override
  bool shouldRepaint(covariant SplashArtPainter oldDelegate) =>
      oldDelegate.t != t;
}
