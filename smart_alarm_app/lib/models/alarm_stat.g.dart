// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm_stat.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlarmStatAdapter extends TypeAdapter<AlarmStat> {
  @override
  final int typeId = 4;

  @override
  AlarmStat read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AlarmStat(
      id: fields[0] as String,
      alarmId: fields[1] as String,
      triggerTime: fields[2] as DateTime,
      completionTime: fields[3] as DateTime?,
      snoozeCount: fields[4] as int,
      challengeType: fields[5] as ChallengeType,
      challengeDifficulty: fields[6] as ChallengeDifficulty,
      wasCompleted: fields[7] as bool,
      challengeAttempts: fields[8] as int,
      completionDuration: fields[9] as Duration?,
      challengeData: (fields[10] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, AlarmStat obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.alarmId)
      ..writeByte(2)
      ..write(obj.triggerTime)
      ..writeByte(3)
      ..write(obj.completionTime)
      ..writeByte(4)
      ..write(obj.snoozeCount)
      ..writeByte(5)
      ..write(obj.challengeType)
      ..writeByte(6)
      ..write(obj.challengeDifficulty)
      ..writeByte(7)
      ..write(obj.wasCompleted)
      ..writeByte(8)
      ..write(obj.challengeAttempts)
      ..writeByte(9)
      ..write(obj.completionDuration)
      ..writeByte(10)
      ..write(obj.challengeData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlarmStatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
