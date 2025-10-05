import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/alarm.dart';
import '../models/enums.dart';
import '../providers/alarm_provider.dart';
import '../widgets/challenges/math_challenge.dart';
import '../widgets/challenges/shake_challenge.dart';
import '../services/alarm_service.dart';
import '../services/audio_service.dart';
import 'dart:async';

class AlarmRingingScreen extends StatefulWidget {
  final Alarm alarm;

  const AlarmRingingScreen({
    super.key,
    required this.alarm,
  });

  @override
  State<AlarmRingingScreen> createState() => _AlarmRingingScreenState();
}

class _AlarmRingingScreenState extends State<AlarmRingingScreen> with TickerProviderStateMixin {
  bool _showChallenge = false;
  Timer? _timeoutTimer;
  int _remainingSeconds = 60; // Default timeout
  late AnimationController _pulseController;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    
    // Start playing alarm sound
    _startAlarmSound();
    
    // Prevent back navigation
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    
    // Keep screen on
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [],
    );

    // Pulse animation for alarm bell
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    // Progress animation for timer
    _progressController = AnimationController(
      duration: Duration(seconds: _remainingSeconds),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _stopAlarmSound();
    _pulseController.dispose();
    _progressController.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  void _startAlarmSound() {
    final audioService = AudioService();
    audioService.playAlarmSound(volume: widget.alarm.volume);
    
    if (widget.alarm.gradualVolumeIncrease) {
      audioService.startGradualVolumeIncrease(
        startVolume: 0.1,
        endVolume: widget.alarm.volume,
        duration: const Duration(seconds: 30),
      );
    }
  }

  void _stopAlarmSound() {
    final audioService = AudioService();
    audioService.stopAlarmSound();
  }

  void _startChallenge() {
    setState(() {
      _showChallenge = true;
    });

    // Start countdown timer
    _progressController.forward();
    _timeoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds <= 0) {
        timer.cancel();
        _onChallengeTimeout();
      }
    });
  }

  void _onChallengeSuccess() {
    _timeoutTimer?.cancel();
    
    // Stop alarm sound
    _stopAlarmSound();
    
    // Update statistics
    final provider = Provider.of<AlarmProvider>(context, listen: false);
    // TODO: Add stat tracking
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alarm dismissed! Good morning! 🌅'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate back
    Navigator.of(context).pop();
  }

  void _onChallengeTimeout() {
    setState(() {
      _showChallenge = false;
      _remainingSeconds = 60; // Reset timer
    });

    _progressController.reset();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Time\'s up! Alarm will continue ringing...'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _snoozeAlarm() {
    _stopAlarmSound();
    
    final alarmService = AlarmService();
    alarmService.snoozeAlarm(widget.alarm);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Snoozed for ${widget.alarm.snoozeMinutes} minutes'),
        backgroundColor: Colors.orange,
      ),
    );
    
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent back button if in no-escape mode
        return !widget.alarm.noEscapeMode || !_showChallenge;
      },
      child: Scaffold(
        backgroundColor: _showChallenge 
            ? Colors.white 
            : const Color(0xFFFF5252), // Red background for alarm
        body: SafeArea(
          child: _showChallenge
              ? _buildChallengeView()
              : _buildAlarmView(),
        ),
      ),
    );
  }

  Widget _buildAlarmView() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFF5252),
            const Color(0xFFD32F2F),
          ],
        ),
      ),
      child: Column(
        children: [
          const Spacer(),
          
          // Animated alarm icon
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.2),
                child: Icon(
                  Icons.alarm,
                  size: 120,
                  color: Colors.white.withOpacity(0.9),
                ),
              );
            },
          ),
          
          const SizedBox(height: 40),
          
          // Time display
          Text(
            _formatTime(DateTime.now()),
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Alarm label
          if (widget.alarm.label.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                widget.alarm.label,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          
          const SizedBox(height: 60),
          
          // Turn Off Alarm button
          GestureDetector(
            onTap: _startChallenge,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.stop_circle_outlined,
                      size: 60,
                      color: Color(0xFFD32F2F),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Turn Off',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Snooze button
          TextButton.icon(
            onPressed: _snoozeAlarm,
            icon: const Icon(Icons.snooze, color: Colors.white70),
            label: Text(
              'Snooze ${widget.alarm.snoozeMinutes} min',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ),
          
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildChallengeView() {
    return Column(
      children: [
        // Timer header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Solve to turn off alarm',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _remainingSeconds <= 10 
                          ? Colors.red.shade100 
                          : Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer,
                          size: 20,
                          color: _remainingSeconds <= 10 
                              ? Colors.red.shade700 
                              : Colors.blue.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_remainingSeconds}s',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _remainingSeconds <= 10 
                                ? Colors.red.shade700 
                                : Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress bar
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: 1 - _progressController.value,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _remainingSeconds <= 10 
                            ? Colors.red 
                            : const Color(0xFF6366F1),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        
        // Challenge widget
        Expanded(
          child: _buildChallengeWidget(),
        ),
      ],
    );
  }

  Widget _buildChallengeWidget() {
    switch (widget.alarm.challengeType) {
      case ChallengeType.math:
        return MathChallenge(
          difficulty: widget.alarm.challengeDifficulty,
          config: widget.alarm.challengeConfig,
          onSuccess: _onChallengeSuccess,
        );
      
      case ChallengeType.shake:
        return ShakeChallenge(
          difficulty: widget.alarm.challengeDifficulty,
          config: widget.alarm.challengeConfig,
          onSuccess: _onChallengeSuccess,
        );
      
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Challenge type: ${widget.alarm.challengeType}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _onChallengeSuccess,
                child: const Text('Complete Challenge'),
              ),
            ],
          ),
        );
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute\n$amPm';
  }
}
