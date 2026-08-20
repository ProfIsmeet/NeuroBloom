import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neurobloom/features/premium/presentation/premium_screen.dart';

void main() {
  testWidgets('renders the feature list and a disabled action button', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: PremiumScreen()),
    );

    expect(find.text('✨ NeuroBloom Premium'), findsOneWidget);
    expect(find.text('Yakında Kullanıma Açılacak'), findsOneWidget);
    expect(find.text('Daha fazla oyun'), findsOneWidget);
    expect(find.text('Gelişmiş ebeveyn özellikleri'), findsOneWidget);

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull, reason: 'no real payment/subscription action');

    // Tapping a disabled button must be a safe no-op.
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
