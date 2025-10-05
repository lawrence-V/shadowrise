import 'package:hive/hive.dart';

part 'enums.g.dart';

@HiveType(typeId: 1)
enum ChallengeType {
  @HiveField(0)
  math,
  @HiveField(1)
  qrCode,
  @HiveField(2)
  memoryGame,
  @HiveField(3)
  shake,
  @HiveField(4)
  random,
}

@HiveType(typeId: 2)
enum ChallengeDifficulty {
  @HiveField(0)
  easy,
  @HiveField(1)
  medium,
  @HiveField(2)
  hard,
}

extension ChallengeTypeExtension on ChallengeType {
  String get displayName {
    switch (this) {
      case ChallengeType.math:
        return 'Math Problem';
      case ChallengeType.qrCode:
        return 'QR Scan';
      case ChallengeType.memoryGame:
        return 'Memory Game';
      case ChallengeType.shake:
        return 'Shake Phone';
      case ChallengeType.random:
        return 'Random Task';
    }
  }

  String get description {
    switch (this) {
      case ChallengeType.math:
        return 'Solve arithmetic problems';
      case ChallengeType.qrCode:
        return 'Scan QR to dismiss';
      case ChallengeType.memoryGame:
        return 'Pattern repeat';
      case ChallengeType.shake:
        return 'Shake to wake';
      case ChallengeType.random:
        return 'Random challenge';
    }
  }
}

extension ChallengeDifficultyExtension on ChallengeDifficulty {
  String get displayName {
    switch (this) {
      case ChallengeDifficulty.easy:
        return 'Easy';
      case ChallengeDifficulty.medium:
        return 'Medium';
      case ChallengeDifficulty.hard:
        return 'Hard';
    }
  }
}