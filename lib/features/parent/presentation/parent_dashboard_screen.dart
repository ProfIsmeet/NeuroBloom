import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/security/parent_pin_providers.dart';
import '../../../core/streak/streak_providers.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/xp/xp_providers.dart';
import '../../exercises/application/exercise_completion_providers.dart';
import '../../home/application/emotion_providers.dart';
import '../application/dashboard_providers.dart';

const List<String> _weekdayLabelsTr = ['Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct', 'Pz'];

/// Only reachable when parentUnlockedProvider is true — enforced by
/// AppRouter's redirect, not by anything in this widget.
class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalXp = ref.watch(totalXpProvider);
    final streak = ref.watch(currentStreakProvider);
    final exerciseCount =
        (ref.watch(exerciseCompletionsProvider).valueOrNull ?? []).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ebeveyn Paneli'),
        actions: [
          IconButton(
            tooltip: 'Kilitle',
            icon: const Icon(Icons.lock_rounded),
            onPressed: () {
              ref.read(parentAuthControllerProvider).lock();
              context.go('/parent');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.spaceLg),
        children: [
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppDimens.spaceMd,
            crossAxisSpacing: AppDimens.spaceMd,
            childAspectRatio: 1.1,
            children: [
              _StatTile(
                key: const Key('stat_exerciseCount'),
                label: 'Toplam Egzersiz',
                value: '$exerciseCount',
              ),
              _StatTile(
                key: const Key('stat_totalXp'),
                label: 'Toplam XP',
                value: '$totalXp',
              ),
              _StatTile(
                key: const Key('stat_streak'),
                label: 'Streak',
                value: '$streak',
              ),
            ],
          ),
          const SizedBox(height: AppDimens.spaceXl),
          Text('Haftalık Aktivite', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppDimens.spaceMd),
          const SizedBox(height: 180, child: _WeeklyActivityChart()),
          const SizedBox(height: AppDimens.spaceXl),
          Text('Duygu Dağılımı', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppDimens.spaceMd),
          const SizedBox(height: 220, child: _EmotionDistributionChart()),
          const SizedBox(height: AppDimens.spaceXl),
          Text('XP İlerlemesi', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppDimens.spaceMd),
          const SizedBox(height: 180, child: _XpProgressChart()),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.spaceSm),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyActivityChart extends ConsumerWidget {
  const _WeeklyActivityChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(weeklyActivityProvider);
    final values = counts.values.toList();
    final maxValue = values.isEmpty
        ? 1.0
        : (values.reduce((a, b) => a > b ? a : b)).toDouble();

    return BarChart(
      BarChartData(
        maxY: maxValue < 1 ? 1 : maxValue + 1,
        barGroups: [
          for (var i = 0; i < values.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: values[i].toDouble(),
                  color: Theme.of(context).colorScheme.primary,
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
        ],
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 24),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= _weekdayLabelsTr.length) return const SizedBox.shrink();
                return Text(_weekdayLabelsTr[i], style: const TextStyle(fontSize: 11));
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

class _EmotionDistributionChart extends ConsumerWidget {
  const _EmotionDistributionChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distribution = ref.watch(emotionDistributionProvider);
    final definitions = ref.watch(emotionDefinitionsProvider).valueOrNull ?? [];
    final emojiById = {for (final d in definitions) d.id: d.emoji};

    if (distribution.isEmpty) {
      return Center(
        child: Text(
          'Henüz duygu kaydedilmedi.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final total = distribution.values.fold(0, (a, b) => a + b);
    final colors = Theme.of(context).colorScheme;
    final palette = [colors.primary, colors.secondary, colors.tertiary];

    return PieChart(
      PieChartData(
        sections: [
          for (final (i, entry) in distribution.entries.indexed)
            PieChartSectionData(
              value: entry.value.toDouble(),
              title: emojiById[entry.key] ?? entry.key,
              color: palette[i % palette.length],
              radius: 70,
              titleStyle: const TextStyle(fontSize: 16),
            ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 32,
      ),
      duration: total > 0 ? const Duration(milliseconds: 200) : Duration.zero,
    );
  }
}

class _XpProgressChart extends ConsumerWidget {
  const _XpProgressChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyTotals = ref.watch(dailyXpTotalsProvider);

    if (dailyTotals.isEmpty) {
      return Center(
        child: Text(
          'Henüz XP kazanılmadı.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    var cumulative = 0;
    final spots = <FlSpot>[];
    for (var i = 0; i < dailyTotals.length; i++) {
      cumulative += dailyTotals[i].value;
      spots.add(FlSpot(i.toDouble(), cumulative.toDouble()));
    }

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        ],
        titlesData: const FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 32),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
