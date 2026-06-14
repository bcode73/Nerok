import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/episodes_provider.dart';
import '../../theme/colors.dart';
import '../../theme/dimens.dart';
import '../../theme/typography.dart';
import '../../widgets/app_card.dart';
import '../report/report_screen.dart';
import 'widgets/days_clear_ring.dart';
import 'widgets/week_bars.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daysClear = ref.watch(daysClearProvider);
    final lastEpisode = ref.watch(lastEpisodeProvider);
    final hasData = lastEpisode != null;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpace.lg, AppSpace.lg, AppSpace.lg, 120),
        children: [
          Text(_greeting(), style: AppType.body),
          const SizedBox(height: 2),
          Text('Today', style: AppType.display.copyWith(fontSize: 30)),
          const SizedBox(height: AppSpace.xl),
          AppCard(
            padding: const EdgeInsets.symmetric(
                vertical: AppSpace.xl, horizontal: AppSpace.lg),
            child: Center(
              child: DaysClearRing(
                days: daysClear,
                ongoing: lastEpisode?.isOngoing ?? false,
                hasData: hasData,
              ),
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('This week', style: AppType.title),
                const SizedBox(height: AppSpace.lg),
                const WeekBars(),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          _ReportBanner(),
        ],
      ),
    );
  }
}

class _ReportBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.surface2,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ReportScreen()),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.accentSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.description_outlined,
                color: AppColors.accent),
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Appointment soon?', style: AppType.bodyHi),
                const SizedBox(height: 2),
                Text('Create a report to bring to your doctor.',
                    style: AppType.caption),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textMid),
        ],
      ),
    );
  }
}
