class ExerciseCompletion {
  const ExerciseCompletion({required this.exerciseId, required this.date});

  final String exerciseId;
  final DateTime date;

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'date': date.toIso8601String(),
  };

  static ExerciseCompletion? tryParse(dynamic json) {
    if (json is! Map) return null;
    final exerciseId = json['exerciseId'];
    final dateStr = json['date'];
    if (exerciseId is! String || dateStr is! String) return null;
    final date = DateTime.tryParse(dateStr);
    if (date == null) return null;
    return ExerciseCompletion(exerciseId: exerciseId, date: date);
  }
}
