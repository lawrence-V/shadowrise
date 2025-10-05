// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enums.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChallengeTypeAdapter extends TypeAdapter<ChallengeType> {
  @override
  final int typeId = 1;

  @override
  ChallengeType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ChallengeType.math;
      case 1:
        return ChallengeType.qrCode;
      case 2:
        return ChallengeType.memoryGame;
      case 3:
        return ChallengeType.shake;
      case 4:
        return ChallengeType.random;
      default:
        return ChallengeType.math;
    }
  }

  @override
  void write(BinaryWriter writer, ChallengeType obj) {
    switch (obj) {
      case ChallengeType.math:
        writer.writeByte(0);
        break;
      case ChallengeType.qrCode:
        writer.writeByte(1);
        break;
      case ChallengeType.memoryGame:
        writer.writeByte(2);
        break;
      case ChallengeType.shake:
        writer.writeByte(3);
        break;
      case ChallengeType.random:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChallengeDifficultyAdapter extends TypeAdapter<ChallengeDifficulty> {
  @override
  final int typeId = 2;

  @override
  ChallengeDifficulty read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ChallengeDifficulty.easy;
      case 1:
        return ChallengeDifficulty.medium;
      case 2:
        return ChallengeDifficulty.hard;
      default:
        return ChallengeDifficulty.easy;
    }
  }

  @override
  void write(BinaryWriter writer, ChallengeDifficulty obj) {
    switch (obj) {
      case ChallengeDifficulty.easy:
        writer.writeByte(0);
        break;
      case ChallengeDifficulty.medium:
        writer.writeByte(1);
        break;
      case ChallengeDifficulty.hard:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeDifficultyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
