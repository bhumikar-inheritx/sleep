import 'package:flutter/material.dart';
import '../../models/routine.dart';

class UserEntity {
  final String? uid;
  final String name;
  final String? email;
  final TimeOfDay preferredBedtime;
  final TimeOfDay preferredWakeTime;
  final List<String> sleepGoals;
  final List<String> sleepChallenges;
  final List<String> preferredContent;
  final List<String> favorites;
  final int streakDays;
  final DateTime? lastActiveDate;
  final List<String> completedChallenges;
  final List<String> recentlyPlayed;
  final SleepRoutine? windDownRoutine;
  final bool onboardingComplete;
  
  // Audio settings
  final Duration defaultSleepTimer;
  final Duration fadeOutDuration;

  const UserEntity({
    this.uid,
    required this.name,
    this.email,
    this.preferredBedtime = const TimeOfDay(hour: 22, minute: 30),
    this.preferredWakeTime = const TimeOfDay(hour: 7, minute: 0),
    this.sleepGoals = const [],
    this.sleepChallenges = const [],
    this.preferredContent = const [],
    this.favorites = const [],
    this.streakDays = 0,
    this.lastActiveDate,
    this.completedChallenges = const [],
    this.recentlyPlayed = const [],
    this.windDownRoutine,
    this.onboardingComplete = false,
    this.defaultSleepTimer = const Duration(minutes: 30),
    this.fadeOutDuration = const Duration(minutes: 5),
  });

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      uid: map['uid'] as String?,
      name: map['name'] as String? ?? 'Dreamer',
      email: map['email'] as String?,
      preferredBedtime: _parseTimeOfDay(map['preferredBedtime'] as String?),
      preferredWakeTime: _parseTimeOfDay(
        map['preferredWakeTime'] as String?,
        defaultHour: 7,
        defaultMinute: 0,
      ),
      sleepGoals: _parseStringList(map['sleepGoals']),
      sleepChallenges: _parseStringList(map['sleepChallenges']),
      preferredContent: _parseStringList(map['preferredContent']),
      favorites: _parseStringList(map['favorites']),
      streakDays: map['streakDays'] as int? ?? 0,
      lastActiveDate: map['lastActiveDate'] != null
          ? DateTime.tryParse(map['lastActiveDate'] as String)
          : null,
      completedChallenges: _parseStringList(map['completedChallenges']),
      recentlyPlayed: _parseStringList(map['recentlyPlayed']),
      windDownRoutine: map['windDownRoutine'] != null
          ? SleepRoutine.fromJson(map['windDownRoutine'] as Map<String, dynamic>)
          : null,
      onboardingComplete: map['onboardingComplete'] as bool? ?? false,
      defaultSleepTimer: Duration(minutes: map['defaultSleepTimer'] as int? ?? 30),
      fadeOutDuration: Duration(minutes: map['fadeOutDuration'] as int? ?? 5),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'preferredBedtime': '${preferredBedtime.hour}:${preferredBedtime.minute}',
      'preferredWakeTime': '${preferredWakeTime.hour}:${preferredWakeTime.minute}',
      'sleepGoals': sleepGoals,
      'sleepChallenges': sleepChallenges,
      'preferredContent': preferredContent,
      'favorites': favorites,
      'streakDays': streakDays,
      'lastActiveDate': lastActiveDate?.toIso8601String(),
      'completedChallenges': completedChallenges,
      'recentlyPlayed': recentlyPlayed,
      'windDownRoutine': windDownRoutine?.toJson(),
      'onboardingComplete': onboardingComplete,
      'defaultSleepTimer': defaultSleepTimer.inMinutes,
      'fadeOutDuration': fadeOutDuration.inMinutes,
    };
  }

  UserEntity copyWith({
    String? uid,
    String? name,
    String? email,
    TimeOfDay? preferredBedtime,
    TimeOfDay? preferredWakeTime,
    List<String>? sleepGoals,
    List<String>? sleepChallenges,
    List<String>? preferredContent,
    List<String>? favorites,
    int? streakDays,
    DateTime? lastActiveDate,
    List<String>? completedChallenges,
    List<String>? recentlyPlayed,
    SleepRoutine? windDownRoutine,
    bool? onboardingComplete,
    Duration? defaultSleepTimer,
    Duration? fadeOutDuration,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      preferredBedtime: preferredBedtime ?? this.preferredBedtime,
      preferredWakeTime: preferredWakeTime ?? this.preferredWakeTime,
      sleepGoals: sleepGoals ?? this.sleepGoals,
      sleepChallenges: sleepChallenges ?? this.sleepChallenges,
      preferredContent: preferredContent ?? this.preferredContent,
      favorites: favorites ?? this.favorites,
      streakDays: streakDays ?? this.streakDays,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      completedChallenges: completedChallenges ?? this.completedChallenges,
      recentlyPlayed: recentlyPlayed ?? this.recentlyPlayed,
      windDownRoutine: windDownRoutine ?? this.windDownRoutine,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      defaultSleepTimer: defaultSleepTimer ?? this.defaultSleepTimer,
      fadeOutDuration: fadeOutDuration ?? this.fadeOutDuration,
    );
  }

  static TimeOfDay _parseTimeOfDay(
    String? value, {
    int defaultHour = 22,
    int defaultMinute = 30,
  }) {
    if (value == null) return TimeOfDay(hour: defaultHour, minute: defaultMinute);
    final parts = value.split(':');
    if (parts.length != 2) return TimeOfDay(hour: defaultHour, minute: defaultMinute);
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? defaultHour,
      minute: int.tryParse(parts[1]) ?? defaultMinute,
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }
}
