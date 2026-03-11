/// Model for a sleep story — narrated content designed to lull users to sleep.
class SleepStory {
  final String id;
  final String title;
  final String narrator;
  final String description;
  final String category;
  final String imageUrl;
  final String audioUrl;
  final Duration duration;
  final bool isPremium;
  final bool isNew;
  final int playCount;
  final DateTime? addedAt;
  final List<String> tags;

  const SleepStory({
    required this.id,
    required this.title,
    required this.narrator,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.audioUrl,
    required this.duration,
    this.isPremium = false,
    this.isNew = false,
    this.playCount = 0,
    this.addedAt,
    this.tags = const [],
  });

  factory SleepStory.fromJson(Map<String, dynamic> json) {
    return SleepStory(
      id: json['id'] as String,
      title: json['title'] as String,
      narrator: json['narrator'] as String? ?? 'Unknown',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'Nature',
      imageUrl: json['imageUrl'] as String? ?? '',
      audioUrl: json['audioUrl'] as String,
      duration: Duration(seconds: json['durationSeconds'] as int? ?? 0),
      isPremium: json['isPremium'] as bool? ?? false,
      isNew: json['isNew'] as bool? ?? false,
      playCount: json['playCount'] as int? ?? 0,
      addedAt: json['addedAt'] != null
          ? DateTime.tryParse(json['addedAt'] as String)
          : null,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'narrator': narrator,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'durationSeconds': duration.inSeconds,
      'isPremium': isPremium,
      'isNew': isNew,
      'playCount': playCount,
      'addedAt': addedAt?.toIso8601String(),
      'tags': tags,
    };
  }

  String get formattedDuration {
    final mins = duration.inMinutes;
    if (mins < 60) return '${mins}m';
    final hrs = mins ~/ 60;
    final rem = mins % 60;
    return rem > 0 ? '${hrs}h ${rem}m' : '${hrs}h';
  }
}
