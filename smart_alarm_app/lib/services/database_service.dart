import 'package:hive_flutter/hive_flutter.dart';
import '../models/alarm.dart';
import '../models/settings.dart';
import '../models/alarm_stat.dart';
import '../models/enums.dart';

class DatabaseService {
  static const String _alarmsBoxName = 'alarms';
  static const String _settingsBoxName = 'settings';
  static const String _statsBoxName = 'statistics';

  static Box<Alarm>? _alarmsBox;
  static Box<AppSettings>? _settingsBox;
  static Box<AlarmStat>? _statsBox;

  // Getters for boxes
  static Box<Alarm> get alarmsBox {
    if (_alarmsBox == null) {
      throw Exception('Alarms box not initialized. Call DatabaseService.init() first.');
    }
    return _alarmsBox!;
  }

  static Box<AppSettings> get settingsBox {
    if (_settingsBox == null) {
      throw Exception('Settings box not initialized. Call DatabaseService.init() first.');
    }
    return _settingsBox!;
  }

  static Box<AlarmStat> get statsBox {
    if (_statsBox == null) {
      throw Exception('Statistics box not initialized. Call DatabaseService.init() first.');
    }
    return _statsBox!;
  }

  static Future<void> init() async {
    // Initialize Hive
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AlarmAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ChallengeTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ChallengeDifficultyAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(AppSettingsAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(AlarmStatAdapter());
    }

    // Open boxes
    _alarmsBox = await Hive.openBox<Alarm>(_alarmsBoxName);
    _settingsBox = await Hive.openBox<AppSettings>(_settingsBoxName);
    _statsBox = await Hive.openBox<AlarmStat>(_statsBoxName);

    // Initialize default settings if not exists
    if (_settingsBox!.isEmpty) {
      await _settingsBox!.put('default', AppSettings());
    }
  }

  static Future<void> close() async {
    await _alarmsBox?.close();
    await _settingsBox?.close();
    await _statsBox?.close();
  }

  // Convenience methods for common operations
  static AppSettings getSettings() {
    return settingsBox.get('default') ?? AppSettings();
  }

  static Future<void> saveSettings(AppSettings settings) async {
    await settingsBox.put('default', settings);
  }

  static List<Alarm> getAllAlarms() {
    return alarmsBox.values.toList();
  }

  static Future<void> saveAlarm(Alarm alarm) async {
    await alarmsBox.put(alarm.id, alarm);
  }

  static Future<void> deleteAlarm(String id) async {
    await alarmsBox.delete(id);
  }

  static List<AlarmStat> getAllStats() {
    return statsBox.values.toList();
  }

  static Future<void> saveStat(AlarmStat stat) async {
    await statsBox.put(stat.id, stat);
  }

  static List<AlarmStat> getStatsForAlarm(String alarmId) {
    return statsBox.values.where((stat) => stat.alarmId == alarmId).toList();
  }

  static Future<void> clearAllData() async {
    await _alarmsBox?.clear();
    await _settingsBox?.clear();
    await _statsBox?.clear();
    // Re-initialize default settings
    await saveSettings(AppSettings());
  }
}