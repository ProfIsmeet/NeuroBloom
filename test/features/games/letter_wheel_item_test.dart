import 'package:flutter_test/flutter_test.dart';
import 'package:neurobloom/features/games/domain/letter_wheel_item.dart';

void main() {
  group('LetterWheelItem.tryParse', () {
    test('parses a valid entry', () {
      final item = LetterWheelItem.tryParse({
        'id': 'ma',
        'syllable': 'MA',
        'prompt': 'MA sesiyle bir kelime söyle.',
      });
      expect(item, isNotNull);
      expect(item!.syllable, 'MA');
    });

    test('non-map input returns null instead of throwing', () {
      expect(LetterWheelItem.tryParse('not a map'), isNull);
      expect(LetterWheelItem.tryParse(null), isNull);
    });

    test('missing field returns null', () {
      expect(LetterWheelItem.tryParse({'id': 'ma', 'syllable': 'MA'}), isNull);
    });

    test('wrong field type returns null', () {
      expect(
        LetterWheelItem.tryParse({'id': 1, 'syllable': 'MA', 'prompt': 'p'}),
        isNull,
      );
    });

    test('empty id returns null', () {
      expect(
        LetterWheelItem.tryParse({'id': '', 'syllable': 'MA', 'prompt': 'p'}),
        isNull,
      );
    });
  });
}
