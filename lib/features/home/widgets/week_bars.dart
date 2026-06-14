import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../models/episode.dart';
import '../../../providers/episodes_provider.dart';
import '../../../theme/colors.dart';
import '../../../theme/dimens.dart';
import '../../../theme/typography.dart';

/// Seven mini bars, one per day for the last week. Each bar's height and tint
/// reflect that day's worst intensity. Calm ember ramp, no traffic lights.
class WeekBars extends ConsumerWidget {
  const WeekBars({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodes = ref.watch(episodesProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final days = List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      final worst = _worstIntensityOn(episodes, day);
      return (day: day, intensity: worst);
    });

    return SizedBox(
      height: 96,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final d in days)
            Expanded(
              child: _Bar(
                intensity: d.intensity,
                label: DateFormat('E').format(d.day)[0],
                isToday: d.day == today,
              ),
            ),
        ],
      ),
    );
  }

  int _worstIntensityOn(List<Episode> episodes, DateTime day) {
    var worst = 0;
    for (final e in episodes) {
      final s = e.startAt;
      if (s.year == day.year && s.month == day.month && s.day == day.day) {
        if (e.intensity > worst) worst = e.intensity;
      }
    }
    return worst;
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.intensity,
    required this.label,
    required this.isToday,
  });

  final int intensity;
  final String label;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final hasEpisode = intensity > 0;
    final fraction = hasEpisode ? (intensity / 10).clamp(0.12, 1.0) : 0.06;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: fraction,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: hasEpisode
                      ? AppColors.intensity(intensity)
                      : AppColors.surface2,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpace.sm),
        Text(
          label,
          style: AppType.caption.copyWith(
            color: isToday ? AppColors.accent : AppColors.textLow,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
