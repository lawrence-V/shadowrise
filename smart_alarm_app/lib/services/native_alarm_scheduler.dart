import 'package:flutter/services.dart';
import 'dart:io' show Platform;

/// Service to schedule alarms using native Android AlarmManager
/// This allows alarms to trigger even when the app is closed or phone is sleeping
class NativeAlarmScheduler {
  static const MethodChannel _channel = MethodChannel('com.example.smart_alarm_app/alarm');

  /// Schedule an exact alarm using Android's AlarmManager
  /// Returns true if successful, throws an exception otherwise
  static Future<bool> scheduleAlarm({
    required int id,
    required String label,
    required DateTime scheduledTime,
  }) async {
    if (!Platform.isAndroid) {
      print('⚠️ Native alarm scheduling is only supported on Android');
      return false;
    }

    try {
      final triggerTimeMillis = scheduledTime.millisecondsSinceEpoch;
      
      print('📱 NativeAlarmScheduler: Scheduling alarm via platform channel');
      print('   ID: $id');
      print('   Label: $label');
      print('   Time: $scheduledTime');
      print('   Millis: $triggerTimeMillis');

      final result = await _channel.invokeMethod('scheduleAlarm', {
        'id': id,
        'label': label,
        'triggerTime': triggerTimeMillis,
      });

      print('✅ Native alarm scheduled successfully: $result');
      return result == true;
    } on PlatformException catch (e) {
      print('❌ Failed to schedule native alarm: ${e.code} - ${e.message}');
      throw Exception('Failed to schedule alarm: ${e.message}');
    } catch (e) {
      print('❌ Unexpected error scheduling native alarm: $e');
      throw Exception('Failed to schedule alarm: $e');
    }
  }

  /// Cancel a scheduled alarm
  static Future<bool> cancelAlarm(int id) async {
    if (!Platform.isAndroid) {
      print('⚠️ Native alarm scheduling is only supported on Android');
      return false;
    }

    try {
      print('📱 NativeAlarmScheduler: Cancelling alarm ID: $id');
      
      final result = await _channel.invokeMethod('cancelAlarm', {
        'id': id,
      });

      print('✅ Native alarm cancelled: $result');
      return result == true;
    } on PlatformException catch (e) {
      print('❌ Failed to cancel native alarm: ${e.code} - ${e.message}');
      throw Exception('Failed to cancel alarm: ${e.message}');
    } catch (e) {
      print('❌ Unexpected error cancelling native alarm: $e');
      throw Exception('Failed to cancel alarm: $e');
    }
  }
}
