/// A single sleep log entry — manually recorded by the user.
class SleepLog {
  final String id;
  final DateTime bedtime;
  final DateTime wakeTime;
  final int qualityRating; // 1 - 5 stars
  final String? mood; // e.g. 'refreshed', 'groggy', 'tired', 'great'
  final String? notes;
  final String? contentUsed; // title of content played that night

  const SleepLog({
    required this.id,
    required this.bedtime,
    required this.wakeTime,
    required this.qualityRating,
    this.mood,
    this.notes,
    this.contentUsed,
  });

  Duration get sleepDuration => wakeTime.difference(bedtime);

  String get formattedDuration {
    final hours = sleepDuration.inHours;
    final mins = sleepDuration.inMinutes % 60;
    return '${hours}h ${mins}m';
  }

  factory SleepLog.fromJson(Map<String, dynamic> json) {
    return SleepLog(
      id: json['id'] as String,
      bedtime: DateTime.parse(json['bedtime'] as String),
      wakeTime: DateTime.parse(json['wakeTime'] as String),
      qualityRating: json['qualityRating'] as int? ?? 3,
      mood: json['mood'] as String?,
      notes: json['notes'] as String?,
      contentUsed: json['contentUsed'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bedtime': bedtime.toIso8601String(),
      'wakeTime': wakeTime.toIso8601String(),
      'qualityRating': qualityRating,
      'mood': mood,
      'notes': notes,
      'contentUsed': contentUsed,
    };
  }
}
