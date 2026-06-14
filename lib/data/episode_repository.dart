import 'package:hive/hive.dart';

import '../models/episode.dart';

/// CRUD + queries over the episodes box.
class EpisodeRepository {
  EpisodeRepository(this._box);

  final Box<Episode> _box;

  /// All episodes, newest first.
  List<Episode> all() {
    final list = _box.values.toList();
    list.sort((a, b) => b.startAt.compareTo(a.startAt));
    return list;
  }

  Episode? byId(String id) => _box.get(id);

  Future<void> save(Episode episode) async {
    episode.updatedAt = DateTime.now();
    await _box.put(episode.id, episode);
  }

  Future<void> delete(String id) async => _box.delete(id);

  /// Episodes whose start falls within [from, to).
  List<Episode> inRange(DateTime from, DateTime to) {
    return all()
        .where((e) => !e.startAt.isBefore(from) && e.startAt.isBefore(to))
        .toList();
  }

  /// Listenable for providers.
  Stream<BoxEvent> watch() => _box.watch();
}
