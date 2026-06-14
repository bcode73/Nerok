import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../providers/insights_provider.dart';
import '../../../theme/colors.dart';
import '../../../theme/typography.dart';

/// Bar chart of episode counts per week.
class EpisodesBarChart extends StatelessWidget {
  const EpisodesBarChart({super.key, required this.buckets});

  final List<WeekBucket> buckets;

  @override
  Widget build(BuildContext context) {
    final maxCount =
        buckets.fold<int>(0, (m, b) => b.count > m ? b.count : m);
    final maxY = (maxCount + 1).toDouble();
    // Label every Nth week to avoid crowding.
    final step = (buckets.length / 6).ceil().clamp(1, buckets.length);

    return BarChart(
      BarChartData(
        maxY: maxY,
        alignment: BarChartAlignment.spaceBetween,
        barTouchData: BarTouchData(enabled: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY <= 4 ? 1 : (maxY / 4).ceilToDouble(),
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppColors.line, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              interval: maxY <= 4 ? 1 : (maxY / 4).ceilToDouble(),
              getTitlesWidget: (value, meta) {
                if (value != value.roundToDouble()) {
                  return const SizedBox.shrink();
                }
                return Text('${value.toInt()}', style: AppType.caption);
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= buckets.length) {
                  return const SizedBox.shrink();
                }
                if (i % step != 0 && i != buckets.length - 1) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    DateFormat('d/M').format(buckets[i].weekStart),
                    style: AppType.caption.copyWith(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < buckets.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: buckets[i].count.toDouble(),
                  width: 10,
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [AppColors.accentDeep, AppColors.accent],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
