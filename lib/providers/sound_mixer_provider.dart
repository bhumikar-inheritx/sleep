import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/soundscape.dart';

/// Manages multiple audio players to mix different sounds together.
class SoundMixerProvider extends ChangeNotifier {
  // Map of sound ID to its dedicated AudioPlayer
  final Map<String, AudioPlayer> _players = {};
  
  // Track the current volume of each active sound (0.0 to 1.0)
  final Map<String, double> _volumes = {};

  bool get isPlaying => _players.values.any((p) => p.playing);
  
  bool isSoundActive(String soundId) => _players.containsKey(soundId);
  double getVolume(String soundId) => _volumes[soundId] ?? 0.0;

  /// Max number of sounds allowed to play at once
  static const int maxActiveSounds = 5;

  @override
  void dispose() {
    _stopAll();
    super.dispose();
  }

  /// Toggles a sound on or off. If turning on, it starts at 50% volume.
  Future<void> toggleSound(Soundscape sound) async {
    if (isSoundActive(sound.id)) {
      await _removeSound(sound.id);
    } else {
      if (_players.length >= maxActiveSounds) {
        // Here we could throw an exception or notify the UI 
        // to show a snackbar "Max sounds reached".
        // For now, we'll just ignore the addition.
        return;
      }
      await _addSound(sound);
    }
  }

  /// Sets the volume for a specific active sound.
  void setVolume(String soundId, double volume) {
    if (_players.containsKey(soundId)) {
      _volumes[soundId] = volume;
      _players[soundId]?.setVolume(volume);
      notifyListeners();
    }
  }

  /// Pauses all currently playing sounds.
  Future<void> pauseAll() async {
    for (final player in _players.values) {
      await player.pause();
    }
    notifyListeners();
  }

  /// Resumes all active sounds.
  Future<void> playAll() async {
    for (final player in _players.values) {
      await player.play();
    }
    notifyListeners();
  }

  /// Stops and removes all sounds from the mix.
  Future<void> clearMix() async {
    await _stopAll();
    notifyListeners();
  }

  // --- Private Helpers ---

  Future<void> _addSound(Soundscape sound) async {
    final player = AudioPlayer();
    
    // Set looping
    await player.setLoopMode(sound.isLoopable ? LoopMode.one : LoopMode.off);
    
    try {
      if (sound.audioUrl.startsWith('assets/')) {
        await player.setAsset(sound.audioUrl);
      } else {
        await player.setUrl(sound.audioUrl);
      }
      
      // Default volume is 50%
      final initialVolume = 0.5;
      await player.setVolume(initialVolume);
      
      _players[sound.id] = player;
      _volumes[sound.id] = initialVolume;
      
      // Auto-play the newly added sound
      player.play();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading sound ${sound.id}: $e');
      player.dispose();
    }
  }

  Future<void> _removeSound(String soundId) async {
    final player = _players.remove(soundId);
    _volumes.remove(soundId);
    
    if (player != null) {
      await player.stop();
      await player.dispose();
    }
    notifyListeners();
  }

  Future<void> _stopAll() async {
    for (final player in _players.values) {
      await player.stop();
      await player.dispose();
    }
    _players.clear();
    _volumes.clear();
  }
}
