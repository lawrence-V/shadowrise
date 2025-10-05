import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alarm_provider.dart';
import '../models/enums.dart';
import '../models/alarm.dart';
import 'add_edit_alarm_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';
import 'alarm_ringing_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _AlarmsTab(),
          StatisticsScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: 'Alarms',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _AlarmsTab extends StatefulWidget {
  const _AlarmsTab();

  @override
  State<_AlarmsTab> createState() => _AlarmsTabState();
}

class _AlarmsTabState extends State<_AlarmsTab> {
  late Timer _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Update the clock every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
    
    print('📅 _AlarmsTabState: Initialized (alarm checking is now handled globally)');
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6366F1), // Purple background like in image
      body: Consumer<AlarmProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // Top section with time and settings
              _buildTopSection(context, provider),
              
              // Stats section
              _buildStatsSection(context, provider),
              
              // Alarms section
              Expanded(
                flex: 3, // Give more space to the alarms section
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Your Alarms header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Your Alarms',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _navigateToAddAlarm(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Add Alarm',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Alarms list or empty state - give it more height
                      Expanded(
                        flex: 2, // Prioritize alarm list over challenge types
                        child: provider.alarms.isEmpty
                            ? _buildEmptyStateNew(context)
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                itemCount: provider.alarms.length,
                                physics: const BouncingScrollPhysics(), // Better scroll physics
                                itemBuilder: (context, index) {
                                  final alarm = provider.alarms[index];
                                  return _buildAlarmCard(
                                    context,
                                    alarm,
                                    provider,
                                  );
                                },
                              ),
                      ),
                      
                      // Challenge Types section at bottom - make it smaller
                      _buildChallengeTypesSection(context),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopSection(BuildContext context, AlarmProvider provider) {
    final now = _currentTime; // Use the updating time
    final nextAlarm = provider.getNextAlarm();
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          children: [
            // Header with app name and icons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Smart Alarm',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    // Debug test button for alarm ringing screen
                    if (const bool.fromEnvironment('dart.vm.product') == false)
                      IconButton(
                        onPressed: () => _testAlarmRinging(context),
                        icon: const Icon(
                          Icons.bug_report,
                          color: Colors.amber,
                        ),
                        tooltip: 'Test Alarm',
                      ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.settings,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.list,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Large time display
            Text(
              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 64,
                fontWeight: FontWeight.w300,
                height: 1.0,
              ),
            ),
            
            // Date and next alarm info
            Column(
              children: <Widget>[
                Text(
                  _formatDateString(now),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                if (nextAlarm != null)
                  const SizedBox(height: 4),
                if (nextAlarm != null)
                  Text(
                    'Next alarm: ${_formatTime(nextAlarm.time)}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, AlarmProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard(
            '${(provider.overallSuccessRate * 100).toInt()}%',
            'Success Rate',
          ),
          _buildStatCard(
            '${provider.averageCompletionTime.toInt()}s',
            'Avg Solve Time',
          ),
          _buildStatCard(
            '${provider.totalAlarmsTriggered}',
            'Days Streak',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAlarmCard(BuildContext context, alarm, AlarmProvider provider) {
    return GestureDetector(
      onTap: () => _navigateToEditAlarm(context, alarm),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(
          minHeight: 100, // Ensure minimum height for better touch targets
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: alarm.isEnabled 
                ? const Color(0xFF6366F1).withValues(alpha: 0.2) 
                : Colors.grey.shade200,
          ),
        ),
      child: Row(
        children: [
          // Time and label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _formatTime(alarm.time),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (alarm.label.isNotEmpty) const SizedBox(height: 4),
                if (alarm.label.isNotEmpty)
                  Text(
                    alarm.label,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                const SizedBox(height: 8),
                // Day chips or one-time indicator
                if (alarm.repeatDays.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    children: alarm.repeatDays.map<Widget>((day) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getDayName(day),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'One time',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                // Challenge type
                Row(
                  children: [
                    Icon(
                      _getChallengeIcon(alarm.challengeType),
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getChallengeTypeName(alarm.challengeType),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Toggle switch
          Switch(
            value: alarm.isEnabled,
            onChanged: (_) => provider.toggleAlarm(alarm.id),
            activeColor: const Color(0xFF6366F1),
          ),
        ],
      ),
      ), // Close Container
    ); // Close GestureDetector
  }

  Widget _buildChallengeTypesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Challenge Types',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildChallengeTypeCard(
                  Icons.calculate,
                  'Math',
                  'Equations',
                  const Color(0xFF6366F1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildChallengeTypeCard(
                  Icons.qr_code_scanner,
                  'QR Scan',
                  'Scan code',
                  const Color(0xFF06B6D4),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildChallengeTypeCard(
                  Icons.vibration,
                  'Shake',
                  'Shake phone',
                  const Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildChallengeTypeCard(
                  Icons.memory,
                  'Memory',
                  'Pattern',
                  const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeTypeCard(IconData icon, String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 18,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateNew(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.alarm_off,
            size: 60,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No alarms yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Create your first smart alarm',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $amPm';
  }

  String _formatDateString(DateTime date) {
    const weekdays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    
    return '${weekdays[date.weekday % 7]}, ${months[date.month - 1]} ${date.day}';
  }

  String _getDayName(int day) {
    const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return dayNames[day];
  }

  IconData _getChallengeIcon(ChallengeType type) {
    switch (type) {
      case ChallengeType.math:
        return Icons.calculate;
      case ChallengeType.qrCode:
        return Icons.qr_code_scanner;
      case ChallengeType.memoryGame:
        return Icons.memory;
      case ChallengeType.shake:
        return Icons.vibration;
      case ChallengeType.random:
        return Icons.shuffle;
    }
  }

  String _getChallengeTypeName(ChallengeType type) {
    switch (type) {
      case ChallengeType.math:
        return 'Math Problem';
      case ChallengeType.qrCode:
        return 'QR Scan';
      case ChallengeType.memoryGame:
        return 'Memory Game';
      case ChallengeType.shake:
        return 'Shake Phone';
      case ChallengeType.random:
        return 'Random Task';
    }
  }

  void _navigateToAddAlarm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditAlarmScreen(),
      ),
    );
  }

  void _navigateToEditAlarm(BuildContext context, alarm) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditAlarmScreen(alarm: alarm),
      ),
    );
  }

  // Test method to open alarm ringing screen
  void _testAlarmRinging(BuildContext context) {
    // Show a dialog to select difficulty
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Alarm'),
        content: const Text('This will trigger a test alarm with sound. Choose difficulty:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _triggerTestAlarm(context, ChallengeDifficulty.easy);
            },
            child: const Text('Easy (1 problem)'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _triggerTestAlarm(context, ChallengeDifficulty.medium);
            },
            child: const Text('Medium (2 problems)'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _triggerTestAlarm(context, ChallengeDifficulty.hard);
            },
            child: const Text('Hard (3 problems)'),
          ),
        ],
      ),
    );
  }

  void _triggerTestAlarm(BuildContext context, ChallengeDifficulty difficulty) {
    // Create a test alarm
    final testAlarm = Alarm(
      id: 'test',
      label: 'Test Alarm - Wake Up!',
      time: DateTime.now(),
      isEnabled: true,
      challengeType: ChallengeType.math,
      challengeDifficulty: difficulty,
      volume: 0.5, // Medium volume for testing
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlarmRingingScreen(alarm: testAlarm),
      ),
    );
  }
}
