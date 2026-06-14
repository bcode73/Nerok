import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../models/episode.dart';
import '../../../providers/providers.dart';
import '../../../theme/colors.dart';
import '../../../theme/dimens.dart';
import '../../../theme/typography.dart';
import '../../../widgets/app_card.dart';

/// One row in a list of episodes: date · type, duration, triggers, intensity.
class EpisodeTile extends ConsumerWidget {
  const EpisodeTile({super.key, required this.episode, this.onTap});

  final Episode episode;
  final VoidCallback? onTap;

  String _duration(Episode e) {
    if (e.isOngoing) return 'Ongoing';
    final d = e.duration;
    if (d.inHours >= 1) {
      final h = d.inHours;
      final m = d.inMinutes % 60;
      return m == 0 ? '${h}h' : '${h}h ${m}m';
    }
    return '${d.inMinutes}m';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogRepositoryProvider);
    final triggerNames = episode.triggerIds
        .map((id) => catalog.byId(id)?.name)
        .whereType<String>()
        .toList();

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpace.md),
      child: Row(
        children: [
          _IntensityBadge(intensity: episode.intensity),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${DateFormat('EEE d MMM').format(episode.startAt)} · ${episode.type.label}',
                        style: AppType.bodyHi,
                      ),
                    ),
                    Text(_duration(episode), style: AppType.caption),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  triggerNames.isEmpty
                      ? 'No triggers logged'
                      : triggerNames.join(' · '),
                  style: AppType.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IntensityBadge extends StatelessWidget {
  const _IntensityBadge({required this.intensity});
  final int intensity;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.intensity(intensity);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadii.input),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      alignment: Alignment.center,
      child: Text(
        '$intensity',
        style: AppType.bodyHi.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
