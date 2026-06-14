// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CatalogItemAdapter extends TypeAdapter<CatalogItem> {
  @override
  final int typeId = 2;

  @override
  CatalogItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CatalogItem(
      id: fields[0] as String,
      name: fields[1] as String,
      kind: fields[2] as CatalogKind,
      isCustom: fields[3] as bool,
      category: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, CatalogItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.kind)
      ..writeByte(3)
      ..write(obj.isCustom)
      ..writeByte(4)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatalogItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
