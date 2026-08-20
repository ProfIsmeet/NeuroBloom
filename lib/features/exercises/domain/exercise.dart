class Exercise {
  const Exercise({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.instruction,
    required this.duration,
    required this.repetitions,
    required this.tts,
    required this.animation,
    required this.xp,
    required this.difficulty,
    required this.ageMin,
    required this.ageMax,
    required this.enabled,
  });

  final String id;
  final String category;
  final String title;
  final String description;
  final String instruction;
  final int duration;
  final int repetitions;
  final String tts;
  final String animation;
  final int xp;
  final String difficulty;
  final int ageMin;
  final int ageMax;
  final bool enabled;

  bool isVisibleForAge(int age) => enabled && age >= ageMin && age <= ageMax;

  /// Returns null (never throws) when the entry is malformed, so one bad
  /// JSON object skips that entry instead of breaking the whole category.
  static Exercise? tryParse(dynamic json) {
    if (json is! Map) return null;
    final ageRange = json['ageRange'];
    if (ageRange is! Map) return null;

    final id = json['id'];
    final category = json['category'];
    final title = json['title'];
    final description = json['description'];
    final instruction = json['instruction'];
    final duration = json['duration'];
    final repetitions = json['repetitions'];
    final tts = json['tts'];
    final animation = json['animation'];
    final xp = json['xp'];
    final difficulty = json['difficulty'];
    final ageMin = ageRange['min'];
    final ageMax = ageRange['max'];
    final enabled = json['enabled'];

    if (id is! String || id.isEmpty) return null;
    if (category is! String) return null;
    if (title is! String) return null;
    if (description is! String) return null;
    if (instruction is! String) return null;
    if (duration is! int) return null;
    if (repetitions is! int) return null;
    if (tts is! String) return null;
    if (animation is! String) return null;
    if (xp is! int) return null;
    if (difficulty is! String) return null;
    if (ageMin is! int) return null;
    if (ageMax is! int) return null;
    if (enabled is! bool) return null;

    return Exercise(
      id: id,
      category: category,
      title: title,
      description: description,
      instruction: instruction,
      duration: duration,
      repetitions: repetitions,
      tts: tts,
      animation: animation,
      xp: xp,
      difficulty: difficulty,
      ageMin: ageMin,
      ageMax: ageMax,
      enabled: enabled,
    );
  }
}
