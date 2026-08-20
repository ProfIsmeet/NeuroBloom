import 'package:flutter/material.dart';

/// Elegant fallback illustration shown when no Lottie/SVG asset exists for
/// an exercise's `animation` id. Dropping a real animation file into
/// assets/animations/ later can replace this with zero risk of a missing
/// asset ever crashing the app, since this widget never touches the
/// filesystem — it only reads the category string.
class ExerciseAnimationFallback extends StatefulWidget {
  const ExerciseAnimationFallback({super.key, required this.category});

  final String category;

  @override
  State<ExerciseAnimationFallback> createState() =>
      _ExerciseAnimationFallbackState();
}

class _ExerciseAnimationFallbackState extends State<ExerciseAnimationFallback>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const Map<String, IconData> _icons = {
    'tongue': Icons.face_retouching_natural_rounded,
    'lips': Icons.emoji_emotions_rounded,
    'speech': Icons.record_voice_over_rounded,
  };

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
      duration: const Duration(milliseconds: 1200),
    );
    if (!reduceMotion) {
      _controller.repeat(reverse: true);
    } else {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = _icons[widget.category] ?? Icons.emoji_emotions_rounded;
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.9,
        end: 1.05,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
        ),
        child: Icon(
          icon,
          size: 72,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
