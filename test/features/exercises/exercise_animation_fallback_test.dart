import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neurobloom/features/exercises/presentation/widgets/exercise_animation_fallback.dart';

void main() {
  testWidgets('renders without crashing for a known category', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ExerciseAnimationFallback(category: 'tongue')),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'renders without crashing for an unknown/missing category (no matching asset)',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExerciseAnimationFallback(category: 'does_not_exist'),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
      expect(find.byType(Icon), findsOneWidget);
    },
  );
}
