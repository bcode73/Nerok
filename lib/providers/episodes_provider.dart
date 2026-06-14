import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/episode.dart';
import 'providers.dart';

/// Reactive list of all episodes (newest first), backed by the Hive box.
class EpisodesNotifier extends Notifier<List<Episode>> {
  @override
  List<Episode> build() {
    final repo = ref.watch(episodeRepositoryProvider);
    final sub = repo.watch().listen((_) => _refresh());
    ref.onDispose(sub.cancel);
    return repo.all();
  }

  void _refresh() => state = ref.read(episodeRepositoryProvider).all();

  Future<void> save(Episode episode) async {
    await ref.read(episodeRepositoryProvider).save(episode);
    _refresh();
  }

  Future<void> delete(String id) async {
    await ref.read(episodeRepositoryProvider).delete(id);
    _refresh();
  }
}

final episodesProvider =
    NotifierProvider<EpisodesNotifier, List<Episode>>(EpisodesNotifier.new);

/// Most recent episode, or null when there are none.
final lastEpisodeProvider = Provider<Episode?>((ref) {
  final episodes = ref.watch(episodesProvider);
  return episodes.isEmpty ? null : episodes.first;
});

/// Whole days clear since the end of the most recent episode.
final daysClearProvider = Provider<int>((ref) {
  final last = ref.watch(lastEpisodeProvider);
  if (last == null) return 0;
  if (last.isOngoing) return 0;
  final since = last.endAt!;
  final now = DateTime.now();
  return now.difference(since).inDays;
});
