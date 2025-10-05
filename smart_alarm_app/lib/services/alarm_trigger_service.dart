import 'dart:async';
import 'package:flutter/material.dart';
import '../models/alarm.dart';
import '../providers/alarm_provider.dart';
import '../screens/alarm_ringing_screen.dart';

/// Global service that checks for due alarms and triggers them
/// This runs independently of which screen is currently visible
class AlarmTriggerService {
  static AlarmTriggerService? _instance;
  static AlarmTriggerService get instance {
    _instance ??= AlarmTriggerService._();
    return _instance!;
  }

  AlarmTriggerService._();

  Timer? _checkTimer;
  DateTime? _lastCheckedMinute;
  AlarmProvider? _alarmProvider;
  BuildContext? _context;

  /// Initialize the service with context and alarm provider
  void initialize(BuildContext context, AlarmProvider alarmProvider) {
    print('🚀 AlarmTriggerService: Initializing...');
    _context = context;
    _alarmProvider = alarmProvider;
    start();
  }

  /// Start the alarm checking timer
  void start() {
    if (_checkTimer != null && _checkTimer!.isActive) {
      print('⏰ AlarmTriggerService: Already running');
      return;
    }

    print('⏰ AlarmTriggerService: Starting alarm check timer (every 5 seconds)');
    _checkTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkForDueAlarms();
    });

    // Do an immediate check
    Future.delayed(const Duration(seconds: 1), () {
      _checkForDueAlarms();
    });
  }

  /// Stop the alarm checking timer
  void stop() {
    print('🛑 AlarmTriggerService: Stopping alarm check timer');
    _checkTimer?.cancel();
    _checkTimer = null;
  }

  /// Check if any alarms are due and trigger them
  void _checkForDueAlarms() {
    if (_alarmProvider == null || _context == null) {
      print('⚠️ AlarmTriggerService: Not initialized properly');
      return;
    }

    final now = DateTime.now();
    print('⏰ AlarmTriggerService: Checking alarms at ${now.hour}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}');

    // Only check once per minute to avoid duplicate triggers
    if (_lastCheckedMinute != null &&
        _lastCheckedMinute!.year == now.year &&
        _lastCheckedMinute!.month == now.month &&
        _lastCheckedMinute!.day == now.day &&
        _lastCheckedMinute!.hour == now.hour &&
        _lastCheckedMinute!.minute == now.minute) {
      print('⏭️ AlarmTriggerService: Already checked this minute');
      return;
    }

    final alarms = _alarmProvider!.alarms;
    print('📋 AlarmTriggerService: Checking ${alarms.length} alarm(s)');

    // Check each enabled alarm
    for (int i = 0; i < alarms.length; i++) {
      final alarm = alarms[i];
      print('  [$i] "${alarm.label}" - ${alarm.time.hour}:${alarm.time.minute.toString().padLeft(2, '0')} (enabled: ${alarm.isEnabled})');

      if (!alarm.isEnabled) {
        print('    ⏸️ Skipped (disabled)');
        continue;
      }

      // Check if alarm time matches current time (within the same minute)
      if (alarm.time.hour == now.hour && alarm.time.minute == now.minute) {
        print('    ⏰ TIME MATCH! Checking repeat days...');

        // Check if it should trigger today (for repeating alarms)
        if (alarm.repeatDays.isNotEmpty) {
          final todayWeekday = now.weekday % 7; // Convert to 0-6 (Sun=0)
          print('    Today is weekday $todayWeekday, alarm repeats on: ${alarm.repeatDays}');
          if (!alarm.repeatDays.contains(todayWeekday)) {
            print('    ⏭️ Skipped (not scheduled for today)');
            continue;
          }
        }

        print('🔔🔔🔔 AlarmTriggerService: TRIGGERING ALARM "${alarm.label}" 🔔🔔🔔');
        _lastCheckedMinute = now;
        _triggerAlarm(alarm);
        break; // Only trigger one alarm at a time
      } else {
        print('    ⏭️ Time mismatch');
      }
    }
  }

  /// Trigger an alarm by navigating to the alarm ringing screen
  void _triggerAlarm(Alarm alarm) {
    if (_context == null) {
      print('❌ AlarmTriggerService: Cannot trigger alarm - context is null');
      return;
    }

    print('📱 AlarmTriggerService: Navigating to alarm ringing screen');
    Navigator.of(_context!).push(
      MaterialPageRoute(
        builder: (context) => AlarmRingingScreen(alarm: alarm),
        fullscreenDialog: true,
      ),
    );
  }

  /// Dispose of the service
  void dispose() {
    print('🗑️ AlarmTriggerService: Disposing');
    stop();
    _context = null;
    _alarmProvider = null;
  }
}