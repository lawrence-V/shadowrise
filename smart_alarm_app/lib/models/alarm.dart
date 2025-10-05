import 'package:hive/hive.dart';
import 'enums.dart';

part 'alarm.g.dart';

@HiveType(typeId: 0)
class Alarm extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String label;

  @HiveField(2)
  DateTime time;

  @HiveField(3)
  List<int> repeatDays; // 0 = Sunday, 1 = Monday, etc.

  @HiveField(4)
  bool isEnabled;

  @HiveField(5)
  String alarmSound;

  @HiveField(6)
  double volume;

  @HiveField(7)
  bool vibration;

  @HiveField(8)
  int snoozeMinutes;

  @HiveField(9)
  bool gradualVolumeIncrease;

  @HiveField(10)
  ChallengeType challengeType;

  @HiveField(11)
  ChallengeDifficulty challengeDifficulty;

  @HiveField(12)
  Map<String, dynamic> challengeConfig;

  @HiveField(13)
  bool noEscapeMode;

  @HiveField(14)
  DateTime? nextTriggerTime;

  Alarm({
    required this.id,
    required this.label,
    required this.time,
    this.repeatDays = const [],
    this.isEnabled = true,
    this.alarmSound = 'default',
    this.volume = 0.8,
    this.vibration = true,
    this.snoozeMinutes = 5,
    this.gradualVolumeIncrease = false,
    this.challengeType = ChallengeType.math,
    this.challengeDifficulty = ChallengeDifficulty.easy,
    this.challengeConfig = const {},
    this.noEscapeMode = false,
    this.nextTriggerTime,
  });

  // Calculate next trigger time based on current time and repeat settings
  void updateNextTriggerTime() {
    final now = DateTime.now();
    final alarmTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (repeatDays.isEmpty) {
      // One-time alarm
      nextTriggerTime = alarmTime.isAfter(now) ? alarmTime : alarmTime.add(const Duration(days: 1));
    } else {
      // Recurring alarm
      DateTime nextAlarm = alarmTime;
      
      // If today's alarm time has passed, start from tomorrow
      if (alarmTime.isBefore(now) || alarmTime.isAtSameMomentAs(now)) {
        nextAlarm = nextAlarm.add(const Duration(days: 1));
      }

      // Find the next day that matches our repeat schedule
      while (!repeatDays.contains(nextAlarm.weekday % 7)) {
        nextAlarm = nextAlarm.add(const Duration(days: 1));
      }

      nextTriggerTime = nextAlarm;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'time': time.toIso8601String(),
    'repeatDays': repeatDays,
    'isEnabled': isEnabled,
    'alarmSound': alarmSound,
    'volume': volume,
    'vibration': vibration,
    'snoozeMinutes': snoozeMinutes,
    'gradualVolumeIncrease': gradualVolumeIncrease,
    'challengeType': challengeType.index,
    'challengeDifficulty': challengeDifficulty.index,
    'challengeConfig': challengeConfig,
    'noEscapeMode': noEscapeMode,
    'nextTriggerTime': nextTriggerTime?.toIso8601String(),
  };
}

