# Alarm Challenge System - Implementation Guide

## Overview
This document describes the alarm challenge system implemented in the Smart Alarm app. When an alarm triggers, the user must complete a challenge to dismiss it, making the alarm more effective at waking people up.

## Architecture

### Core Components

#### 1. **AlarmRingingScreen** (`lib/screens/alarm_ringing_screen.dart`)
The main screen that displays when an alarm triggers. It has two states:
- **Alarm View**: Shows the ringing alarm with time, alarm label, and a large circular button to start the challenge
- **Challenge View**: Displays the specific challenge the user must complete

**Key Features:**
- 60-second countdown timer for challenge completion
- Animated progress bar showing remaining time
- Full-screen immersive mode (hides system UI)
- Prevents back navigation when in no-escape mode
- Snooze functionality
- Success/timeout handling

#### 2. **MathChallenge** (`lib/widgets/challenges/math_challenge.dart`)
Interactive math problem solver with three difficulty levels:

**Easy:**
- 1 problem to solve
- Single-digit addition/subtraction (1-9)
- Example: 5 + 3 = ?

**Medium:**
- 2 problems to solve
- Two-digit numbers with +, -, × operations
- Example: 45 + 67 = ?, 8 × 7 = ?

**Hard:**
- 3 problems to solve
- Three-digit numbers with all operations (+, -, ×, ÷)
- Clean division (no remainders)
- Example: 145 + 332 = ?, 54 × 9 = ?, 96 ÷ 8 = ?

**Features:**
- Real-time answer validation
- Progress indicator for multiple problems
- Visual feedback (green for correct, red for incorrect)
- Auto-advance to next problem
- Large numeric keyboard-friendly input

#### 3. **ShakeChallenge** (`lib/widgets/challenges/shake_challenge.dart`)
Requires the user to shake their phone vigorously.

**Difficulty Levels:**
- **Easy**: 10 shakes
- **Medium**: 25 shakes
- **Hard**: 50 shakes

**Features:**
- Animated phone icon that moves with shakes
- Real-time shake counter
- Progress bar with color gradient
- Debug/test button for development
- TODO: Real accelerometer integration with sensors_plus package

## User Flow

### 1. Alarm Triggers
```
Alarm Time Reached
    ↓
AlarmRingingScreen Opens
    ↓
Full-screen Red Alarm View
    ↓
Pulsing alarm icon + current time + alarm label
    ↓
User sees "Turn Off" button
```

### 2. Challenge Started
```
User taps "Turn Off" button
    ↓
Screen transitions to Challenge View
    ↓
Timer starts (60 seconds)
    ↓
Challenge widget displays (Math/Shake/etc.)
    ↓
User completes challenge
```

### 3. Challenge Completion
```
Challenge Completed Successfully
    ↓
Success message shown
    ↓
Screen dismisses after 500ms
    ↓
User returns to Home Screen
```

### 4. Challenge Timeout
```
Timer reaches 0 seconds
    ↓
Challenge resets
    ↓
Returns to Alarm View
    ↓
Alarm continues ringing
    ↓
User must try again
```

### 5. Snooze Option
```
User taps "Snooze" button
    ↓
Alarm scheduled for X minutes later
    ↓
Screen dismisses
    ↓
Notification shown
```

## Testing the System

### Debug Test Button
In debug mode (development builds), a bug icon appears in the home screen header. Tapping it opens the AlarmRingingScreen with a test alarm:
- Label: "Test Alarm"
- Challenge Type: Math (Medium difficulty)
- Challenge Difficulty: 2 problems to solve

### Testing on Device
1. **Install the app** on your Android device
2. **Tap the bug icon** (amber color) in the top right of the home screen
3. **Try the alarm flow:**
   - See the red alarm screen
   - Tap the "Turn Off" button
   - Solve the math problems
   - Watch the success animation
4. **Test timeout:**
   - Let the timer run out
   - Verify it returns to alarm view
5. **Test snooze:**
   - Tap the "Snooze" button
   - Verify the snackbar message

## Integration Points

### AlarmService Integration
The `AlarmService` already includes a `snoozeAlarm()` method that:
- Calculates the snooze time based on alarm settings
- Reschedules the notification
- Preserves alarm configuration

### Future Integration (TODO)
1. **Audio System**: Play alarm sound when screen opens, stop on success
2. **Statistics Tracking**: Record challenge completion times, success rates
3. **Notification Tap**: Open AlarmRingingScreen when alarm notification is tapped
4. **Background Service**: Ensure alarm triggers even when app is closed
5. **Vibration**: Add vibration patterns during alarm ringing

## Adding New Challenges

To add a new challenge type:

### 1. Create Challenge Widget
Create a new file in `lib/widgets/challenges/`:

```dart
import 'package:flutter/material.dart';
import '../../models/enums.dart';

class YourChallenge extends StatefulWidget {
  final ChallengeDifficulty difficulty;
  final Map<String, dynamic>? config;
  final VoidCallback onSuccess;

  const YourChallenge({
    super.key,
    required this.difficulty,
    this.config,
    required this.onSuccess,
  });

  @override
  State<YourChallenge> createState() => _YourChallengeState();
}

class _YourChallengeState extends State<YourChallenge> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Your challenge UI here
          
          // When challenge is completed, call:
          // widget.onSuccess();
        ],
      ),
    );
  }
}
```

### 2. Update AlarmRingingScreen
Add the new challenge case in `_buildChallengeWidget()`:

```dart
case ChallengeType.yourChallenge:
  return YourChallenge(
    difficulty: widget.alarm.challengeDifficulty,
    config: widget.alarm.challengeConfig,
    onSuccess: _onChallengeSuccess,
  );
```

### 3. Update ChallengeType Enum
Add your challenge type to `lib/models/enums.dart`

### 4. Update AlarmService Config
Add default configuration in `getDefaultChallengeConfig()` method

## UI/UX Design Principles

### Alarm View
- **Color**: Urgent red gradient background (#FF5252 → #D32F2F)
- **Visibility**: Large elements, high contrast white text
- **Action**: Central circular button (200×200) for primary action
- **Animation**: Pulsing alarm icon to create urgency

### Challenge View
- **Color**: Clean white background, calming
- **Timer**: Always visible at top with prominent countdown
- **Urgency**: Color changes from blue to red when ≤10 seconds
- **Feedback**: Immediate visual feedback for correct/incorrect answers
- **Progress**: Clear indicators for multi-step challenges

### Accessibility
- Large touch targets (min 44×44 points)
- High contrast text and backgrounds
- Clear error messages
- Haptic feedback (to be implemented)

## Known Issues & Future Improvements

### Current Limitations
1. **No Audio**: Alarm sound not yet implemented (needs audioplayers integration)
2. **No Real Shake Detection**: ShakeChallenge uses simulated shakes (needs sensors_plus integration)
3. **No Background Triggering**: Alarm only works when app is in foreground
4. **No Statistics**: Challenge results not tracked yet

### Planned Improvements
1. **QR Code Challenge**: Scan a registered QR code to dismiss alarm
2. **Memory Game Challenge**: Remember and repeat a sequence
3. **Custom Sounds**: Let users choose alarm sounds
4. **Gradual Volume**: Slowly increase volume over time
5. **Smart Snooze**: Gradually decrease snooze time
6. **Weather Integration**: Show weather on alarm screen
7. **Motivational Quotes**: Display inspiring messages

## Dependencies

### Current
- `flutter_local_notifications`: For scheduling alarms
- `provider`: State management
- `hive`: Local data storage

### Required (Not Yet Integrated)
- `audioplayers`: Play alarm sounds
- `sensors_plus`: Detect device shaking
- `mobile_scanner`: QR code scanning
- `vibration`: Haptic feedback

## Code Quality

### Testing
- Unit tests needed for challenge logic
- Widget tests for UI components
- Integration tests for alarm flow

### Performance
- Animations optimized with AnimationController
- Efficient state management with setState
- No unnecessary rebuilds

### Maintainability
- Clear separation of concerns
- Reusable challenge widget pattern
- Well-documented code
- Type-safe with Dart 3.8+

## Conclusion

The alarm challenge system is now functional with a solid foundation for math and shake challenges. The architecture is extensible and ready for additional challenge types. The next priority should be integrating the audio system and ensuring alarms trigger reliably from the background.
