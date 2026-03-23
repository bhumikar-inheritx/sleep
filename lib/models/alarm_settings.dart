import 'package:flutter/material.dart';

class AlarmSettings {
  final TimeOfDay bedtime;
  final TimeOfDay wakeTime;
  final List<int> repeatDays; // 1 = Monday, 7 = Sunday
  final bool isWakeAlarmEnabled;
   final bool isBedtimeReminderEnabled;
  final String wakeSoundId; // 'chimes', 'birds', 'sunrise', etc.
  final bool isSmartWakeEnabled;
  final int smartWakeWindow; // minutes
  final bool isLucidTriggerEnabled;
  final int lucidTriggerInterval; // minutes
  final String lucidTriggerSoundId;

  const AlarmSettings({
    required this.bedtime,
    required this.wakeTime,
    required this.repeatDays,
    required this.isWakeAlarmEnabled,
    required this.isBedtimeReminderEnabled,
    required this.wakeSoundId,
    this.isSmartWakeEnabled = false,
    this.smartWakeWindow = 30,
    this.isLucidTriggerEnabled = false,
    this.lucidTriggerInterval = 90,
    this.lucidTriggerSoundId = 'lucid_cue',
  });

  factory AlarmSettings.defaultSettings() {
    return const AlarmSettings(
      bedtime: TimeOfDay(hour: 22, minute: 0), // 10:00 PM
      wakeTime: TimeOfDay(hour: 6, minute: 30), // 6:30 AM
      repeatDays: [1, 2, 3, 4, 5], // Mon-Fri
      isWakeAlarmEnabled: true,
      isBedtimeReminderEnabled: true,
      wakeSoundId: 'gentle_chimes',
      isSmartWakeEnabled: false,
      smartWakeWindow: 30,
      isLucidTriggerEnabled: false,
      lucidTriggerInterval: 90,
      lucidTriggerSoundId: 'lucid_cue',
    );
  }

  AlarmSettings copyWith({
    TimeOfDay? bedtime,
    TimeOfDay? wakeTime,
    List<int>? repeatDays,
    bool? isWakeAlarmEnabled,
    bool? isBedtimeReminderEnabled,
    String? wakeSoundId,
    bool? isSmartWakeEnabled,
    int? smartWakeWindow,
    bool? isLucidTriggerEnabled,
    int? lucidTriggerInterval,
    String? lucidTriggerSoundId,
  }) {
    return AlarmSettings(
      bedtime: bedtime ?? this.bedtime,
      wakeTime: wakeTime ?? this.wakeTime,
      repeatDays: repeatDays ?? this.repeatDays,
      isWakeAlarmEnabled: isWakeAlarmEnabled ?? this.isWakeAlarmEnabled,
      isBedtimeReminderEnabled: isBedtimeReminderEnabled ?? this.isBedtimeReminderEnabled,
      wakeSoundId: wakeSoundId ?? this.wakeSoundId,
      isSmartWakeEnabled: isSmartWakeEnabled ?? this.isSmartWakeEnabled,
      smartWakeWindow: smartWakeWindow ?? this.smartWakeWindow,
      isLucidTriggerEnabled: isLucidTriggerEnabled ?? this.isLucidTriggerEnabled,
      lucidTriggerInterval: lucidTriggerInterval ?? this.lucidTriggerInterval,
      lucidTriggerSoundId: lucidTriggerSoundId ?? this.lucidTriggerSoundId,
    );
  }

  // Calculate duration between bedtime and waketime
  Duration get sleepDuration {
    var bHour = bedtime.hour;
    var bMin = bedtime.minute;
    var wHour = wakeTime.hour;
    var wMin = wakeTime.minute;

    if (wHour < bHour || (wHour == bHour && wMin < bMin)) {
      wHour += 24; // Next day
    }
    
    final totalBedMinutes = bHour * 60 + bMin;
    final totalWakeMinutes = wHour * 60 + wMin;
    
    return Duration(minutes: totalWakeMinutes - totalBedMinutes);
  }
}
