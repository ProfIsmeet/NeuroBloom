class LetterWheelItem {
  const LetterWheelItem({
    required this.id,
    required this.syllable,
    required this.prompt,
  });

  final String id;
  final String syllable;
  final String prompt;

  /// Returns null (never throws) on any malformed entry, so one bad JSON
  /// object skips that syllable instead of breaking the whole wheel.
  static LetterWheelItem? tryParse(dynamic json) {
    if (json is! Map) return null;
    final id = json['id'];
    final syllable = json['syllable'];
    final prompt = json['prompt'];
    if (id is! String || id.isEmpty) return null;
    if (syllable is! String || syllable.isEmpty) return null;
    if (prompt is! String || prompt.isEmpty) return null;
    return LetterWheelItem(id: id, syllable: syllable, prompt: prompt);
  }
}
