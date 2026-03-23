import 'package:flutter/foundation.dart';

import '../models/meditation.dart';
import '../models/sleep_story.dart';
import '../models/sleep_track.dart';
import '../models/soundscape.dart';

/// Provider for fetching and caching content.
/// Loads real local audio assets from assets/audio/.
class ContentProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Data Collections
  List<SleepStory> _stories = [];
  List<SleepTrack> _music = [];
  List<Soundscape> _sounds = [];
  List<Meditation> _meditations = [];

  List<SleepStory> get stories => _stories;
  List<SleepTrack> get music => _music;
  List<Soundscape> get sounds => _sounds;
  List<Meditation> get meditations => _meditations;

  ContentProvider() {
    _loadContent();
  }

  Future<void> _loadContent() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    // ─── Stories (from assets/audio/Stories/) ───────────────────
    _stories = [
      SleepStory(
        id: 'story_1',
        title: 'Giant Panda',
        narrator: 'DreamDrift Narrator',
        description: 'A gentle tale about a giant panda wandering through a bamboo forest under the moonlight.',
        category: 'Nature',
        imageUrl: 'assets/images/story_giant_panda.png',
        audioUrl: 'assets/audio/Stories/Giant_Panda_-_NEW7k0p9.mp3',
        duration: const Duration(minutes: 22),
        isNew: true,
      ),
      SleepStory(
        id: 'story_2',
        title: 'Midnight Train',
        narrator: 'DreamDrift Narrator',
        description: 'The rhythmic clicking of wheels on tracks leads you through moonlit valleys.',
        category: 'Nature',
        imageUrl: 'assets/images/story_midnight_train.png',
        audioUrl: 'assets/audio/Stories/Just_for_Today8r70o.mp3', // Reusing available audio
        duration: const Duration(minutes: 45),
      ),
      SleepStory(
        id: 'story_3',
        title: 'Lavender Field',
        narrator: 'DreamDrift Narrator',
        description: 'Drift through endless purple fields as the scent of lavender calms your mind.',
        category: 'Nature',
        imageUrl: 'assets/images/story_lavender_field.png',
        audioUrl: 'assets/audio/Stories/Super_Power_SpectaclesMP39rui4.mp3', // Reusing available audio
        duration: const Duration(minutes: 30),
        isNew: true,
      ),
      SleepStory(
        id: 'story_4',
        title: 'Rainy Window',
        narrator: 'DreamDrift Narrator',
        description: 'Listen to the gentle pitter-patter of rain against the glass of a cozy cabin.',
        category: 'Rain',
        imageUrl: 'assets/images/story_rainy_window.png',
        audioUrl: 'assets/audio/Stories/Unicorn_Sleepoverb5ieu.mp3', // Reusing available audio
        duration: const Duration(minutes: 33),
      ),
      SleepStory(
        id: 'story_5',
        title: 'Space voyage',
        narrator: 'Armonicamente',
        description: 'Float weightlessly through the cosmic silence of a distant nebula.',
        category: 'Nature',
        imageUrl: 'assets/images/story_space_voyage.png',
        audioUrl: 'assets/audio/Stories/armonicamente-sleep-141321.mp3',
        duration: const Duration(minutes: 17),
      ),
      SleepStory(
        id: 'story_6',
        title: 'Lunar Journey',
        narrator: 'VFS World',
        description: 'A silver path across the moon leads you to deep, cratered silence.',
        category: 'Fairytales',
        imageUrl: 'assets/images/onboarding_moon.png',
        audioUrl: 'assets/audio/Stories/vfs_world-relaxing-sleep-music-for-stress-relief-deep-sleep-on-bed-time-482793.mp3',
        duration: const Duration(minutes: 10),
      ),
    ];

    // ─── Music & Sounds (from assets/audio/music_sounds/) ──────
    _music = [
      SleepTrack(
        id: 'music_1',
        title: '25 Hz Delta Waves',
        artist: 'DreamDrift Originals',
        category: 'Binaural',
        imageUrl: 'assets/images/soundscape_ocean_night.png',
        audioUrl: 'assets/audio/music_sounds/25-hz-delta-waves-with-rain-deep-sleep-amp-restoration-457283.mp3',
        duration: const Duration(minutes: 13),
      ),
      SleepTrack(
        id: 'music_2',
        title: 'Calming Music for Deep Sleep',
        artist: 'DreamDrift Originals',
        category: 'Ambient',
        imageUrl: 'assets/images/onboarding_moon.png',
        audioUrl: 'assets/audio/music_sounds/calming-music-for-deep-sleep-457510.mp3',
        duration: const Duration(minutes: 20),
      ),
      SleepTrack(
        id: 'music_3',
        title: 'Morning Dew Zen',
        artist: 'CFL Turning Pages',
        category: 'Piano',
        imageUrl: 'assets/images/placeholder_cover.png',
        audioUrl: 'assets/audio/music_sounds/cfl_turningpages-morning-dew-zen-459268.mp3',
        duration: const Duration(minutes: 2),
      ),
      SleepTrack(
        id: 'music_4',
        title: 'Stress Relief Meditation',
        artist: 'Crystal Eye',
        category: 'Ambient',
        imageUrl: 'assets/images/soundscape_forest_night.png',
        audioUrl: 'assets/audio/music_sounds/crystaleyeofficial-stress-relief-nature-background-meditation-music-track-328750.mp3',
        duration: const Duration(minutes: 2),
      ),
      SleepTrack(
        id: 'music_5',
        title: 'Deep Sleep',
        artist: 'NN Channel',
        category: 'Ambient',
        imageUrl: 'assets/images/placeholder_cover.png',
        audioUrl: 'assets/audio/music_sounds/deep-sleep-308846.mp3',
        duration: const Duration(minutes: 5),
      ),
      SleepTrack(
        id: 'music_6',
        title: 'Dreamy Tranquility (528 Hz)',
        artist: 'DreamDrift Originals',
        category: 'Binaural',
        imageUrl: 'assets/images/story_space_voyage.png',
        audioUrl: 'assets/audio/music_sounds/dreamy-tranquilitysoothing-528-hz-theta-sound-waves-316843.mp3',
        duration: const Duration(minutes: 27),
      ),
      SleepTrack(
        id: 'music_7',
        title: 'Creativity & Emotional Release',
        artist: 'HoggyArt',
        category: 'Piano',
        imageUrl: 'assets/images/story_lavender_field.png',
        audioUrl: 'assets/audio/music_sounds/hoggyart-creativity-and-emotional-release-224204.mp3',
        duration: const Duration(minutes: 3),
      ),
      SleepTrack(
        id: 'music_8',
        title: 'Meditation Rain',
        artist: 'Kals Stockmedia',
        category: 'Ambient',
        imageUrl: 'assets/images/story_rainy_window.png',
        audioUrl: 'assets/audio/music_sounds/kalsstockmedia-meditation-rain-music-1-minute-270982.mp3',
        duration: const Duration(minutes: 1),
      ),
      SleepTrack(
        id: 'music_9',
        title: 'Meditation Relax C Major',
        artist: 'DreamDrift Originals',
        category: 'Classical',
        imageUrl: 'assets/images/placeholder_cover.png',
        audioUrl: 'assets/audio/music_sounds/meditation-relax-deep-sleep-quotc-majorquot-music-150647.mp3',
        duration: const Duration(minutes: 5),
      ),
      SleepTrack(
        id: 'music_10',
        title: 'Tibetan Bowl in Nature',
        artist: 'Meditative Tiger',
        category: 'Ambient',
        imageUrl: 'assets/images/placeholder_cover.png',
        audioUrl: 'assets/audio/music_sounds/meditativetiger-tibetan-bowl-meditation-in-nature-peaceful-music-for-toddlers-387016.mp3',
        duration: const Duration(minutes: 2),
      ),
      SleepTrack(
        id: 'music_11',
        title: 'Yoga Nidra Soundscape',
        artist: 'Meditative Tiger',
        category: 'Ambient',
        imageUrl: 'assets/images/placeholder_cover.png',
        audioUrl: 'assets/audio/music_sounds/meditativetiger-yoga-nidra-soundscape-deep-relaxation-489162.mp3',
        duration: const Duration(minutes: 3),
      ),
      SleepTrack(
        id: 'music_12',
        title: 'Frequency of Sleep',
        artist: 'Natures Eye',
        category: 'Binaural',
        imageUrl: 'assets/images/placeholder_cover.png',
        audioUrl: 'assets/audio/music_sounds/natureseye-frequency-of-sleep-meditation-113050.mp3',
        duration: const Duration(minutes: 40),
      ),
      SleepTrack(
        id: 'music_13',
        title: 'Deep Sleep II',
        artist: 'NN Channel',
        category: 'Ambient',
        imageUrl: 'assets/images/placeholder_cover.png',
        audioUrl: 'assets/audio/music_sounds/nnchannel-deep-sleep-308846.mp3',
        duration: const Duration(minutes: 5),
      ),
      SleepTrack(
        id: 'music_14',
        title: 'Tibetan Bells',
        artist: 'DreamDrift Originals',
        category: 'Piano',
        imageUrl: 'assets/images/story_midnight_train.png',
        audioUrl: 'assets/audio/music_sounds/sleep-inducing-tibetan-bells-388638.mp3',
        duration: const Duration(minutes: 3),
      ),
      SleepTrack(
        id: 'music_15',
        title: 'Sleep Music Vol. 15',
        artist: 'DreamDrift Originals',
        category: 'Lofi',
        imageUrl: 'assets/images/placeholder_cover.png',
        audioUrl: 'assets/audio/music_sounds/sleep-music-vol15-195425.mp3',
        duration: const Duration(minutes: 29),
      ),
    ];

    // ─── Soundscapes (reusable from music_sounds for mixer) ────
    _sounds = [
      const Soundscape(
        id: 'snd_rain',
        name: 'Meditation Rain',
        category: 'Rain',
        iconName: 'rain_heavy',
        audioUrl: 'assets/audio/music_sounds/kalsstockmedia-meditation-rain-music-1-minute-270982.mp3',
      ),
      const Soundscape(
        id: 'snd_delta',
        name: 'Delta Waves + Rain',
        category: 'White Noise',
        iconName: 'waves',
        audioUrl: 'assets/audio/music_sounds/25-hz-delta-waves-with-rain-deep-sleep-amp-restoration-457283.mp3',
      ),
      const Soundscape(
        id: 'snd_tibetan',
        name: 'Tibetan Bowls',
        category: 'Nature',
        iconName: 'bells',
        audioUrl: 'assets/audio/music_sounds/sleep-inducing-tibetan-bells-388638.mp3',
      ),
      const Soundscape(
        id: 'snd_yoga',
        name: 'Yoga Nidra',
        category: 'Nature',
        iconName: 'wind',
        audioUrl: 'assets/audio/music_sounds/meditativetiger-yoga-nidra-soundscape-deep-relaxation-489162.mp3',
      ),
      const Soundscape(
        id: 'snd_nature',
        name: 'Nature Meditation',
        category: 'Forest',
        iconName: 'birds',
        audioUrl: 'assets/audio/music_sounds/meditativetiger-tibetan-bowl-meditation-in-nature-peaceful-music-for-toddlers-387016.mp3',
      ),
    ];

    // ─── Meditations (from assets/audio/music_sounds/ mostly for now) ───
    _meditations = [
      Meditation(
        id: 'med_1',
        title: 'Deep Body Scan',
        instructor: 'Sarah Jenkins',
        description: 'A guided journey through your body to release physical tension.',
        category: 'Body Scan',
        imageUrl: 'assets/images/story_giant_panda.png',
        audioUrl: 'assets/audio/music_sounds/calming-music-for-deep-sleep-457510.mp3',
        duration: const Duration(minutes: 15),
        isNew: true,
      ),
      Meditation(
        id: 'med_2',
        title: 'Gratitude Reflection',
        instructor: 'Marcus Cole',
        description: 'End your day by reflecting on the positive moments.',
        category: 'Gratitude',
        imageUrl: 'assets/images/story_midnight_train.png',
        audioUrl: 'assets/audio/music_sounds/crystaleyeofficial-stress-relief-nature-background-meditation-music-track-328750.mp3',
        duration: const Duration(minutes: 10),
      ),
      Meditation(
        id: 'med_3',
        title: 'Sleep Yoga Nidra',
        instructor: 'Dr. Elena Rostova',
        description: 'Deep relaxation technique to bring you into a state of conscious sleep.',
        category: 'Yoga Nidra',
        imageUrl: 'assets/images/story_lavender_field.png',
        audioUrl: 'assets/audio/music_sounds/meditativetiger-yoga-nidra-soundscape-deep-relaxation-489162.mp3',
        duration: const Duration(minutes: 25),
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  List<SleepStory> getStoriesByCategory(String category) {
    if (category == 'All') return _stories;
    return _stories.where((s) => s.category == category).toList();
  }

  List<SleepTrack> getMusicByCategory(String category) {
    if (category == 'All') return _music;
    return _music.where((t) => t.category == category).toList();
  }

  List<Meditation> getMeditationsByCategory(String category) {
    if (category == 'All') return _meditations;
    return _meditations.where((m) => m.category == category).toList();
  }
}
