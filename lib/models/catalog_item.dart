import 'package:hive/hive.dart';

import 'enums.dart';

part 'catalog_item.g.dart';

/// Triggers, symptoms and relief all share this shape, distinguished by [kind].
@HiveType(typeId: 2)
class CatalogItem {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  CatalogKind kind;

  @HiveField(3)
  bool isCustom;

  /// Optional grouping for triggers.
  @HiveField(4)
  int? category;

  CatalogItem({
    required this.id,
    required this.name,
    required this.kind,
    this.isCustom = false,
    this.category,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'kind': kind.index,
        'isCustom': isCustom,
        'category': category,
      };

  factory CatalogItem.fromJson(Map<String, dynamic> json) => CatalogItem(
        id: json['id'] as String,
        name: json['name'] as String,
        kind: CatalogKind.values[json['kind'] as int],
        isCustom: json['isCustom'] as bool? ?? false,
        category: json['category'] as int?,
      );
}
