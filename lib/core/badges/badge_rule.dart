/// Content-driven unlock condition for a Badge. `type` determines which
/// field of BadgeStats is compared against `threshold`; `category` is
/// only used by the category_count type. `all_badges` is a meta-rule
/// (ignores threshold/category) satisfied once every other badge unlocks.
class BadgeRule {
  const BadgeRule({required this.type, this.threshold = 0, this.category});

  final String type;
  final int threshold;
  final String? category;

  static BadgeRule? tryParse(dynamic json) {
    if (json is! Map) return null;
    final type = json['type'];
    if (type is! String || type.isEmpty) return null;
    final threshold = json['threshold'];
    final category = json['category'];
    if (threshold != null && threshold is! int) return null;
    if (category != null && category is! String) return null;
    return BadgeRule(
      type: type,
      threshold: threshold is int ? threshold : 0,
      category: category is String ? category : null,
    );
  }
}
