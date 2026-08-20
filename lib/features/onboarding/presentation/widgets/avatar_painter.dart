import 'package:flutter/material.dart';

/// 8 original, gender-neutral avatar illustrations, drawn with CustomPainter
/// (no external asset files, so there is no missing-asset failure mode).
/// avatarId in [0, 7] selects a skin-tone / hairstyle combination.
class AvatarWidget extends StatelessWidget {
  const AvatarWidget({super.key, required this.avatarId, this.size = 72});

  final int avatarId;
  final double size;

  @override
  Widget build(BuildContext context) {
    final safeId = avatarId.clamp(0, 7);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _AvatarPainter(safeId)),
    );
  }
}

class _AvatarPainter extends CustomPainter {
  _AvatarPainter(this.avatarId);

  final int avatarId;

  static const List<Color> _skinTones = [
    Color(0xFFFFE0BD),
    Color(0xFFF1C27D),
    Color(0xFFC68642),
    Color(0xFF8D5524),
  ];

  static const List<Color> _hairColors = [
    Color(0xFF3B2A20),
    Color(0xFFB05A2C),
    Color(0xFF1F1F1F),
    Color(0xFFE8C56B),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final skinTone = _skinTones[avatarId % _skinTones.length];
    final hairColor = _hairColors[avatarId % _hairColors.length];
    final hairStyle = avatarId % 2; // 0 = short/round, 1 = pigtails/spiky
    final center = Offset(size.width / 2, size.height / 2);
    final faceRadius = size.width * 0.36;

    // Background circle
    canvas.drawCircle(
      center,
      size.width / 2,
      Paint()..color = skinTone.withValues(alpha: 0.15),
    );

    // Face
    canvas.drawCircle(center, faceRadius, Paint()..color = skinTone);

    // Hair
    final hairPaint = Paint()..color = hairColor;
    if (hairStyle == 0) {
      canvas.drawArc(
        Rect.fromCircle(
          center: center.translate(0, -faceRadius * 0.15),
          radius: faceRadius * 1.05,
        ),
        3.4,
        2.7,
        true,
        hairPaint,
      );
    } else {
      canvas.drawArc(
        Rect.fromCircle(
          center: center.translate(0, -faceRadius * 0.2),
          radius: faceRadius * 1.05,
        ),
        3.3,
        2.9,
        true,
        hairPaint,
      );
      final tailRadius = faceRadius * 0.22;
      canvas.drawCircle(
        center.translate(-faceRadius * 0.95, faceRadius * 0.1),
        tailRadius,
        hairPaint,
      );
      canvas.drawCircle(
        center.translate(faceRadius * 0.95, faceRadius * 0.1),
        tailRadius,
        hairPaint,
      );
    }

    // Eyes
    final eyePaint = Paint()..color = const Color(0xFF2B2B3A);
    final eyeOffsetX = faceRadius * 0.38;
    final eyeOffsetY = -faceRadius * 0.05;
    canvas.drawCircle(
      center.translate(-eyeOffsetX, eyeOffsetY),
      faceRadius * 0.08,
      eyePaint,
    );
    canvas.drawCircle(
      center.translate(eyeOffsetX, eyeOffsetY),
      faceRadius * 0.08,
      eyePaint,
    );

    // Smile
    final smileRect = Rect.fromCenter(
      center: center.translate(0, faceRadius * 0.25),
      width: faceRadius * 0.9,
      height: faceRadius * 0.6,
    );
    canvas.drawArc(
      smileRect,
      0.25,
      2.6,
      false,
      Paint()
        ..color = const Color(0xFF2B2B3A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _AvatarPainter oldDelegate) {
    return oldDelegate.avatarId != avatarId;
  }
}
