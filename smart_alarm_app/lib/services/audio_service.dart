import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  // Play alarm sound (loops until stopped)
  Future<void> playAlarmSound({double volume = 0.8}) async {
    if (_isPlaying) {
      print('Alarm sound already playing');
      return;
    }

    _isPlaying = true;
    print('Starting alarm with vibration and sound...');
    
    // Start vibration pattern for alarm
    _startVibrationPattern();
    
    try {
      // Set audio configuration
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(volume);
      await _player.setPlayerMode(PlayerMode.mediaPlayer); // Use media player mode
      
      // Try multiple alarm sound URLs
      const soundUrls = [
        'https://actions.google.com/sounds/v1/alarms/alarm_clock.ogg',
        'https://commondatastorage.googleapis.com/codeskulptor-assets/week7-brrring.m4a',
        'https://www.soundjay.com/mechanical/sounds/alarm-clock-01.mp3',
      ];
      
      bool soundPlayed = false;
      for (final url in soundUrls) {
        try {
          print('Trying to play sound from: $url');
          await _player.play(UrlSource(url));
          print('✓ Sound playing from URL');
          soundPlayed = true;
          break;
        } catch (e) {
          print('Failed URL $url: $e');
          continue;
        }
      }
      
      if (!soundPlayed) {
        print('⚠️ Audio playback failed - using vibration only');
      }
      
    } catch (e) {
      print('Error in audio setup: $e');
    }
  }
  
  // Vibration pattern for alarm
  void _startVibrationPattern() async {
    try {
      final hasVibrator = await Vibration.hasVibrator() ?? false;
      if (hasVibrator) {
        // Vibration pattern: [wait, vibrate, wait, vibrate, ...]
        // Continuous alarm vibration
        Vibration.vibrate(
          pattern: [0, 1000, 500, 1000, 500, 1000],
          repeat: 0, // Repeat the pattern
        );
        print('✓ Vibration started');
      }
    } catch (e) {
      print('Vibration error: $e');
    }
  }

  // Fallback: Use system method channel to play device sound
  void _playDeviceNotificationSound() {
    try {
      // This would require a platform channel implementation
      // For now, just log
      print('Would play device notification sound here');
    } catch (e) {
      print('Failed to play device sound: $e');
    }
  }

  // Stop alarm sound
  Future<void> stopAlarmSound() async {
    if (!_isPlaying) {
      print('No alarm sound playing');
      return;
    }

    try {
      print('Stopping alarm sound and vibration...');
      await _player.stop();
      Vibration.cancel(); // Stop vibration
      _isPlaying = false;
      print('✓ Alarm stopped');
    } catch (e) {
      print('Error stopping alarm sound: $e');
      _isPlaying = false;
      Vibration.cancel(); // Make sure vibration stops
    }
  }

  // Pause alarm sound (for snooze)
  Future<void> pauseAlarmSound() async {
    if (!_isPlaying) return;

    try {
      await _player.pause();
      print('Alarm sound paused');
    } catch (e) {
      print('Error pausing alarm sound: $e');
    }
  }

  // Resume alarm sound
  Future<void> resumeAlarmSound() async {
    if (!_isPlaying) return;

    try {
      await _player.resume();
      print('Alarm sound resumed');
    } catch (e) {
      print('Error resuming alarm sound: $e');
    }
  }

  // Gradually increase volume (for gradual volume increase feature)
  Future<void> startGradualVolumeIncrease({
    double startVolume = 0.1,
    double endVolume = 0.8,
    Duration duration = const Duration(seconds: 30),
  }) async {
    const steps = 30;
    final volumeIncrement = (endVolume - startVolume) / steps;
    final stepDuration = duration.inMilliseconds ~/ steps;

    await _player.setVolume(startVolume);

    for (int i = 0; i < steps; i++) {
      if (!_isPlaying) break;
      
      await Future.delayed(Duration(milliseconds: stepDuration));
      final newVolume = startVolume + (volumeIncrement * (i + 1));
      await _player.setVolume(newVolume.clamp(0.0, 1.0));
    }
  }

  // Dispose resources
  Future<void> dispose() async {
    await _player.dispose();
  }
}
