import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/episode.dart';
import '../../../theme/colors.dart';
import '../../../theme/dimens.dart';
import '../../../theme/typography.dart';

/// Month calendar where each day is tinted by that day's worst intensity.
/// Days outside the free 30-day window are shown locked when [lockedBefore] is
/// set.
class HeatmapCalendar extends StatelessWidget {
  const HeatmapCalendar({
    super.key,
    required this.month,
    required this.episodes,
    required this.onPrev,
    required this.onNext,
    this.lockedBefore,
  });

  final DateTime month; // any day within the month
  final List<Episode> episodes;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  /// Days strictly before this date are locked (free tier). Null = all visible.
  final DateTime? lockedBefore;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // Monday = 1 ... Sunday = 7; grid starts on Monday.
    final leadingBlanks = first.weekday - 1;
    final today = DateTime.now();
    final isCurrentMonth =
        month.year == today.year && month.month == today.month;

    final worst = <int, int>{};
    for (final e in episodes) {
      if (e.startAt.year == month.year && e.startAt.month == month.month) {
        final d = e.startAt.day;
        if ((worst[d] ?? 0) < e.intensity) worst[d] = e.intensity;
      }
    }

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onPrev,
              icon: const Icon(Icons.chevron_left, color: AppColors.textMid),
            ),
            Expanded(
              child: Text(
                DateFormat('MMMM yyyy').format(month),
                textAlign: TextAlign.center,
                style: AppType.title,
              ),
            ),
            IconButton(
              onPressed: isCurrentMonth ? null : onNext,
              icon: Icon(
                Icons.chevron_right,
                color: isCurrentMonth ? AppColors.textLow : AppColors.textMid,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.sm),
        Row(
          children: [
            for (final d in ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
              Expanded(
                child: Center(
                  child: Text(d, style: AppType.caption),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpace.sm),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 1,
          ),
          itemCount: leadingBlanks + daysInMonth,
          itemBuilder: (context, index) {
            if (index < leadingBlanks) return const SizedBox.shrink();
            final day = index - leadingBlanks + 1;
            final date = DateTime(month.year, month.month, day);
            final intensity = worst[day];
            final isToday = date.year == today.year &&
                date.month == today.month &&
                date.day == today.day;
            final locked = lockedBefore != null &&
                date.isBefore(DateTime(lockedBefore!.year, lockedBefore!.month,
                    lockedBefore!.day));
            return _DayCell(
              day: day,
              intensity: intensity,
              isToday: isToday,
              locked: locked,
            );
          },
        ),
        const SizedBox(height: AppSpace.md),
        const _Legend(),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.intensity,
    required this.isToday,
    required this.locked,
  });

  final int day;
  final int? intensity;
  final bool isToday;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final hasEpisode = intensity != null;
    final bg = locked
        ? AppColors.surface.withValues(alpha: 0.4)
        : hasEpisode
            ? AppColors.intensity(intensity!)
            : AppColors.surface;
    final fg = locked
        ? AppColors.textLow
        : hasEpisode
            ? AppColors.page
            : AppColors.textMid;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: isToday
            ? Border.all(color: AppColors.textHi, width: 1.5)
            : Border.all(color: AppColors.line),
      ),
      alignment: Alignment.center,
      child: locked
          ? const Icon(Icons.lock, size: 12, color: AppColors.textLow)
          : Text(
              '$day',
              style: AppType.caption.copyWith(
                color: fg,
                fontWeight: hasEpisode ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Mild', style: AppType.caption),
        const SizedBox(width: AppSpace.sm),
        for (var i = 1; i <= 10; i++)
          Container(
            width: 14,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: AppColors.intensity(i),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        const SizedBox(width: AppSpace.sm),
        Text('Severe', style: AppType.caption),
      ],
    );
  }
}
