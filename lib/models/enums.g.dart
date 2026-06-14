// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enums.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EpisodeTypeAdapter extends TypeAdapter<EpisodeType> {
  @override
  final int typeId = 10;

  @override
  EpisodeType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EpisodeType.migraine;
      case 1:
        return EpisodeType.tension;
      case 2:
        return EpisodeType.cluster;
      case 3:
        return EpisodeType.other;
      default:
        return EpisodeType.migraine;
    }
  }

  @override
  void write(BinaryWriter writer, EpisodeType obj) {
    switch (obj) {
      case EpisodeType.migraine:
        writer.writeByte(0);
        break;
      case EpisodeType.tension:
        writer.writeByte(1);
        break;
      case EpisodeType.cluster:
        writer.writeByte(2);
        break;
      case EpisodeType.other:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EpisodeTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CatalogKindAdapter extends TypeAdapter<CatalogKind> {
  @override
  final int typeId = 11;

  @override
  CatalogKind read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CatalogKind.trigger;
      case 1:
        return CatalogKind.symptom;
      case 2:
        return CatalogKind.relief;
      default:
        return CatalogKind.trigger;
    }
  }

  @override
  void write(BinaryWriter writer, CatalogKind obj) {
    switch (obj) {
      case CatalogKind.trigger:
        writer.writeByte(0);
        break;
      case CatalogKind.symptom:
        writer.writeByte(1);
        break;
      case CatalogKind.relief:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatalogKindAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
