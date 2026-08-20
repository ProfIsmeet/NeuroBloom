import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Loads JSON array assets defensively: a missing file, invalid JSON, or a
/// root value that isn't a list all yield an empty list instead of throwing,
/// so a broken content file degrades to an empty category, never a crash.
class ContentLoader {
  Future<List<dynamic>> loadJsonList(String assetPath) async {
    try {
      final raw = await rootBundle.loadString(assetPath);
      final decoded = jsonDecode(raw);
      if (decoded is List) return decoded;
      return const [];
    } catch (_) {
      return const [];
    }
  }
}
