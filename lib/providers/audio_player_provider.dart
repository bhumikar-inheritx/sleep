import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';

enum AudioContentType { story, music, meditation }

/// Core provider for playback of Sleep Stories and Sleep Music.
class AudioPlayerProvider extends ChangeNotifier {
  late final AudioPlayer _player;
  
  // State
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _currentId;
  String? _currentTitle;
  String? _currentCategory;
  String? _currentImageUrl;
  AudioContentType? _currentType;

  // Sleep Timer
  Timer? _sleepTimer;
  DateTime? _sleepTimerEndTime;

  // Getters
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  Duration get duration => _duration;
  Duration get position => _position;
  String? get currentId => _currentId;
  String? get currentTitle => _currentTitle;
  String? get currentCategory => _currentCategory;
  String? get currentImageUrl => _currentImageUrl;
  AudioContentType? get currentType => _currentType;
  bool get hasAudio => _currentTitle != null;

  bool get isSleepTimerActive => _sleepTimer != null;
  Duration? get sleepTimerRemaining {
    if (_sleepTimerEndTime == null) return null;
    final remaining = _sleepTimerEndTime!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  AudioPlayerProvider() {
    _player = AudioPlayer();
    _initAudioSession();
    _listenToPlayerState();
    _listenToPosition();
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  void _listenToPlayerState() {
    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      _isLoading = state.processingState == ProcessingState.loading ||
                   state.processingState == ProcessingState.buffering;
      
      if (state.processingState == ProcessingState.completed) {
        _isPlaying = false;
        _position = Duration.zero;
        _player.seek(Duration.zero);
        _player.pause();
      }
      notifyListeners();
    });
  }

  void _listenToPosition() {
    _player.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _player.durationStream.listen((dur) {
      if (dur != null) {
        _duration = dur;
        notifyListeners();
      }
    });
  }

  /// Load and play a track via a remote URL or local asset.
  /// Local asset paths should start with "assets/" (e.g. "assets/audio/...").
  Future<void> loadAndPlay({
    required String url,
    required String id,
    required String title,
    required AudioContentType type,
    String? artist,
    String? category,
    String? imageUrl,
  }) async {
    _isLoading = true;
    _currentId = id;
    _currentTitle = title;
    _currentCategory = category ?? artist ?? 'DreamDrift';
    _currentImageUrl = imageUrl;
    _currentType = type;
    notifyListeners();

    try {
      final bool isLocalAsset = url.startsWith('assets/');

      AudioSource audioSource;
      if (isLocalAsset) {
        audioSource = AudioSource.asset(
          url,
          tag: MediaItem(
            id: id,
            album: _currentCategory,
            title: title,
            artist: artist,
          ),
        );
      } else {
        audioSource = AudioSource.uri(
          Uri.parse(url),
          tag: MediaItem(
            id: id,
            album: _currentCategory,
            title: title,
            artist: artist,
            artUri: imageUrl != null && imageUrl.isNotEmpty ? Uri.parse(imageUrl) : null,
          ),
        );
      }

      await _player.setAudioSource(audioSource);
      await _player.play();
    } catch (e) {
      debugPrint("Error loading audio: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> play() async => await _player.play();
  
  Future<void> pause() async => await _player.pause();
  
  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seek(Duration position) async => await _player.seek(position);

  Future<void> stop() async {
    await _player.stop();
    _currentTitle = null;
    _position = Duration.zero;
    notifyListeners();
  }

  // Sleep Timer Methods
  void setSleepTimer(Duration duration) {
    cancelSleepTimer();
    if (duration == Duration.zero) return;
    
    _sleepTimerEndTime = DateTime.now().add(duration);
    _sleepTimer = Timer(duration, () {
      pause();
      cancelSleepTimer();
    });
    notifyListeners();
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepTimerEndTime = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
