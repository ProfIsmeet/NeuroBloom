class EmotionDefinition {
  const EmotionDefinition({
    required this.id,
    required this.emoji,
    required this.label,
  });

  final String id;
  final String emoji;
  final String label;

  /// Returns null (never throws) if the entry is missing a required field
  /// or has the wrong type, so one bad entry doesn't break the whole list.
  static EmotionDefinition? tryParse(dynamic json) {
    if (json is! Map) return null;
    final id = json['id'];
    final emoji = json['emoji'];
    final label = json['label'];
    if (id is! String || emoji is! String || label is! String) return null;
    if (id.isEmpty) return null;
    return EmotionDefinition(id: id, emoji: emoji, label: label);
  }
}
