import 'package:flutter/foundation.dart';
import '../models/meditation.dart';
import '../models/sleep_story.dart';
import '../models/sleep_track.dart';
import 'auth_provider.dart';
import 'content_provider.dart';

class RecommendationProvider extends ChangeNotifier {
  final AuthProvider auth;
  final ContentProvider content;

  RecommendationProvider({
    required this.auth,
    required this.content,
  });

  List<SleepStory> get recommendedStories {
    final prefs = auth.profile?.preferredContent ?? [];
    final history = auth.profile?.recentlyPlayed ?? [];
    
    // Filter out recently played if we have enough other content
    var list = content.stories.toList();
    var filtered = list.where((s) => !history.contains(s.id)).toList();
    
    if (filtered.length < 3) filtered = list; // Fallback to all if history is full

    // Sort by preference match
    filtered.sort((a, b) {
      final aMatch = prefs.contains(a.category);
      final bMatch = prefs.contains(b.category);
      if (aMatch && !bMatch) return -1;
      if (!aMatch && bMatch) return 1;
      return 0;
    });
    
    return filtered.take(5).toList();
  }

  List<SleepTrack> get recommendedMusic {
    final prefs = auth.profile?.preferredContent ?? [];
    final history = auth.profile?.recentlyPlayed ?? [];
    
    var list = content.music.toList();
    var filtered = list.where((m) => !history.contains(m.id)).toList();
    
    if (filtered.length < 3) filtered = list;

    filtered.sort((a, b) {
      final aMatch = prefs.contains(a.category);
      final bMatch = prefs.contains(b.category);
      if (aMatch && !bMatch) return -1;
      if (!aMatch && bMatch) return 1;
      return 0;
    });
    
    return filtered.take(5).toList();
  }

  List<Meditation> get recommendedMeditations {
    final prefs = auth.profile?.preferredContent ?? [];
    final history = auth.profile?.recentlyPlayed ?? [];
    
    var list = content.meditations.toList();
    var filtered = list.where((m) => !history.contains(m.id)).toList();
    
    if (filtered.length < 3) filtered = list;

    filtered.sort((a, b) {
      final aMatch = prefs.contains(a.category);
      final bMatch = prefs.contains(b.category);
      if (aMatch && !bMatch) return -1;
      if (!aMatch && bMatch) return 1;
      return 0;
    });
    
    return filtered.take(5).toList();
  }

  /// Returns a mix of content optimized for the current time of day
  List<dynamic> get tonightHighlights {
    final hour = DateTime.now().hour;

    if (hour >= 20 || hour <= 4) {
      // Night: Heavy on stories and deep sleep music
      return [
        ...recommendedStories.take(2),
        ...recommendedMusic.take(1),
        ...recommendedMeditations.take(1),
      ]..shuffle();
    } else {
      // Day/Evening: More meditations and ambient music
      return [
        ...recommendedMeditations.take(2),
        ...recommendedMusic.take(2),
      ]..shuffle();
    }
  }

  List<dynamic> get personalizedPicks {
    return [
      ...recommendedStories.take(3),
      ...recommendedMusic.take(3),
      ...recommendedMeditations.take(3),
    ]..shuffle();
  }
}
