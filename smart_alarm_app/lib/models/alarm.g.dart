// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlarmAdapter extends TypeAdapter<Alarm> {
  @override
  final int typeId = 0;

  @override
  Alarm read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Alarm(
      id: fields[0] as String,
      label: fields[1] as String,
      time: fields[2] as DateTime,
      repeatDays: (fields[3] as List).cast<int>(),
      isEnabled: fields[4] as bool,
      alarmSound: fields[5] as String,
      volume: fields[6] as double,
      vibration: fields[7] as bool,
      snoozeMinutes: fields[8] as int,
      gradualVolumeIncrease: fields[9] as bool,
      challengeType: fields[10] as ChallengeType,
      challengeDifficulty: fields[11] as ChallengeDifficulty,
      challengeConfig: (fields[12] as Map).cast<String, dynamic>(),
      noEscapeMode: fields[13] as bool,
      nextTriggerTime: fields[14] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Alarm obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.time)
      ..writeByte(3)
      ..write(obj.repeatDays)
      ..writeByte(4)
      ..write(obj.isEnabled)
      ..writeByte(5)
      ..write(obj.alarmSound)
      ..writeByte(6)
      ..write(obj.volume)
      ..writeByte(7)
      ..write(obj.vibration)
      ..writeByte(8)
      ..write(obj.snoozeMinutes)
      ..writeByte(9)
      ..write(obj.gradualVolumeIncrease)
      ..writeByte(10)
      ..write(obj.challengeType)
      ..writeByte(11)
      ..write(obj.challengeDifficulty)
      ..writeByte(12)
      ..write(obj.challengeConfig)
      ..writeByte(13)
      ..write(obj.noEscapeMode)
      ..writeByte(14)
      ..write(obj.nextTriggerTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlarmAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
