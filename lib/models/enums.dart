import 'package:hive/hive.dart';

part 'enums.g.dart';

/// Headache classification for an episode.
@HiveType(typeId: 10)
enum EpisodeType {
  @HiveField(0)
  migraine,
  @HiveField(1)
  tension,
  @HiveField(2)
  cluster,
  @HiveField(3)
  other;

  String get label => switch (this) {
        EpisodeType.migraine => 'Migraine',
        EpisodeType.tension => 'Tension',
        EpisodeType.cluster => 'Cluster',
        EpisodeType.other => 'Other',
      };
}

/// What kind of catalog item this is. Triggers, symptoms and relief share one
/// model shape and are distinguished by this kind.
@HiveType(typeId: 11)
enum CatalogKind {
  @HiveField(0)
  trigger,
  @HiveField(1)
  symptom,
  @HiveField(2)
  relief;

  String get label => switch (this) {
        CatalogKind.trigger => 'Trigger',
        CatalogKind.symptom => 'Symptom',
        CatalogKind.relief => 'Relief',
      };
}
