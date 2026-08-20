import 'package:flutter/material.dart';

const Map<String, IconData> _badgeIcons = {
  'flag_rounded': Icons.flag_rounded,
  'local_fire_department_rounded': Icons.local_fire_department_rounded,
  'whatshot_rounded': Icons.whatshot_rounded,
  'record_voice_over_rounded': Icons.record_voice_over_rounded,
  'sentiment_very_satisfied_rounded': Icons.sentiment_very_satisfied_rounded,
  'sports_esports_rounded': Icons.sports_esports_rounded,
  'star_half_rounded': Icons.star_half_rounded,
  'star_rounded': Icons.star_rounded,
  'verified_rounded': Icons.verified_rounded,
  'military_tech_rounded': Icons.military_tech_rounded,
};

/// Unknown/missing icon names fall back to a generic badge glyph instead
/// of crashing, consistent with the app's "missing content never crashes"
/// rule.
IconData badgeIconFor(String icon) =>
    _badgeIcons[icon] ?? Icons.emoji_events_rounded;
