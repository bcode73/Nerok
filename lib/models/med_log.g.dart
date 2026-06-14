// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'med_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedLogAdapter extends TypeAdapter<MedLog> {
  @override
  final int typeId = 1;

  @override
  MedLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedLog(
      medId: fields[0] as String,
      name: fields[1] as String,
      doseMg: fields[2] as double?,
      takenAt: fields[3] as DateTime,
      effectiveness: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, MedLog obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.medId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.doseMg)
      ..writeByte(3)
      ..write(obj.takenAt)
      ..writeByte(4)
      ..write(obj.effectiveness);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
