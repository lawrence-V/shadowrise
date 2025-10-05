import 'package:flutter/material.dart';
import '../models/alarm.dart';
import '../models/enums.dart';

class AlarmTile extends StatelessWidget {
  final Alarm alarm;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AlarmTile({
    super.key,
    required this.alarm,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _formatTime(alarm.time),
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: alarm.isEnabled 
                                    ? null 
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (alarm.nextTriggerTime != null)
                              Text(
                                _getTimeUntilNext(),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                          ],
                        ),
                        if (alarm.label.isNotEmpty)
                          Text(
                            alarm.label,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: alarm.isEnabled 
                                  ? null 
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Switch(
                    value: alarm.isEnabled,
                    onChanged: (_) => onToggle(),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Repeat days
              if (alarm.repeatDays.isNotEmpty)
                Wrap(
                  spacing: 4,
                  children: alarm.repeatDays.map((day) {
                    return Chip(
                      label: Text(_getDayName(day)),
                      labelStyle: Theme.of(context).textTheme.bodySmall,
                      backgroundColor: alarm.isEnabled
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      side: BorderSide.none,
                    );
                  }).toList(),
                )
              else
                Chip(
                  label: const Text('One time'),
                  labelStyle: Theme.of(context).textTheme.bodySmall,
                  backgroundColor: alarm.isEnabled
                      ? Theme.of(context).colorScheme.secondaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  side: BorderSide.none,
                ),
              
              const SizedBox(height: 8),
              
              // Challenge info and actions
              Row(
                children: [
                  Icon(
                    _getChallengeIcon(alarm.challengeType),
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${alarm.challengeType.displayName} (${alarm.challengeDifficulty.displayName})',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  if (alarm.vibration)
                    Icon(
                      Icons.vibration,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  if (alarm.gradualVolumeIncrease)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.trending_up,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  if (alarm.noEscapeMode)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.lock,
                        size: 16,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                    iconSize: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
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

  String _getDayName(int day) {
    const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return dayNames[day];
  }

  String _getTimeUntilNext() {
    if (alarm.nextTriggerTime == null || !alarm.isEnabled) return '';
    
    final now = DateTime.now();
    final difference = alarm.nextTriggerTime!.difference(now);
    
    if (difference.inDays > 0) {
      return 'in ${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return 'in ${difference.inMinutes}m';
    } else {
      return 'soon';
    }
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
}