import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../theme/colors.dart';
import '../../../theme/dimens.dart';
import '../../../theme/typography.dart';

/// A progress ring showing how many whole days have passed since the last
/// episode. The arc fills over a 30-day horizon, then stays full.
class DaysClearRing extends StatelessWidget {
  const DaysClearRing({
    super.key,
    required this.days,
    required this.ongoing,
    required this.hasData,
  });

  final int days;
  final bool ongoing;
  final bool hasData;

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final progress = ongoing || !hasData ? 0.0 : (days / 30).clamp(0.0, 1.0);

    final centerTop = !hasData
        ? '—'
        : ongoing
            ? 'Now'
            : '$days';
    final centerBottom = !hasData
        ? 'No episodes yet'
        : ongoing
            ? 'Episode ongoing'
            : days == 1
                ? 'day clear'
                : 'days clear';

    return SizedBox(
      width: 200,
      height: 200,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress),
        duration: reduceMotion ? Duration.zero : AppMotion.medium,
        curve: Curves.easeOut,
        builder: (context, value, _) {
          return CustomPaint(
            painter: _RingPainter(value),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(centerTop, style: AppType.statNumber),
                  const SizedBox(height: AppSpace.xs),
                  Text(centerBottom, style: AppType.caption),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 12.0;
    final center = size.center(Offset.zero);
    final radius = (size.width - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = AppColors.surface2;
    canvas.drawCircle(center, radius, track);

    if (progress <= 0) return;

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [AppColors.accent, AppColors.accentDeep],
      ).createShader(rect);

    const start = -math.pi / 2;
    canvas.drawArc(rect, start, 2 * math.pi * progress, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
