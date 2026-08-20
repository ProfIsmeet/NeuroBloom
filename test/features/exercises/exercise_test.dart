import 'package:flutter_test/flutter_test.dart';
import 'package:neurobloom/features/exercises/application/exercise_providers.dart';
import 'package:neurobloom/features/exercises/domain/exercise.dart';

Map<String, dynamic> _validJson({
  String id = 'tongue_out',
  String category = 'tongue',
  bool enabled = true,
  int ageMin = 3,
  int ageMax = 13,
}) {
  return {
    'id': id,
    'category': category,
    'title': 'Dilini Dışarı Çıkar',
    'description': 'desc',
    'instruction': 'instr',
    'duration': 5,
    'repetitions': 5,
    'tts': 'tts',
    'animation': 'tongue_out',
    'xp': 20,
    'difficulty': 'easy',
    'ageRange': {'min': ageMin, 'max': ageMax},
    'enabled': enabled,
  };
}

void main() {
  group('Exercise.tryParse', () {
    test('parses a valid exercise', () {
      final exercise = Exercise.tryParse(_validJson());
      expect(exercise, isNotNull);
      expect(exercise!.id, 'tongue_out');
      expect(exercise.category, 'tongue');
      expect(exercise.ageMin, 3);
      expect(exercise.ageMax, 13);
      expect(exercise.enabled, isTrue);
    });

    test('returns null for a non-map entry (invalid JSON shape)', () {
      expect(Exercise.tryParse('not an object'), isNull);
      expect(Exercise.tryParse(42), isNull);
      expect(Exercise.tryParse(null), isNull);
    });

    test('returns null when a required field is missing', () {
      final json = _validJson()..remove('title');
      expect(Exercise.tryParse(json), isNull);
    });

    test('returns null when a field has the wrong type', () {
      final json = _validJson();
      json['duration'] = 'five'; // should be int
      expect(Exercise.tryParse(json), isNull);
    });

    test('returns null when ageRange is missing or malformed', () {
      final json = _validJson();
      json.remove('ageRange');
      expect(Exercise.tryParse(json), isNull);

      final json2 = _validJson();
      json2['ageRange'] = {'min': 3}; // missing max
      expect(Exercise.tryParse(json2), isNull);
    });
  });

  group('visibleExercises', () {
    final exercises = [
      Exercise.tryParse(_validJson(id: 'a', enabled: true, ageMin: 3, ageMax: 13))!,
      Exercise.tryParse(_validJson(id: 'b', enabled: false, ageMin: 3, ageMax: 13))!,
      Exercise.tryParse(_validJson(id: 'c', enabled: true, ageMin: 8, ageMax: 13))!,
      Exercise.tryParse(_validJson(id: 'd', category: 'lips', enabled: true, ageMin: 3, ageMax: 13))!,
    ];

    test('enabled filtering hides disabled exercises', () {
      final visible = visibleExercises(exercises, age: 10);
      expect(visible.any((e) => e.id == 'b'), isFalse);
    });

    test('age filtering excludes exercises outside the age range', () {
      final tooYoung = visibleExercises(exercises, age: 5);
      expect(tooYoung.any((e) => e.id == 'c'), isFalse);

      final oldEnough = visibleExercises(exercises, age: 9);
      expect(oldEnough.any((e) => e.id == 'c'), isTrue);
    });

    test('category filtering: exercises retain their own category', () {
      final visible = visibleExercises(exercises, age: 10);
      final tongueCount = visible.where((e) => e.category == 'tongue').length;
      final lipsCount = visible.where((e) => e.category == 'lips').length;
      expect(tongueCount, 2); // a and c
      expect(lipsCount, 1); // d
    });
  });
}
