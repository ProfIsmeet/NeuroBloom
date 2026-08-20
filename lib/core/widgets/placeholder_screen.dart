import 'package:flutter/material.dart';
import '../theme/app_dimens.dart';

/// Shared placeholder body used by every feature screen until its real
/// UI is implemented in a later phase.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: AppDimens.spaceMd),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppDimens.spaceSm),
              Text(
                'Yakında burada olacak.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
