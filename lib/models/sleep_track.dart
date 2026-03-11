/// Model for a sleep music track.
class SleepTrack {
  final String id;
  final String title;
  final String artist;
  final String category;
  final String imageUrl;
  final String audioUrl;
  final Duration duration;
  final bool isPremium;
  final List<String> tags;

  const SleepTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.category,
    required this.imageUrl,
    required this.audioUrl,
    required this.duration,
    this.isPremium = false,
    this.tags = const [],
  });

  factory SleepTrack.fromJson(Map<String, dynamic> json) {
    return SleepTrack(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String? ?? 'Unknown',
      category: json['category'] as String? ?? 'Ambient',
      imageUrl: json['imageUrl'] as String? ?? '',
      audioUrl: json['audioUrl'] as String,
      duration: Duration(seconds: json['durationSeconds'] as int? ?? 0),
      isPremium: json['isPremium'] as bool? ?? false,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'category': category,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'durationSeconds': duration.inSeconds,
      'isPremium': isPremium,
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
