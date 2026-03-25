class JournalEntry {
  final String id;
  final DateTime date;
  final int moodIndex;
  final double sleepQuality;
  final String notes;
  final String? userId;

  const JournalEntry({
    required this.id,
    required this.date,
    required this.moodIndex,
    required this.sleepQuality,
    required this.notes,
    this.userId,
  });

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      moodIndex: map['moodIndex'] as int? ?? 0,
      sleepQuality: (map['sleepQuality'] as num?)?.toDouble() ?? 5.0,
      notes: map['notes'] as String? ?? '',
      userId: map['userId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'moodIndex': moodIndex,
      'sleepQuality': sleepQuality,
      'notes': notes,
      'userId': userId,
    };
  }
}
