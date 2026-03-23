import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/alarm_settings.dart';
import '../services/storage_service.dart';
import '../services/notifications_service.dart';

class AlarmProvider extends ChangeNotifier {
  static const String _storageKey = 'alarm_settings';
  
  AlarmSettings _settings = AlarmSettings.defaultSettings();
  AlarmSettings get settings => _settings;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  AlarmProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final jsonString = StorageService.getString(_storageKey);
      if (jsonString != null) {
        final Map<String, dynamic> json = jsonDecode(jsonString);
        
        _settings = AlarmSettings(
          bedtime: TimeOfDay(
            hour: json['bedtimeHour'] as int,
            minute: json['bedtimeMinute'] as int,
          ),
          wakeTime: TimeOfDay(
            hour: json['wakeTimeHour'] as int,
            minute: json['wakeTimeMinute'] as int,
          ),
          repeatDays: List<int>.from(json['repeatDays'] as List),
          isWakeAlarmEnabled: json['isWakeAlarmEnabled'] as bool,
          isBedtimeReminderEnabled: json['isBedtimeReminderEnabled'] as bool,
          wakeSoundId: json['wakeSoundId'] as String,
          isSmartWakeEnabled: json['isSmartWakeEnabled'] as bool? ?? false,
          smartWakeWindow: json['smartWakeWindow'] as int? ?? 30,
          isLucidTriggerEnabled: json['isLucidTriggerEnabled'] as bool? ?? false,
          lucidTriggerInterval: json['lucidTriggerInterval'] as int? ?? 90,
          lucidTriggerSoundId: json['lucidTriggerSoundId'] as String? ?? 'lucid_cue',
        );
      }
    } catch (e) {
      debugPrint('Error loading alarm settings: $e');
      _settings = AlarmSettings.defaultSettings();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveSettings() async {
    try {
      final json = {
        'bedtimeHour': _settings.bedtime.hour,
        'bedtimeMinute': _settings.bedtime.minute,
        'wakeTimeHour': _settings.wakeTime.hour,
        'wakeTimeMinute': _settings.wakeTime.minute,
        'repeatDays': _settings.repeatDays,
        'isWakeAlarmEnabled': _settings.isWakeAlarmEnabled,
        'isBedtimeReminderEnabled': _settings.isBedtimeReminderEnabled,
        'wakeSoundId': _settings.wakeSoundId,
        'isSmartWakeEnabled': _settings.isSmartWakeEnabled,
        'smartWakeWindow': _settings.smartWakeWindow,
        'isLucidTriggerEnabled': _settings.isLucidTriggerEnabled,
        'lucidTriggerInterval': _settings.lucidTriggerInterval,
        'lucidTriggerSoundId': _settings.lucidTriggerSoundId,
      };
      
      await StorageService.setString(_storageKey, jsonEncode(json));
      
      // Schedule/Cancel Notifications
      await _updateScheduledNotifications();
    } catch (e) {
      debugPrint('Error saving alarm settings: $e');
    }
  }

  Future<void> _updateScheduledNotifications() async {
    // Cancel existing
    await NotificationsService.cancelAll();

    if (_settings.isBedtimeReminderEnabled) {
      // 1. Switch Off Alert (1 hour before bedtime)
      final switchOffTime = _subtractMinutes(_settings.bedtime, 60);
      await NotificationsService.scheduleDailyNotification(
        id: 100,
        title: 'Switch Off Screens 📱',
        body: 'It\'s time to put away your phone and start winding down.',
        hour: switchOffTime.hour,
        minute: switchOffTime.minute,
      );

      // 2. Bedtime Reminder (15 mins before bedtime)
      final reminderTime = _subtractMinutes(_settings.bedtime, 15);
      await NotificationsService.scheduleDailyNotification(
        id: 101,
        title: 'Bedtime is approaching 🌙',
        body: 'Time to head to bed in 15 minutes for a restful night.',
        hour: reminderTime.hour,
        minute: reminderTime.minute,
      );
    }
  }

  TimeOfDay _subtractMinutes(TimeOfDay time, int minutes) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute)
        .subtract(Duration(minutes: minutes));
    return TimeOfDay(hour: dt.hour, minute: dt.minute);
  }

  void updateSettings(AlarmSettings newSettings) {
    _settings = newSettings;
    notifyListeners();
    _saveSettings();
  }
  
  void toggleWakeAlarm(bool isEnabled) {
    updateSettings(_settings.copyWith(isWakeAlarmEnabled: isEnabled));
  }
  
  void toggleBedtimeReminder(bool isEnabled) {
    updateSettings(_settings.copyWith(isBedtimeReminderEnabled: isEnabled));
  }
  
  void updateBedtime(TimeOfDay time) {
    updateSettings(_settings.copyWith(bedtime: time));
  }
  
  void updateWakeTime(TimeOfDay time) {
    updateSettings(_settings.copyWith(wakeTime: time));
  }
  
  void toggleRepeatDay(int dayId) {
    final days = List<int>.from(_settings.repeatDays);
    if (days.contains(dayId)) {
      days.remove(dayId);
    } else {
      days.add(dayId);
      days.sort();
    }
    updateSettings(_settings.copyWith(repeatDays: days));
  }

  void toggleSmartWake(bool isEnabled) {
    updateSettings(_settings.copyWith(isSmartWakeEnabled: isEnabled));
  }

  void toggleLucidTrigger(bool isEnabled) {
    updateSettings(_settings.copyWith(isLucidTriggerEnabled: isEnabled));
  }
}
