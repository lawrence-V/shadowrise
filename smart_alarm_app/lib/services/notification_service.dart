import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:io' show Platform;
import 'dart:typed_data';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    
    // Request permissions
    await requestPermissions();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      defaultPresentAlert: true,
      defaultPresentSound: true,
      defaultPresentBadge: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    _initialized = true;
  }

  static Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.scheduleExactAlarm.request();
      await Permission.notification.request();
    } else if (Platform.isIOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (!_initialized) await init();

    // Android notification details
    final androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      'Smart Alarm',
      channelDescription: 'Smart alarm notifications',
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      showWhen: true,
      when: null,
      playSound: true,
      // Using default sound for now, can add custom sound later
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      ongoing: true,
      autoCancel: false,
    );

    // iOS notification details
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      // Using default sound for now
      categoryIdentifier: 'alarm_category',
      threadIdentifier: 'alarm_thread',
      interruptionLevel: InterruptionLevel.critical,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _convertToTimeZone(scheduledDate),
      notificationDetails,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Handle notification tap/response
  static void _onNotificationResponse(NotificationResponse response) {
    final alarmId = response.payload;
    if (alarmId != null) {
      // Navigate to alarm challenge screen
      _handleAlarmTrigger(alarmId);
    }
  }

  static void _handleAlarmTrigger(String alarmId) {
    // This will be handled by the main app navigation
    // The alarm screen will be shown when the notification is tapped
    // TODO: Navigate to alarm challenge screen
  }

  // Convert DateTime to TZDateTime for scheduling
  static tz.TZDateTime _convertToTimeZone(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }

  // Show immediate notification (for testing)
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await init();

    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Test notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Create notification channels (Android)
  static Future<void> createNotificationChannels() async {
    if (Platform.isAndroid) {
      const alarmChannel = AndroidNotificationChannel(
        'alarm_channel',
        'Smart Alarm',
        description: 'Smart alarm notifications',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
      );

      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(alarmChannel);
    }
  }
}

