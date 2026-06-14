import 'package:hive/hive.dart';

part 'med_log.g.dart';

/// A single instance of a medication taken during an episode.
@HiveType(typeId: 1)
class MedLog {
  @HiveField(0)
  String medId;

  @HiveField(1)
  String name;

  @HiveField(2)
  double? doseMg;

  @HiveField(3)
  DateTime takenAt;

  /// 0 none, 1 some, 2 full, null unknown.
  @HiveField(4)
  int? effectiveness;

  MedLog({
    required this.medId,
    required this.name,
    this.doseMg,
    required this.takenAt,
    this.effectiveness,
  });

  Map<String, dynamic> toJson() => {
        'medId': medId,
        'name': name,
        'doseMg': doseMg,
        'takenAt': takenAt.toIso8601String(),
        'effectiveness': effectiveness,
      };

  factory MedLog.fromJson(Map<String, dynamic> json) => MedLog(
        medId: json['medId'] as String,
        name: json['name'] as String,
        doseMg: (json['doseMg'] as num?)?.toDouble(),
        takenAt: DateTime.parse(json['takenAt'] as String),
        effectiveness: json['effectiveness'] as int?,
      );
}
