import 'package:hive/hive.dart';

import 'enums.dart';
import 'med_log.dart';

part 'episode.g.dart';

/// A logged headache/migraine episode.
@HiveType(typeId: 0)
class Episode {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime startAt;

  /// null = ongoing.
  @HiveField(2)
  DateTime? endAt;

  /// 1..10.
  @HiveField(3)
  int intensity;

  @HiveField(4)
  EpisodeType type;

  /// Free strings, e.g. left, right, front, whole.
  @HiveField(5)
  List<String> locations;

  @HiveField(6)
  List<String> triggerIds;

  @HiveField(7)
  List<String> symptomIds;

  @HiveField(8)
  List<String> reliefIds;

  @HiveField(9)
  List<MedLog> meds;

  @HiveField(10)
  String notes;

  @HiveField(11)
  DateTime createdAt;

  @HiveField(12)
  DateTime updatedAt;

  Episode({
    required this.id,
    required this.startAt,
    this.endAt,
    required this.intensity,
    required this.type,
    List<String>? locations,
    List<String>? triggerIds,
    List<String>? symptomIds,
    List<String>? reliefIds,
    List<MedLog>? meds,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  })  : locations = locations ?? [],
        triggerIds = triggerIds ?? [],
        symptomIds = symptomIds ?? [],
        reliefIds = reliefIds ?? [],
        meds = meds ?? [];

  bool get isOngoing => endAt == null;

  /// Duration so far, or final duration if ended.
  Duration get duration => (endAt ?? DateTime.now()).difference(startAt);

  Map<String, dynamic> toJson() => {
        'id': id,
        'startAt': startAt.toIso8601String(),
        'endAt': endAt?.toIso8601String(),
        'intensity': intensity,
        'type': type.index,
        'locations': locations,
        'triggerIds': triggerIds,
        'symptomIds': symptomIds,
        'reliefIds': reliefIds,
        'meds': meds.map((m) => m.toJson()).toList(),
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Episode.fromJson(Map<String, dynamic> json) => Episode(
        id: json['id'] as String,
        startAt: DateTime.parse(json['startAt'] as String),
        endAt: json['endAt'] == null
            ? null
            : DateTime.parse(json['endAt'] as String),
        intensity: json['intensity'] as int,
        type: EpisodeType.values[json['type'] as int],
        locations: (json['locations'] as List?)?.cast<String>() ?? [],
        triggerIds: (json['triggerIds'] as List?)?.cast<String>() ?? [],
        symptomIds: (json['symptomIds'] as List?)?.cast<String>() ?? [],
        reliefIds: (json['reliefIds'] as List?)?.cast<String>() ?? [],
        meds: (json['meds'] as List?)
                ?.map((m) => MedLog.fromJson((m as Map).cast<String, dynamic>()))
                .toList() ??
            [],
        notes: json['notes'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}
