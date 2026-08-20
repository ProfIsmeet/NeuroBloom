import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom navigation shell hosting the six top-level feature branches.
/// Navigation switches must never crash regardless of branch content.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Ana Sayfa'),
    NavigationDestination(
      icon: Icon(Icons.self_improvement_rounded),
      label: 'Egzersizler',
    ),
    NavigationDestination(
      icon: Icon(Icons.videogame_asset_rounded),
      label: 'Oyunlar',
    ),
    NavigationDestination(
      icon: Icon(Icons.smart_toy_rounded),
      label: 'NeuroBot',
    ),
    NavigationDestination(
      icon: Icon(Icons.bar_chart_rounded),
      label: 'İlerleme',
    ),
    NavigationDestination(
      icon: Icon(Icons.workspace_premium_rounded),
      label: 'Premium',
    ),
  ];

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        animationDuration: reduceMotion ? Duration.zero : null,
        destinations: _destinations,
      ),
    );
  }
}
