import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/episode.dart';
import 'episodes_provider.dart';
import 'providers.dart';

/// A trigger and how often it appeared in the analysed window.
class TriggerCount {
  const TriggerCount(this.name, this.count);
  final String name;
  final int count;
}

/// Episodes that started within a given calendar week (Mon-anchored bucket).
class WeekBucket {
  const WeekBucket(this.weekStart, this.count);
  final DateTime weekStart;
  final int count;
}

/// Plain aggregation over the last [days] of local data. No ML, no network.
class Insights {
  const Insights({
    required this.days,
    required this.episodeCount,
    required this.priorEpisodeCount,
    required this.avgIntensity,
    required this.avgDuration,
    required this.episodesPerWeek,
    required this.weekBuckets,
    required this.topTriggers,
  });

  final int days;
  final int episodeCount;
  final int priorEpisodeCount;
  final double avgIntensity;
  final Duration avgDuration;
  final double episodesPerWeek;
  final List<WeekBucket> weekBuckets;
  final List<TriggerCount> topTriggers;

  bool get isEmpty => episodeCount == 0;

  /// Change in episode count vs the equally-sized prior period.
  /// Negative is an improvement (fewer episodes).
  int get countDelta => episodeCount - priorEpisodeCount;

  /// Percentage change vs prior period, or null when prior period was empty.
  double? get countDeltaPercent {
    if (priorEpisodeCount == 0) return null;
    return (countDelta / priorEpisodeCount) * 100;
  }
}

Insights _aggregate({
  required List<Episode> all,
  required int days,
  required String Function(String triggerId) triggerName,
}) {
  final now = DateTime.now();
  final windowStart = now.subtract(Duration(days: days));
  final priorStart = now.subtract(Duration(days: days * 2));

  final inWindow =
      all.where((e) => e.startAt.isAfter(windowStart)).toList();
  final inPrior = all
      .where((e) =>
          e.startAt.isAfter(priorStart) && !e.startAt.isAfter(windowStart))
      .toList();

  final count = inWindow.length;
  final avgIntensity = count == 0
      ? 0.0
      : inWindow.map((e) => e.intensity).reduce((a, b) => a + b) / count;

  final ended = inWindow.where((e) => e.endAt != null).toList();
  final avgDuration = ended.isEmpty
      ? Duration.zero
      : Duration(
          seconds: ended
                  .map((e) => e.duration.inSeconds)
                  .reduce((a, b) => a + b) ~/
              ended.length,
        );

  // Week buckets across the window (oldest first).
  final weeks = (days / 7).ceil();
  final buckets = <WeekBucket>[];
  for (var i = weeks - 1; i >= 0; i--) {
    final start = now.subtract(Duration(days: (i + 1) * 7));
    final end = now.subtract(Duration(days: i * 7));
    final c = inWindow
        .where((e) => e.startAt.isAfter(start) && !e.startAt.isAfter(end))
        .length;
    buckets.add(WeekBucket(start, c));
  }
  final episodesPerWeek = weeks == 0 ? 0.0 : count / weeks;

  // Trigger frequency.
  final counts = <String, int>{};
  for (final e in inWindow) {
    for (final t in e.triggerIds) {
      counts[t] = (counts[t] ?? 0) + 1;
    }
  }
  final triggers = counts.entries
      .map((e) => TriggerCount(triggerName(e.key), e.value))
      .toList()
    ..sort((a, b) => b.count.compareTo(a.count));

  return Insights(
    days: days,
    episodeCount: count,
    priorEpisodeCount: inPrior.length,
    avgIntensity: avgIntensity,
    avgDuration: avgDuration,
    episodesPerWeek: episodesPerWeek,
    weekBuckets: buckets,
    topTriggers: triggers.take(6).toList(),
  );
}

/// Insights over the last 90 days.
final insightsProvider = Provider<Insights>((ref) {
  final all = ref.watch(episodesProvider);
  final catalog = ref.watch(catalogRepositoryProvider);
  return _aggregate(
    all: all,
    days: 90,
    triggerName: (id) => catalog.byId(id)?.name ?? id,
  );
});

/// Insights for an arbitrary range, used by the doctor report.
final reportInsightsProvider =
    Provider.family<Insights, int>((ref, days) {
  final all = ref.watch(episodesProvider);
  final catalog = ref.watch(catalogRepositoryProvider);
  return _aggregate(
    all: all,
    days: days,
    triggerName: (id) => catalog.byId(id)?.name ?? id,
  );
});
