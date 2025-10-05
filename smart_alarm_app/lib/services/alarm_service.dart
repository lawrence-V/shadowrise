import 'dart:math';
import '../models/alarm.dart';
import '../models/enums.dart';
import 'database_service.dart';
import 'notification_service.dart';

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  // Create a new alarm
  Future<Alarm> createAlarm({
    required String label,
    required DateTime time,
    List<int> repeatDays = const [],
    bool isEnabled = true,
    String alarmSound = 'default',
    double volume = 0.8,
    bool vibration = true,
    int snoozeMinutes = 5,
    bool gradualVolumeIncrease = false,
    ChallengeType challengeType = ChallengeType.math,
    ChallengeDifficulty challengeDifficulty = ChallengeDifficulty.easy,
    Map<String, dynamic> challengeConfig = const {},
    bool noEscapeMode = false,
  }) async {
    final alarm = Alarm(
      id: _generateAlarmId(),
      label: label,
      time: time,
      repeatDays: repeatDays,
      isEnabled: isEnabled,
      alarmSound: alarmSound,
      volume: volume,
      vibration: vibration,
      snoozeMinutes: snoozeMinutes,
      gradualVolumeIncrease: gradualVolumeIncrease,
      challengeType: challengeType,
      challengeDifficulty: challengeDifficulty,
      challengeConfig: challengeConfig,
      noEscapeMode: noEscapeMode,
    );

    alarm.updateNextTriggerTime();
    await DatabaseService.saveAlarm(alarm);
    
    if (alarm.isEnabled) {
      await _scheduleAlarm(alarm);
    }
    
    return alarm;
  }

  // Update an existing alarm
  Future<void> updateAlarm(Alarm alarm) async {
    alarm.updateNextTriggerTime();
    await DatabaseService.saveAlarm(alarm);
    
    // Cancel existing notification
    await NotificationService.cancelNotification(alarm.id.hashCode);
    
    // Schedule new notification if enabled
    if (alarm.isEnabled) {
      await _scheduleAlarm(alarm);
    }
  }

  // Delete an alarm
  Future<void> deleteAlarm(String alarmId) async {
    await DatabaseService.deleteAlarm(alarmId);
    await NotificationService.cancelNotification(alarmId.hashCode);
  }

  // Toggle alarm on/off
  Future<void> toggleAlarm(Alarm alarm) async {
    alarm.isEnabled = !alarm.isEnabled;
    await updateAlarm(alarm);
  }

  // Get all alarms
  List<Alarm> getAllAlarms() {
    return DatabaseService.getAllAlarms()
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  // Get enabled alarms
  List<Alarm> getEnabledAlarms() {
    return getAllAlarms().where((alarm) => alarm.isEnabled).toList();
  }

  // Get next alarm to trigger
  Alarm? getNextAlarm() {
    final enabledAlarms = getEnabledAlarms();
    if (enabledAlarms.isEmpty) return null;
    
    enabledAlarms.sort((a, b) => 
      (a.nextTriggerTime ?? DateTime.now()).compareTo(
        b.nextTriggerTime ?? DateTime.now()
      )
    );
    
    return enabledAlarms.first;
  }

  // Schedule alarm notification
  Future<void> _scheduleAlarm(Alarm alarm) async {
    if (alarm.nextTriggerTime == null) return;
    
    try {
      await NotificationService.scheduleNotification(
        id: alarm.id.hashCode,
        title: 'Smart Alarm',
        body: alarm.label.isNotEmpty ? alarm.label : 'Time to wake up!',
        scheduledDate: alarm.nextTriggerTime!,
        payload: alarm.id,
      );
      print('Notification scheduled successfully for alarm ${alarm.id}');
    } catch (e) {
      print('Failed to schedule notification for alarm ${alarm.id}: $e');
      // Don't rethrow - alarm should still be saved even if notification fails
    }
  }

  // Reschedule all enabled alarms (useful after device reboot)
  Future<void> rescheduleAllAlarms() async {
    final enabledAlarms = getEnabledAlarms();
    
    for (final alarm in enabledAlarms) {
      alarm.updateNextTriggerTime();
      await _scheduleAlarm(alarm);
      await DatabaseService.saveAlarm(alarm);
    }
  }

  // Snooze an alarm
  Future<void> snoozeAlarm(Alarm alarm) async {
    final snoozeTime = DateTime.now().add(Duration(minutes: alarm.snoozeMinutes));
    
    await NotificationService.scheduleNotification(
      id: alarm.id.hashCode,
      title: 'Smart Alarm (Snoozed)',
      body: alarm.label.isNotEmpty ? alarm.label : 'Time to wake up!',
      scheduledDate: snoozeTime,
      payload: alarm.id,
    );
  }

  // Generate unique alarm ID
  String _generateAlarmId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           Random().nextInt(1000).toString();
  }

  // Validate alarm configuration
  bool validateAlarm(Alarm alarm) {
    // Basic validation
    if (alarm.volume < 0 || alarm.volume > 1) return false;
    if (alarm.snoozeMinutes <= 0) return false;
    
    // Challenge-specific validation
    switch (alarm.challengeType) {
      case ChallengeType.qrCode:
        final qrCodes = DatabaseService.getSettings().registeredQrCodes;
        return qrCodes.isNotEmpty;
      default:
        return true;
    }
  }

  // Get default challenge config based on type and difficulty
  Map<String, dynamic> getDefaultChallengeConfig(
    ChallengeType type,
    ChallengeDifficulty difficulty,
  ) {
    switch (type) {
      case ChallengeType.math:
        return {
          'problemCount': difficulty == ChallengeDifficulty.easy ? 1 : 
                         difficulty == ChallengeDifficulty.medium ? 2 : 3,
          'operations': difficulty == ChallengeDifficulty.easy ? ['+', '-'] :
                       difficulty == ChallengeDifficulty.medium ? ['+', '-', '*'] :
                       ['+', '-', '*', '/'],
          'maxNumber': difficulty == ChallengeDifficulty.easy ? 20 :
                      difficulty == ChallengeDifficulty.medium ? 50 : 100,
        };
      
      case ChallengeType.shake:
        return {
          'requiredShakes': difficulty == ChallengeDifficulty.easy ? 10 :
                           difficulty == ChallengeDifficulty.medium ? 20 : 30,
          'timeLimit': 30, // seconds
        };
      
      case ChallengeType.memoryGame:
        return {
          'sequenceLength': difficulty == ChallengeDifficulty.easy ? 3 :
                           difficulty == ChallengeDifficulty.medium ? 5 : 7,
          'showTime': 2, // seconds per item
        };
      
      case ChallengeType.qrCode:
        return {
          'timeLimit': 60, // seconds
        };
      
      case ChallengeType.random:
        return {};
    }
  }
}