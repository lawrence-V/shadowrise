import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'services/alarm_trigger_service.dart';
import 'screens/home_screen.dart';
import 'providers/alarm_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize timezone data
  tz.initializeTimeZones();
  // Set to local timezone automatically
  final String timeZoneName = DateTime.now().timeZoneName;
  try {
    // Try to set the device's actual timezone
    final location = tz.getLocation(timeZoneName);
    tz.setLocalLocation(location);
    print('Timezone set to: $timeZoneName');
  } catch (e) {
    // Fallback to UTC if timezone not found
    print('Could not find timezone $timeZoneName, using local: $e');
    tz.setLocalLocation(tz.local);
  }
  
  // Initialize services
  await DatabaseService.init();
  await NotificationService.init();
  
  runApp(const SmartAlarmApp());
}

class SmartAlarmApp extends StatefulWidget {
  const SmartAlarmApp({super.key});

  @override
  State<SmartAlarmApp> createState() => _SmartAlarmAppState();
}

class _SmartAlarmAppState extends State<SmartAlarmApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    print('🚀 SmartAlarmApp: Initialized');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AlarmTriggerService.instance.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('🔄 App lifecycle state changed: $state');
    if (state == AppLifecycleState.resumed) {
      // Restart the alarm check timer when app comes to foreground
      AlarmTriggerService.instance.start();
    } else if (state == AppLifecycleState.paused) {
      // Keep timer running even when app is paused
      // This ensures alarms can trigger when app is in background
      print('⏸️ App paused, but keeping alarm service active');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AlarmProvider()),
      ],
      child: Consumer<AlarmProvider>(
        builder: (context, alarmProvider, _) {
          // Initialize the alarm trigger service once we have the provider
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_navigatorKey.currentContext != null) {
              AlarmTriggerService.instance.initialize(
                _navigatorKey.currentContext!,
                alarmProvider,
              );
            }
          });

          return MaterialApp(
            navigatorKey: _navigatorKey,
            title: 'Smart Alarm',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.indigo,
              brightness: Brightness.light,
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.indigo,
                brightness: Brightness.light,
              ),
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
              ),
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.indigo,
              brightness: Brightness.dark,
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.indigo,
                brightness: Brightness.dark,
              ),
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
              ),
            ),
            themeMode: alarmProvider.settings.isDarkMode 
                ? ThemeMode.dark 
                : ThemeMode.light,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
