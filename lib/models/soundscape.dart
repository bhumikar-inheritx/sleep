/// Model for an individual sound in the soundscape library.
class Soundscape {
  final String id;
  final String name;
  final String category;
  final String iconName; // Maps to a custom animated icon or asset
  final String audioUrl;
  final bool isLoopable;

  const Soundscape({
    required this.id,
    required this.name,
    required this.category,
    required this.iconName,
    required this.audioUrl,
    this.isLoopable = true,
  });

  factory Soundscape.fromJson(Map<String, dynamic> json) {
    return Soundscape(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String? ?? 'Nature',
      iconName: json['iconName'] as String? ?? 'water',
      audioUrl: json['audioUrl'] as String,
      isLoopable: json['isLoopable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'iconName': iconName,
      'audioUrl': audioUrl,
      'isLoopable': isLoopable,
    };
  }
}

/// A user-created or preset mix of multiple sounds with individual volumes.
class SoundMix {
  final String id;
  final String name;
  final bool isPreset;
  final List<SoundMixEntry> entries;

  const SoundMix({
    required this.id,
    required this.name,
    this.isPreset = false,
    required this.entries,
  });

  factory SoundMix.fromJson(Map<String, dynamic> json) {
    return SoundMix(
      id: json['id'] as String,
      name: json['name'] as String,
      isPreset: json['isPreset'] as bool? ?? false,
      entries: (json['entries'] as List<dynamic>?)
              ?.map((e) => SoundMixEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isPreset': isPreset,
      'entries': entries.map((e) => e.toJson()).toList(),
    };
  }
}

/// A single sound + volume level in a mix.
class SoundMixEntry {
  final String soundId;
  final double volume; // 0.0 to 1.0

  const SoundMixEntry({
    required this.soundId,
    this.volume = 0.7,
  });

  factory SoundMixEntry.fromJson(Map<String, dynamic> json) {
    return SoundMixEntry(
      soundId: json['soundId'] as String,
      volume: (json['volume'] as num?)?.toDouble() ?? 0.7,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'soundId': soundId,
      'volume': volume,
    };
  }
}
