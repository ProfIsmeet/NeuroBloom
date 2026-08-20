import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_dimens.dart';
import '../domain/game_definition.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oyunlar')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.spaceLg),
        children: gameRegistry.map((game) {
          return Card(
            child: ListTile(
              leading: Icon(
                game.icon,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(game.title),
              subtitle: Text(game.description),
              onTap: () => context.push(game.route),
            ),
          );
        }).toList(),
      ),
    );
  }
}
