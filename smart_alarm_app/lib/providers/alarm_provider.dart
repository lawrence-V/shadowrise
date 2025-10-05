import 'package:flutter/foundation.dart';
import '../models/alarm.dart';
import '../models/settings.dart';
import '../models/alarm_stat.dart';
import '../services/database_service.dart';
import '../services/alarm_service.dart';
import '../services/notification_service.dart';
import '../services/native_alarm_scheduler.dart';
import 'dart:io' show Platform;

class AlarmProvider extends ChangeNotifier {
  final AlarmService _alarmService = AlarmService();
  
  List<Alarm> _alarms = [];
  AppSettings _settings = AppSettings();
  List<AlarmStat> _stats = [];

  List<Alarm> get alarms => _alarms;
  AppSettings get settings => _settings;
  List<AlarmStat> get stats => _stats;

  AlarmProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    _alarms = _alarmService.getAllAlarms();
    _settings = DatabaseService.getSettings();
    _stats = DatabaseService.getAllStats();
    notifyListeners();
  }

  // Alarm operations
  Future<void> addAlarm(Alarm alarm) async {
    try {
      print('Adding alarm: ${alarm.id} - ${alarm.label}');
      
      // Update next trigger time before saving
      alarm.updateNextTriggerTime();
      print('Next trigger time: ${alarm.nextTriggerTime}');
      
      // Save to database
      await DatabaseService.saveAlarm(alarm);
      print('Saved to database');
      
      // Add to local list
      _alarms.add(alarm);
      _sortAlarms();
      print('Added to local list: ${_alarms.length} alarms total');
      
      // Schedule alarm using native AlarmManager (works even when app is closed)
      if (alarm.isEnabled && Platform.isAndroid) {
        try {
          await NativeAlarmScheduler.scheduleAlarm(
            id: alarm.id.hashCode,
            label: alarm.label.isNotEmpty ? alarm.label : 'Wake up!',
            scheduledTime: alarm.nextTriggerTime!,
          );
          print('✅ Native alarm scheduled successfully!');
        } catch (e) {
          print('❌ Failed to schedule native alarm: $e');
          // Fallback to regular notifications
          try {
            await NotificationService.scheduleNotification(
              id: alarm.id.hashCode,
              title: 'Smart Alarm',
              body: alarm.label.isNotEmpty ? alarm.label : 'Time to wake up!',
              scheduledDate: alarm.nextTriggerTime!,
              payload: alarm.id,
            );
            print('⚠️ Fallback: Regular notification scheduled');
          } catch (e2) {
            print('❌ Failed to schedule fallback notification: $e2');
          }
        }
      } else if (alarm.isEnabled) {
        // For iOS or other platforms, use regular notifications
        try {
          await NotificationService.scheduleNotification(
            id: alarm.id.hashCode,
            title: 'Smart Alarm',
            body: alarm.label.isNotEmpty ? alarm.label : 'Time to wake up!',
            scheduledDate: alarm.nextTriggerTime!,
            payload: alarm.id,
          );
          print('Notification scheduled');
        } catch (e) {
          print('Failed to schedule notification: $e');
        }
      }
      
      notifyListeners();
      print('Listeners notified');
    } catch (e) {
      print('Error adding alarm: $e');
      rethrow;
    }
  }

  Future<void> updateAlarm(Alarm alarm) async {
    print('Updating alarm: ${alarm.id} - ${alarm.label}');
    
    // Cancel old alarm first
    if (Platform.isAndroid) {
      try {
        await NativeAlarmScheduler.cancelAlarm(alarm.id.hashCode);
        print('✅ Old native alarm cancelled');
      } catch (e) {
        print('⚠️ Failed to cancel old native alarm: $e');
      }
    }
    
    // Update next trigger time
    alarm.updateNextTriggerTime();
    print('Next trigger time: ${alarm.nextTriggerTime}');
    
    // Update in database
    await _alarmService.updateAlarm(alarm);
    
    // Update local list
    final index = _alarms.indexWhere((a) => a.id == alarm.id);
    if (index != -1) {
      _alarms[index] = alarm;
      _sortAlarms();
    }
    
    // Reschedule with new time if enabled
    if (alarm.isEnabled && Platform.isAndroid) {
      try {
        await NativeAlarmScheduler.scheduleAlarm(
          id: alarm.id.hashCode,
          label: alarm.label.isNotEmpty ? alarm.label : 'Wake up!',
          scheduledTime: alarm.nextTriggerTime!,
        );
        print('✅ Native alarm rescheduled successfully!');
      } catch (e) {
        print('❌ Failed to reschedule native alarm: $e');
      }
    } else if (alarm.isEnabled) {
      // For iOS or other platforms
      try {
        await NotificationService.scheduleNotification(
          id: alarm.id.hashCode,
          title: 'Smart Alarm',
          body: alarm.label.isNotEmpty ? alarm.label : 'Time to wake up!',
          scheduledDate: alarm.nextTriggerTime!,
          payload: alarm.id,
        );
        print('Notification rescheduled');
      } catch (e) {
        print('Failed to reschedule notification: $e');
      }
    }
    
    notifyListeners();
    print('Alarm update complete');
  }

  Future<void> deleteAlarm(String alarmId) async {
    // Cancel the native alarm first
    if (Platform.isAndroid) {
      try {
        await NativeAlarmScheduler.cancelAlarm(alarmId.hashCode);
        print('✅ Native alarm cancelled');
      } catch (e) {
        print('⚠️ Failed to cancel native alarm: $e');
      }
    }
    
    // Cancel notification
    try {
      await NotificationService.cancelNotification(alarmId.hashCode);
    } catch (e) {
      print('⚠️ Failed to cancel notification: $e');
    }
    
    await _alarmService.deleteAlarm(alarmId);
    _alarms.removeWhere((alarm) => alarm.id == alarmId);
    notifyListeners();
  }

  Future<void> toggleAlarm(String alarmId) async {
    final alarm = _alarms.firstWhere((a) => a.id == alarmId);
    await _alarmService.toggleAlarm(alarm);
    notifyListeners();
  }

  void _sortAlarms() {
    _alarms.sort((a, b) => a.time.compareTo(b.time));
  }

  // Settings operations
  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    await DatabaseService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _settings = _settings.copyWith(isDarkMode: !_settings.isDarkMode);
    await DatabaseService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> addQrCode(String name, String qrData) async {
    final newQrCodes = Map<String, String>.from(_settings.registeredQrCodes);
    newQrCodes[name] = qrData;
    _settings = _settings.copyWith(registeredQrCodes: newQrCodes);
    await DatabaseService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> removeQrCode(String name) async {
    final newQrCodes = Map<String, String>.from(_settings.registeredQrCodes);
    newQrCodes.remove(name);
    _settings = _settings.copyWith(registeredQrCodes: newQrCodes);
    await DatabaseService.saveSettings(_settings);
    notifyListeners();
  }

  // Statistics operations
  Future<void> addAlarmStat(AlarmStat stat) async {
    await DatabaseService.saveStat(stat);
    _stats.add(stat);
    notifyListeners();
  }

  List<AlarmStat> getStatsForAlarm(String alarmId) {
    return _stats.where((stat) => stat.alarmId == alarmId).toList();
  }

  // Analytics methods
  double get overallSuccessRate {
    if (_stats.isEmpty) return 0.0;
    final completedCount = _stats.where((stat) => stat.wasCompleted).length;
    return completedCount / _stats.length;
  }

  double get averageCompletionTime {
    final completedStats = _stats.where((stat) => 
        stat.wasCompleted && stat.completionDuration != null).toList();
    
    if (completedStats.isEmpty) return 0.0;
    
    final totalMinutes = completedStats
        .map((stat) => stat.completionDuration!.inMinutes)
        .reduce((a, b) => a + b);
    
    return totalMinutes / completedStats.length;
  }

  int get totalAlarmsTriggered => _stats.length;

  int get totalSnoozes => _stats.isEmpty ? 0 : _stats.map((stat) => stat.snoozeCount).reduce((a, b) => a + b);

  // Utility methods
  Alarm? getNextAlarm() {
    return _alarmService.getNextAlarm();
  }

  List<Alarm> getEnabledAlarms() {
    return _alarms.where((alarm) => alarm.isEnabled).toList();
  }

  Future<void> rescheduleAllAlarms() async {
    await _alarmService.rescheduleAllAlarms();
    await _loadData();
  }

  Future<void> clearAllData() async {
    await DatabaseService.clearAllData();
    _alarms.clear();
    _stats.clear();
    _settings = AppSettings();
    notifyListeners();
  }
}