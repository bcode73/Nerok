import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/episodes_provider.dart';
import '../../providers/pro_provider.dart';
import '../../theme/dimens.dart';
import '../../theme/typography.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/section_header.dart';
import '../../widgets/upsell_lock.dart';
import '../log/log_episode_sheet.dart';
import 'widgets/episode_tile.dart';
import 'widgets/heatmap_calendar.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  void _shift(int months) {
    setState(() => _month = DateTime(_month.year, _month.month + months));
  }

  @override
  Widget build(BuildContext context) {
    final episodes = ref.watch(episodesProvider);
    final isPro = ref.watch(isProProvider);
    final now = DateTime.now();
    final freeCutoff = now.subtract(const Duration(days: 30));

    if (episodes.isEmpty) {
      return const SafeArea(
        child: EmptyState(
          icon: Icons.calendar_month_outlined,
          title: 'No history yet',
          message: 'Tap the + button to log your first episode. '
              'Your calendar fills in as you go.',
        ),
      );
    }

    // Free tier: only show episodes from the last 30 days in the list.
    final visibleEpisodes = isPro
        ? episodes
        : episodes.where((e) => e.startAt.isAfter(freeCutoff)).toList();
    final hiddenCount = episodes.length - visibleEpisodes.length;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpace.lg, AppSpace.lg, AppSpace.lg, 120),
        children: [
          Text('History', style: AppType.display.copyWith(fontSize: 30)),
          const SizedBox(height: AppSpace.lg),
          AppCard(
            child: HeatmapCalendar(
              month: _month,
              episodes: episodes,
              onPrev: () => _shift(-1),
              onNext: () => _shift(1),
              lockedBefore: isPro ? null : freeCutoff,
            ),
          ),
          const SizedBox(height: AppSpace.xl),
          const SectionHeader(title: 'Recent episodes'),
          for (final e in visibleEpisodes)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.sm),
              child: EpisodeTile(
                episode: e,
                onTap: () => _openEdit(e.id),
              ),
            ),
          if (!isPro && hiddenCount > 0) ...[
            const SizedBox(height: AppSpace.sm),
            UpsellRow(
              message:
                  'Unlock $hiddenCount older ${hiddenCount == 1 ? 'episode' : 'episodes'} '
                  'and full calendar history with Pro.',
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openEdit(String id) async {
    final episode = ref.read(episodesProvider).firstWhere((e) => e.id == id);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => LogEpisodeSheet(episode: episode),
    );
  }
}
