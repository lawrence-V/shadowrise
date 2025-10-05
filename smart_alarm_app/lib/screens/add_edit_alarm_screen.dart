import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alarm.dart';
import '../models/enums.dart';
import '../providers/alarm_provider.dart';
import '../services/alarm_service.dart';

class AddEditAlarmScreen extends StatefulWidget {
  final Alarm? alarm;

  const AddEditAlarmScreen({super.key, this.alarm});

  @override
  State<AddEditAlarmScreen> createState() => _AddEditAlarmScreenState();
}

class _AddEditAlarmScreenState extends State<AddEditAlarmScreen> {
  late TextEditingController _labelController;
  late TimeOfDay _selectedTime;
  late List<int> _selectedDays;
  late bool _isEnabled;
  late String _alarmSound;
  late double _volume;
  late bool _vibration;
  late int _snoozeMinutes;
  late bool _gradualVolumeIncrease;
  late ChallengeType _challengeType;
  late ChallengeDifficulty _challengeDifficulty;
  late bool _noEscapeMode;

  final List<String> _dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  final List<String> _alarmSounds = ['Default', 'Bell', 'Buzzer', 'Chime'];

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    if (widget.alarm != null) {
      // Editing existing alarm
      final alarm = widget.alarm!;
      _labelController = TextEditingController(text: alarm.label);
      _selectedTime = TimeOfDay.fromDateTime(alarm.time);
      _selectedDays = List.from(alarm.repeatDays);
      _isEnabled = alarm.isEnabled;
      _alarmSound = alarm.alarmSound;
      _volume = alarm.volume;
      _vibration = alarm.vibration;
      _snoozeMinutes = alarm.snoozeMinutes;
      _gradualVolumeIncrease = alarm.gradualVolumeIncrease;
      _challengeType = alarm.challengeType;
      _challengeDifficulty = alarm.challengeDifficulty;
      _noEscapeMode = alarm.noEscapeMode;
    } else {
      // Creating new alarm with defaults
      final settings = Provider.of<AlarmProvider>(context, listen: false).settings;
      _labelController = TextEditingController();
      _selectedTime = TimeOfDay.now();
      _selectedDays = [];
      _isEnabled = true;
      _alarmSound = settings.defaultAlarmSound;
      _volume = settings.defaultVolume;
      _vibration = settings.defaultVibration;
      _snoozeMinutes = settings.defaultSnoozeMinutes;
      _gradualVolumeIncrease = settings.gradualVolumeDefault;
      _challengeType = settings.defaultChallengeType;
      _challengeDifficulty = settings.defaultChallengeDifficulty;
      _noEscapeMode = false;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alarm == null ? 'Add Alarm' : 'Edit Alarm'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveAlarm,
            child: _isSaving 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('SAVE'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Picker
            _buildTimePickerCard(),
            const SizedBox(height: 16),
            
            // Label
            _buildLabelCard(),
            const SizedBox(height: 16),
            
            // Repeat Days
            _buildRepeatDaysCard(),
            const SizedBox(height: 16),
            
            // Challenge Settings
            _buildChallengeCard(),
            const SizedBox(height: 16),
            
            // Audio & Vibration
            _buildAudioCard(),
            const SizedBox(height: 16),
            
            // Advanced Settings
            _buildAdvancedCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: _pickTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _selectedTime.format(context),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Label',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(
                hintText: 'e.g., Morning Workout',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepeatDaysCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Repeat',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: List.generate(7, (index) {
                final isSelected = _selectedDays.contains(index);
                return FilterChip(
                  label: Text(_dayNames[index]),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedDays.add(index);
                      } else {
                        _selectedDays.remove(index);
                      }
                    });
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wake-up Challenge',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ChallengeType>(
              value: _challengeType,
              decoration: const InputDecoration(
                labelText: 'Challenge Type',
                border: OutlineInputBorder(),
              ),
              items: ChallengeType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(_getChallengeIcon(type)),
                      const SizedBox(width: 8),
                      Text(type.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _challengeType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ChallengeDifficulty>(
              value: _challengeDifficulty,
              decoration: const InputDecoration(
                labelText: 'Difficulty',
                border: OutlineInputBorder(),
              ),
              items: ChallengeDifficulty.values.map((difficulty) {
                return DropdownMenuItem(
                  value: difficulty,
                  child: Text(difficulty.displayName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _challengeDifficulty = value!;
                });
              },
            ),
            const SizedBox(height: 8),
            Text(
              _challengeType.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Audio & Vibration',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _alarmSound,
              decoration: const InputDecoration(
                labelText: 'Alarm Sound',
                border: OutlineInputBorder(),
              ),
              items: _alarmSounds.map((sound) {
                return DropdownMenuItem(
                  value: sound.toLowerCase(),
                  child: Text(sound),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _alarmSound = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            Text('Volume: ${(_volume * 100).round()}%'),
            Slider(
              value: _volume,
              onChanged: (value) {
                setState(() {
                  _volume = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Vibration'),
              subtitle: const Text('Vibrate when alarm rings'),
              value: _vibration,
              onChanged: (value) {
                setState(() {
                  _vibration = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Gradual Volume Increase'),
              subtitle: const Text('Start quiet and gradually increase volume'),
              value: _gradualVolumeIncrease,
              onChanged: (value) {
                setState(() {
                  _gradualVolumeIncrease = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advanced Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('Snooze Duration'),
              subtitle: Text('$_snoozeMinutes minutes'),
              trailing: DropdownButton<int>(
                value: _snoozeMinutes,
                items: [1, 3, 5, 10, 15].map((minutes) {
                  return DropdownMenuItem(
                    value: minutes,
                    child: Text('$minutes min'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _snoozeMinutes = value!;
                  });
                },
              ),
            ),
            SwitchListTile(
              title: const Text('No Escape Mode'),
              subtitle: const Text('Force completion - no backing out'),
              secondary: Icon(
                Icons.lock,
                color: _noEscapeMode 
                    ? Theme.of(context).colorScheme.error 
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              value: _noEscapeMode,
              onChanged: (value) {
                setState(() {
                  _noEscapeMode = value;
                });
              },
            ),
          ],
        ),
      ),
    );
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

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  bool _isSaving = false;

  Future<void> _saveAlarm() async {
    if (_isSaving) {
      print('Save already in progress, ignoring...');
      return;
    }
    
    if (!mounted) {
      print('Widget not mounted, cannot save');
      return;
    }
    
    try {
      print('Starting to save alarm...');
      setState(() => _isSaving = true);
      print('Set isSaving to true');
      
      final provider = Provider.of<AlarmProvider>(context, listen: false);
      print('Got provider');
      
      final alarmService = AlarmService();
      print('Got alarm service');
      
      // Create DateTime from selected time
      final now = DateTime.now();
      final alarmDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      print('Created datetime: $alarmDateTime');
      
      // Get challenge config
      print('Getting challenge config...');
      final challengeConfig = alarmService.getDefaultChallengeConfig(
        _challengeType,
        _challengeDifficulty,
      );
      print('Got challenge config: $challengeConfig');
      
      if (widget.alarm == null) {
        // Create new alarm directly
        final newAlarm = Alarm(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          label: _labelController.text.trim(),
          time: alarmDateTime,
          repeatDays: _selectedDays,
          isEnabled: _isEnabled,
          alarmSound: _alarmSound,
          volume: _volume,
          vibration: _vibration,
          snoozeMinutes: _snoozeMinutes,
          gradualVolumeIncrease: _gradualVolumeIncrease,
          challengeType: _challengeType,
          challengeDifficulty: _challengeDifficulty,
          challengeConfig: challengeConfig,
          noEscapeMode: _noEscapeMode,
        );
        
        print('About to add alarm to provider');
        await provider.addAlarm(newAlarm);
        print('Alarm added to provider successfully');
      } else {
        // Update existing alarm
        final updatedAlarm = widget.alarm!;
        updatedAlarm.label = _labelController.text.trim();
        updatedAlarm.time = alarmDateTime;
        updatedAlarm.repeatDays = _selectedDays;
        updatedAlarm.isEnabled = _isEnabled;
        updatedAlarm.alarmSound = _alarmSound;
        updatedAlarm.volume = _volume;
        updatedAlarm.vibration = _vibration;
        updatedAlarm.snoozeMinutes = _snoozeMinutes;
        updatedAlarm.gradualVolumeIncrease = _gradualVolumeIncrease;
        updatedAlarm.challengeType = _challengeType;
        updatedAlarm.challengeDifficulty = _challengeDifficulty;
        updatedAlarm.challengeConfig = challengeConfig;
        updatedAlarm.noEscapeMode = _noEscapeMode;
        
        await provider.updateAlarm(updatedAlarm);
      }
      
      print('Save completed successfully!');
      
      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error in _saveAlarm: $e');
      print('Stack trace: ${StackTrace.current}');
      
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving alarm: $e')),
        );
      }
    }
  }
}
