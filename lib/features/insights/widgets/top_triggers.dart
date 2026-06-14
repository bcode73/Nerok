import 'package:flutter/material.dart';

import '../../../providers/insights_provider.dart';
import '../../../theme/colors.dart';
import '../../../theme/dimens.dart';
import '../../../theme/typography.dart';

/// Ranked horizontal bars of the most common triggers.
class TopTriggers extends StatelessWidget {
  const TopTriggers({super.key, required this.triggers});

  final List<TriggerCount> triggers;

  @override
  Widget build(BuildContext context) {
    if (triggers.isEmpty) {
      return Text('No triggers logged yet.', style: AppType.body);
    }
    final max = triggers.first.count;

    return Column(
      children: [
        for (final t in triggers)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpace.md),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    t.name,
                    style: AppType.bodyHi,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  flex: 7,
                  child: _Bar(fraction: max == 0 ? 0 : t.count / max),
                ),
                const SizedBox(width: AppSpace.sm),
                SizedBox(
                  width: 24,
                  child: Text(
                    '${t.count}',
                    textAlign: TextAlign.right,
                    style: AppType.label,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.fraction});
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: Container(
        height: 10,
        color: AppColors.surface2,
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: fraction.clamp(0.04, 1.0),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.accentDeep, AppColors.accent],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
