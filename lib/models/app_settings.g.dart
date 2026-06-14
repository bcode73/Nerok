// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 4;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      onboardingDone: fields[0] as bool,
      reminderEnabled: fields[1] as bool,
      reminderHour: fields[2] as int,
      reminderMinute: fields[3] as int,
      patientName: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.onboardingDone)
      ..writeByte(1)
      ..write(obj.reminderEnabled)
      ..writeByte(2)
      ..write(obj.reminderHour)
      ..writeByte(3)
      ..write(obj.reminderMinute)
      ..writeByte(4)
      ..write(obj.patientName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
