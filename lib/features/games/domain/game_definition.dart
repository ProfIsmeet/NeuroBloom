import 'package:flutter/material.dart';

/// Static registry of available mini-games. Infrastructure only for v0.1
/// (a single entry, Harf Çarkı) — future games (Story Quest, Minimal
/// Pairs, ...) register here without any change to GamesScreen.
class GameDefinition {
  const GameDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String route;
}

const List<GameDefinition> gameRegistry = [
  GameDefinition(
    id: 'letter_wheel',
    title: 'Harf Çarkı',
    description: 'Çarkı çevir, çıkan heceyle bir kelime söyle!',
    icon: Icons.donut_large_rounded,
    route: '/games/letter-wheel',
  ),
];
