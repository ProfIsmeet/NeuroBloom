import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_dimens.dart';
import '../application/exercise_providers.dart';
import '../domain/exercise.dart';

const Map<String, String> _categoryLabelsTr = {
  'tongue': 'Dil',
  'lips': 'Dudak',
  'speech': 'Konuşma',
};

const List<String> _categoryOrder = ['tongue', 'lips', 'speech'];

class ExercisesScreen extends ConsumerWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercisesAsync = ref.watch(visibleExercisesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Egzersizler')),
      body: exercisesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Egzersizler yüklenemedi.')),
        data: (exercises) {
          return ListView(
            padding: const EdgeInsets.all(AppDimens.spaceLg),
            children: _categoryOrder.map((category) {
              final items = exercises
                  .where((e) => e.category == category)
                  .toList();
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.spaceLg),
                child: _CategorySection(
                  title: _categoryLabelsTr[category] ?? category,
                  exercises: items,
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({required this.title, required this.exercises});

  final String title;
  final List<Exercise> exercises;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppDimens.spaceSm),
        if (exercises.isEmpty)
          const Text('Bu kategoride henüz egzersiz yok.')
        else
          ...exercises.map(
            (exercise) => Card(
              margin: const EdgeInsets.only(bottom: AppDimens.spaceSm),
              child: ListTile(
                title: Text(exercise.title),
                subtitle: Text(exercise.description),
                trailing: Text('${exercise.xp} XP'),
                onTap: () => context.push('/exercises/run/${exercise.id}'),
              ),
            ),
          ),
      ],
    );
  }
}
