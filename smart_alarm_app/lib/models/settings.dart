import 'package:hive/hive.dart';
import 'enums.dart';

part 'settings.g.dart';

@HiveType(typeId: 3)
class AppSettings extends HiveObject {
  @HiveField(0)
  bool isDarkMode;

  @HiveField(1)
  double defaultVolume;

  @HiveField(2)
  bool defaultVibration;

  @HiveField(3)
  int defaultSnoozeMinutes;

  @HiveField(4)
  int maxSnoozeCount;

  @HiveField(5)
  bool gradualVolumeDefault;

  @HiveField(6)
  String defaultAlarmSound;

  @HiveField(7)
  ChallengeType defaultChallengeType;

  @HiveField(8)
  ChallengeDifficulty defaultChallengeDifficulty;

  @HiveField(9)
  bool enableNotifications;

  @HiveField(10)
  bool preventAppKilling;

  @HiveField(11)
  Map<String, String> registeredQrCodes; // name -> QR code data

  @HiveField(12)
  bool enableStatistics;

  AppSettings({
    this.isDarkMode = false,
    this.defaultVolume = 0.8,
    this.defaultVibration = true,
    this.defaultSnoozeMinutes = 5,
    this.maxSnoozeCount = 3,
    this.gradualVolumeDefault = false,
    this.defaultAlarmSound = 'default',
    this.defaultChallengeType = ChallengeType.math,
    this.defaultChallengeDifficulty = ChallengeDifficulty.easy,
    this.enableNotifications = true,
    this.preventAppKilling = true,
    this.registeredQrCodes = const {},
    this.enableStatistics = true,
  });

  AppSettings copyWith({
    bool? isDarkMode,
    double? defaultVolume,
    bool? defaultVibration,
    int? defaultSnoozeMinutes,
    int? maxSnoozeCount,
    bool? gradualVolumeDefault,
    String? defaultAlarmSound,
    ChallengeType? defaultChallengeType,
    ChallengeDifficulty? defaultChallengeDifficulty,
    bool? enableNotifications,
    bool? preventAppKilling,
    Map<String, String>? registeredQrCodes,
    bool? enableStatistics,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      defaultVolume: defaultVolume ?? this.defaultVolume,
      defaultVibration: defaultVibration ?? this.defaultVibration,
      defaultSnoozeMinutes: defaultSnoozeMinutes ?? this.defaultSnoozeMinutes,
      maxSnoozeCount: maxSnoozeCount ?? this.maxSnoozeCount,
      gradualVolumeDefault: gradualVolumeDefault ?? this.gradualVolumeDefault,
      defaultAlarmSound: defaultAlarmSound ?? this.defaultAlarmSound,
      defaultChallengeType: defaultChallengeType ?? this.defaultChallengeType,
      defaultChallengeDifficulty: defaultChallengeDifficulty ?? this.defaultChallengeDifficulty,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      preventAppKilling: preventAppKilling ?? this.preventAppKilling,
      registeredQrCodes: registeredQrCodes ?? Map.from(this.registeredQrCodes),
      enableStatistics: enableStatistics ?? this.enableStatistics,
    );
  }
}

