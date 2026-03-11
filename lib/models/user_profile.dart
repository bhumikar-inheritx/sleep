/// User profile & sleep preferences.
class UserProfile {
  final String? uid;
  final String name;
  final String? email;
  final TimeOfDay preferredBedtime;
  final TimeOfDay preferredWakeTime;
  final List<String> sleepGoals;
  final List<String> sleepChallenges;
  final List<String> preferredContent;
  final int streakDays;
  final bool onboardingComplete;

  const UserProfile({
    this.uid,
    required this.name,
    this.email,
    this.preferredBedtime = const TimeOfDay(hour: 22, minute: 30),
    this.preferredWakeTime = const TimeOfDay(hour: 7, minute: 0),
    this.sleepGoals = const [],
    this.sleepChallenges = const [],
    this.preferredContent = const [],
    this.streakDays = 0,
    this.onboardingComplete = false,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String?,
      name: json['name'] as String? ?? 'Dreamer',
      email: json['email'] as String?,
      preferredBedtime: _parseTimeOfDay(json['preferredBedtime'] as String?),
      preferredWakeTime: _parseTimeOfDay(
        json['preferredWakeTime'] as String?,
        defaultHour: 7,
        defaultMinute: 0,
      ),
      sleepGoals: _parseStringList(json['sleepGoals']),
      sleepChallenges: _parseStringList(json['sleepChallenges']),
      preferredContent: _parseStringList(json['preferredContent']),
      streakDays: json['streakDays'] as int? ?? 0,
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'preferredBedtime': '${preferredBedtime.hour}:${preferredBedtime.minute}',
      'preferredWakeTime':
          '${preferredWakeTime.hour}:${preferredWakeTime.minute}',
      'sleepGoals': sleepGoals,
      'sleepChallenges': sleepChallenges,
      'preferredContent': preferredContent,
      'streakDays': streakDays,
      'onboardingComplete': onboardingComplete,
    };
  }

  UserProfile copyWith({
    String? uid,
    String? name,
    String? email,
    TimeOfDay? preferredBedtime,
    TimeOfDay? preferredWakeTime,
    List<String>? sleepGoals,
    List<String>? sleepChallenges,
    List<String>? preferredContent,
    int? streakDays,
    bool? onboardingComplete,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      preferredBedtime: preferredBedtime ?? this.preferredBedtime,
      preferredWakeTime: preferredWakeTime ?? this.preferredWakeTime,
      sleepGoals: sleepGoals ?? this.sleepGoals,
      sleepChallenges: sleepChallenges ?? this.sleepChallenges,
      preferredContent: preferredContent ?? this.preferredContent,
      streakDays: streakDays ?? this.streakDays,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }

  static TimeOfDay _parseTimeOfDay(
    String? value, {
    int defaultHour = 22,
    int defaultMinute = 30,
  }) {
    if (value == null)
      return TimeOfDay(hour: defaultHour, minute: defaultMinute);
    final parts = value.split(':');
    if (parts.length != 2) {
      return TimeOfDay(hour: defaultHour, minute: defaultMinute);
    }
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

/// Flutter's TimeOfDay for the model (avoids importing material in the model).
class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  String get formatted {
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final period = hour >= 12 ? 'PM' : 'AM';
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }
}
