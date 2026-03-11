import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/alarm_settings.dart';
import '../services/storage_service.dart';

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
      };
      
      await StorageService.setString(_storageKey, jsonEncode(json));
      
      // In a real app, you would also interact with local notifications plugin here
      // to schedule/cancel the actual OS-level alarms and reminders based on these settings.
      
    } catch (e) {
      debugPrint('Error saving alarm settings: $e');
    }
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
}
