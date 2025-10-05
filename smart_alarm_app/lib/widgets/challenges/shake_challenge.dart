import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../models/enums.dart';

class ShakeChallenge extends StatefulWidget {
  final ChallengeDifficulty difficulty;
  final Map<String, dynamic>? config;
  final VoidCallback onSuccess;

  const ShakeChallenge({
    super.key,
    required this.difficulty,
    this.config,
    required this.onSuccess,
  });

  @override
  State<ShakeChallenge> createState() => _ShakeChallengeState();
}

class _ShakeChallengeState extends State<ShakeChallenge> with SingleTickerProviderStateMixin {
  int _shakeCount = 0;
  late int _requiredShakes;
  late AnimationController _shakeAnimationController;
  
  // Simulated shake detection (in production, use sensors_plus package)
  Timer? _autoShakeTimer;

  @override
  void initState() {
    super.initState();
    _requiredShakes = _getRequiredShakes();
    
    _shakeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // TODO: Implement real shake detection with sensors_plus
    // For now, this is a placeholder that will be activated by button tap
  }

  @override
  void dispose() {
    _autoShakeTimer?.cancel();
    _shakeAnimationController.dispose();
    super.dispose();
  }

  int _getRequiredShakes() {
    switch (widget.difficulty) {
      case ChallengeDifficulty.easy:
        return 10;
      case ChallengeDifficulty.medium:
        return 25;
      case ChallengeDifficulty.hard:
        return 50;
    }
  }

  void _onShakeDetected() {
    if (_shakeCount >= _requiredShakes) return;

    setState(() {
      _shakeCount++;
    });

    _shakeAnimationController.forward().then((_) {
      _shakeAnimationController.reverse();
    });

    if (_shakeCount >= _requiredShakes) {
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onSuccess();
      });
    }
  }

  // Manual shake trigger for testing (remove when real sensor is implemented)
  void _simulateShake() {
    _onShakeDetected();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _shakeCount / _requiredShakes;
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          
          // Animated phone icon
          AnimatedBuilder(
            animation: _shakeAnimationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: sin(_shakeAnimationController.value * pi * 4) * 0.2,
                child: Transform.translate(
                  offset: Offset(
                    sin(_shakeAnimationController.value * pi * 8) * 10,
                    0,
                  ),
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                    ),
                    child: Icon(
                      Icons.phone_android,
                      size: 100,
                      color: Color.lerp(
                        const Color(0xFF6366F1),
                        Colors.green,
                        progress,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 60),
          
          // Instructions
          const Text(
            'Shake your phone!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Progress text
          Text(
            '$_shakeCount / $_requiredShakes',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6366F1),
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'shakes',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Progress bar
          Container(
            width: double.infinity,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color.lerp(
                    const Color(0xFF6366F1),
                    Colors.green,
                    progress,
                  )!,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 60),
          
          // Instruction text
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.blue.shade200,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue.shade700,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Shake your device vigorously to turn off the alarm',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Debug/Test button (remove in production)
          if (const bool.fromEnvironment('dart.vm.product') == false)
            TextButton.icon(
              onPressed: _simulateShake,
              icon: const Icon(Icons.bug_report),
              label: const Text('Simulate Shake (Debug)'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
              ),
            ),
        ],
      ),
    );
  }
}
