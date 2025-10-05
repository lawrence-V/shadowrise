import 'package:hive/hive.dart';
import 'enums.dart';

part 'alarm_stat.g.dart';

@HiveType(typeId: 4)
class AlarmStat extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String alarmId;

  @HiveField(2)
  DateTime triggerTime;

  @HiveField(3)
  DateTime? completionTime;

  @HiveField(4)
  int snoozeCount;

  @HiveField(5)
  ChallengeType challengeType;

  @HiveField(6)
  ChallengeDifficulty challengeDifficulty;

  @HiveField(7)
  bool wasCompleted;

  @HiveField(8)
  int challengeAttempts;

  @HiveField(9)
  Duration? completionDuration;

  @HiveField(10)
  Map<String, dynamic> challengeData; // Store challenge-specific data

  AlarmStat({
    required this.id,
    required this.alarmId,
    required this.triggerTime,
    this.completionTime,
    this.snoozeCount = 0,
    required this.challengeType,
    required this.challengeDifficulty,
    this.wasCompleted = false,
    this.challengeAttempts = 0,
    this.completionDuration,
    this.challengeData = const {},
  });

  void markCompleted() {
    wasCompleted = true;
    completionTime = DateTime.now();
    completionDuration = completionTime!.difference(triggerTime);
  }

  void incrementSnooze() {
    snoozeCount++;
  }

  void incrementChallengeAttempt() {
    challengeAttempts++;
  }

  // Calculate success rate based on completion vs attempts
  double get successRate {
    if (challengeAttempts == 0) return 0.0;
    return wasCompleted ? 1.0 : 0.0;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'alarmId': alarmId,
    'triggerTime': triggerTime.toIso8601String(),
    'completionTime': completionTime?.toIso8601String(),
    'snoozeCount': snoozeCount,
    'challengeType': challengeType.index,
    'challengeDifficulty': challengeDifficulty.index,
    'wasCompleted': wasCompleted,
    'challengeAttempts': challengeAttempts,
    'completionDuration': completionDuration?.inMilliseconds,
    'challengeData': challengeData,
  };
}

