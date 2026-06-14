import 'package:flutter/material.dart';

import '../../../theme/colors.dart';
import '../../../theme/dimens.dart';
import '../../../theme/typography.dart';

/// Intensity 1..10 with a big Fraunces number tinted by the ember ramp.
class IntensityPicker extends StatelessWidget {
  const IntensityPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  String _word(int v) {
    if (v <= 3) return 'Mild';
    if (v <= 6) return 'Moderate';
    if (v <= 8) return 'Severe';
    return 'Extreme';
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.intensity(value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Intensity', style: AppType.label),
        const SizedBox(height: AppSpace.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$value',
              style: AppType.statNumber.copyWith(color: color),
            ),
            const SizedBox(width: AppSpace.sm),
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.md),
              child: Text(
                '${_word(value)} · $value/10',
                style: AppType.body.copyWith(color: color),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.16),
          ),
          child: Slider(
            value: value.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
      ],
    );
  }
}
