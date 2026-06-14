// Basic unit tests for Nerok's on-device models.
//
// Widget tests that boot the full app are intentionally omitted here because
// the app depends on initialised Hive boxes and platform plugins.

import 'package:flutter_test/flutter_test.dart';
import 'package:nerok/models/enums.dart';
import 'package:nerok/models/episode.dart';

void main() {
  test('Episode duration reflects start and end', () {
    final start = DateTime(2026, 1, 1, 9);
    final end = DateTime(2026, 1, 1, 11, 30);
    final e = Episode(
      id: 'a',
      startAt: start,
      endAt: end,
      intensity: 6,
      type: EpisodeType.migraine,
      createdAt: start,
      updatedAt: start,
    );
    expect(e.isOngoing, isFalse);
    expect(e.duration, const Duration(hours: 2, minutes: 30));
  });

  test('Episode JSON round-trips', () {
    final start = DateTime(2026, 1, 1, 9);
    final original = Episode(
      id: 'b',
      startAt: start,
      intensity: 4,
      type: EpisodeType.tension,
      triggerIds: ['stress', 'poor_sleep'],
      notes: 'Test',
      createdAt: start,
      updatedAt: start,
    );
    final restored = Episode.fromJson(original.toJson());
    expect(restored.id, original.id);
    expect(restored.intensity, 4);
    expect(restored.type, EpisodeType.tension);
    expect(restored.triggerIds, ['stress', 'poor_sleep']);
    expect(restored.isOngoing, isTrue);
  });
}
