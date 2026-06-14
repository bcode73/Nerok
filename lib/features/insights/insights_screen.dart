import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/episodes_provider.dart';
import '../../providers/insights_provider.dart';
import '../../providers/pro_provider.dart';
import '../../theme/colors.dart';
import '../../theme/dimens.dart';
import '../../theme/typography.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/stat_tile.dart';
import '../../widgets/upsell_lock.dart';
import 'widgets/episodes_bar_chart.dart';
import 'widgets/top_triggers.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(isProProvider);
    final hasData = ref.watch(episodesProvider).isNotEmpty;
    final insights = ref.watch(insightsProvider);

    if (!isPro) {
      return _LockedPreview(insights: insights);
    }

    if (!hasData || insights.isEmpty) {
      return const SafeArea(
        child: EmptyState(
          icon: Icons.insights_outlined,
          title: 'No insights yet',
          message: 'Log a few episodes and your patterns over the last '
              '90 days will appear here.',
        ),
      );
    }

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpace.lg, AppSpace.lg, AppSpace.lg, 120),
        children: [
          Text('Insights', style: AppType.display.copyWith(fontSize: 30)),
          const SizedBox(height: 2),
          Text('Last 90 days', style: AppType.body),
          const SizedBox(height: AppSpace.lg),
          _StatRow(insights: insights),
          const SizedBox(height: AppSpace.lg),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Episodes per week', style: AppType.title),
                const SizedBox(height: AppSpace.lg),
                SizedBox(
                  height: 180,
                  child: EpisodesBarChart(buckets: insights.weekBuckets),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Top triggers', style: AppType.title),
                const SizedBox(height: AppSpace.lg),
                TopTriggers(triggers: insights.topTriggers),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.insights});
  final Insights insights;

  @override
  Widget build(BuildContext context) {
    final delta = insights.countDelta;
    final trend = delta == 0
        ? null
        : '${delta > 0 ? '+' : '−'}${delta.abs()}';
    return Row(
      children: [
        Expanded(
          child: StatTile(
            value: '${insights.episodeCount}',
            label: 'Episodes',
            trend: trend,
            trendIsGood: delta <= 0,
          ),
        ),
        const SizedBox(width: AppSpace.md),
        Expanded(
          child: StatTile(
            value: insights.avgIntensity.toStringAsFixed(1),
            label: 'Avg intensity',
          ),
        ),
      ],
    );
  }
}

/// Blurred/locked preview shown to free users.
class _LockedPreview extends StatelessWidget {
  const _LockedPreview({required this.insights});
  final Insights insights;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpace.lg, AppSpace.lg, AppSpace.lg, 120),
        children: [
          Text('Insights', style: AppType.display.copyWith(fontSize: 30)),
          const SizedBox(height: 2),
          Text('Last 90 days', style: AppType.body),
          const SizedBox(height: AppSpace.lg),
          Stack(
            children: [
              // Real-ish content rendered behind a blur so the value is felt.
              IgnorePointer(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: StatTile(
                            value: '${insights.episodeCount}',
                            label: 'Episodes',
                          ),
                        ),
                        const SizedBox(width: AppSpace.md),
                        Expanded(
                          child: StatTile(
                            value: insights.avgIntensity.toStringAsFixed(1),
                            label: 'Avg intensity',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpace.lg),
                    AppCard(
                      child: SizedBox(
                        height: 180,
                        child: EpisodesBarChart(buckets: insights.weekBuckets),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.card),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      color: AppColors.bg.withValues(alpha: 0.35),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.lg),
          const UpsellLock(
            title: 'Unlock insights',
            message:
                'See your episode trends, busiest weeks and most common '
                'triggers over the last 90 days.',
            cta: 'Unlock insights',
          ),
        ],
      ),
    );
  }
}
