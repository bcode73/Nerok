import 'package:hive/hive.dart';

part 'medication.g.dart';

/// A medication the user can attach to an episode.
@HiveType(typeId: 3)
class Medication {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double? defaultDoseMg;

  /// 0 acute, 1 preventive.
  @HiveField(3)
  int kind;

  Medication({
    required this.id,
    required this.name,
    this.defaultDoseMg,
    this.kind = 0,
  });

  bool get isPreventive => kind == 1;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'defaultDoseMg': defaultDoseMg,
        'kind': kind,
      };

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
        id: json['id'] as String,
        name: json['name'] as String,
        defaultDoseMg: (json['defaultDoseMg'] as num?)?.toDouble(),
        kind: json['kind'] as int? ?? 0,
      );
}
