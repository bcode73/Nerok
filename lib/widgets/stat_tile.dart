import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/dimens.dart';
import '../theme/typography.dart';
import 'app_card.dart';

/// A compact metric tile: a big Fraunces value, a label, and an optional trend
/// chip. Used on Insights and the report preview.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.value,
    required this.label,
    this.trend,
    this.trendIsGood,
  });

  final String value;
  final String label;

  /// e.g. "−20%" or "+3". Omit for no trend.
  final String? trend;

  /// Whether the trend is a positive outcome (fewer/lower). Colours the chip.
  final bool? trendIsGood;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppType.statNumber.copyWith(fontSize: 40),
          ),
          const SizedBox(height: AppSpace.xs),
          Row(
            children: [
              Expanded(
                child: Text(label, style: AppType.caption),
              ),
              if (trend != null) _TrendChip(trend!, trendIsGood ?? true),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendChip extends StatelessWidget {
  const _TrendChip(this.text, this.isGood);

  final String text;
  final bool isGood;

  @override
  Widget build(BuildContext context) {
    final color = isGood ? AppColors.good : AppColors.accent;
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpace.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        text,
        style: AppType.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
