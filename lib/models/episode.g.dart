// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episode.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EpisodeAdapter extends TypeAdapter<Episode> {
  @override
  final int typeId = 0;

  @override
  Episode read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Episode(
      id: fields[0] as String,
      startAt: fields[1] as DateTime,
      endAt: fields[2] as DateTime?,
      intensity: fields[3] as int,
      type: fields[4] as EpisodeType,
      locations: (fields[5] as List?)?.cast<String>(),
      triggerIds: (fields[6] as List?)?.cast<String>(),
      symptomIds: (fields[7] as List?)?.cast<String>(),
      reliefIds: (fields[8] as List?)?.cast<String>(),
      meds: (fields[9] as List?)?.cast<MedLog>(),
      notes: fields[10] as String,
      createdAt: fields[11] as DateTime,
      updatedAt: fields[12] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Episode obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.startAt)
      ..writeByte(2)
      ..write(obj.endAt)
      ..writeByte(3)
      ..write(obj.intensity)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.locations)
      ..writeByte(6)
      ..write(obj.triggerIds)
      ..writeByte(7)
      ..write(obj.symptomIds)
      ..writeByte(8)
      ..write(obj.reliefIds)
      ..writeByte(9)
      ..write(obj.meds)
      ..writeByte(10)
      ..write(obj.notes)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EpisodeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
