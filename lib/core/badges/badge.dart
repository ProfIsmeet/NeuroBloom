import 'badge_rule.dart';

class Badge {
  const Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.rule,
  });

  final String id;
  final String title;
  final String description;
  final String icon;
  final BadgeRule rule;

  /// Returns null (never throws) on any malformed entry, so one bad JSON
  /// object skips that badge instead of breaking the whole list.
  static Badge? tryParse(dynamic json) {
    if (json is! Map) return null;
    final id = json['id'];
    final title = json['title'];
    final description = json['description'];
    final icon = json['icon'];
    final rule = BadgeRule.tryParse(json['rule']);
    if (id is! String || id.isEmpty) return null;
    if (title is! String) return null;
    if (description is! String) return null;
    if (icon is! String) return null;
    if (rule == null) return null;
    return Badge(
      id: id,
      title: title,
      description: description,
      icon: icon,
      rule: rule,
    );
  }
}
