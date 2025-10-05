// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 3;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      isDarkMode: fields[0] as bool,
      defaultVolume: fields[1] as double,
      defaultVibration: fields[2] as bool,
      defaultSnoozeMinutes: fields[3] as int,
      maxSnoozeCount: fields[4] as int,
      gradualVolumeDefault: fields[5] as bool,
      defaultAlarmSound: fields[6] as String,
      defaultChallengeType: fields[7] as ChallengeType,
      defaultChallengeDifficulty: fields[8] as ChallengeDifficulty,
      enableNotifications: fields[9] as bool,
      preventAppKilling: fields[10] as bool,
      registeredQrCodes: (fields[11] as Map).cast<String, String>(),
      enableStatistics: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.isDarkMode)
      ..writeByte(1)
      ..write(obj.defaultVolume)
      ..writeByte(2)
      ..write(obj.defaultVibration)
      ..writeByte(3)
      ..write(obj.defaultSnoozeMinutes)
      ..writeByte(4)
      ..write(obj.maxSnoozeCount)
      ..writeByte(5)
      ..write(obj.gradualVolumeDefault)
      ..writeByte(6)
      ..write(obj.defaultAlarmSound)
      ..writeByte(7)
      ..write(obj.defaultChallengeType)
      ..writeByte(8)
      ..write(obj.defaultChallengeDifficulty)
      ..writeByte(9)
      ..write(obj.enableNotifications)
      ..writeByte(10)
      ..write(obj.preventAppKilling)
      ..writeByte(11)
      ..write(obj.registeredQrCodes)
      ..writeByte(12)
      ..write(obj.enableStatistics);
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
