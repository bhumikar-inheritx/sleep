import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../config/constants.dart';
import '../../models/sleep_track.dart';
import '../../providers/audio_player_provider.dart';
import '../../widgets/common/glass_card.dart';

class MusicPlayerScreen extends StatefulWidget {
  final SleepTrack track;
  final String? heroTag;

  const MusicPlayerScreen({
    super.key,
    required this.track,
    this.heroTag,
  });

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  bool _showControls = true;
  bool _isDragging = false;
  double _dragValue = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final audioProvider = Provider.of<AudioPlayerProvider>(context, listen: false);
      
      // Only load and play if it's a different track than what's currently loaded
      if (audioProvider.currentId != widget.track.id) {
        audioProvider.loadAndPlay(
          url: widget.track.audioUrl,
          id: widget.track.id,
          title: widget.track.title,
          type: AudioContentType.music,
          artist: widget.track.artist,
          category: widget.track.category,
          imageUrl: widget.track.imageUrl,
        );
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inHours > 0 ? '${d.inHours}:' : ''}$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image (Blurred for music)
            Image.asset(
              widget.track.imageUrl,
              fit: BoxFit.cover,
            ),
            
            // Blur overlay for music screen
            Container(
              color: SleepColors.background.withValues(alpha: 0.85),
            ),

            // UI Elements
            SafeArea(
              child: AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: AppConstants.animFast,
                child: Column(
                  children: [
                    // Top Bar
                    _buildTopBar(context),
                    
                    const Spacer(),
                    
                    // Album Art
                    Hero(
                      tag: widget.heroTag ?? 'music_art_${widget.track.id}',
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: MediaQuery.of(context).size.width * 0.7,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                          image: DecorationImage(
                            image: AssetImage(widget.track.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Bottom Controls
                    _buildBottomControls(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 32),
            onPressed: () => Navigator.pop(context),
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: SleepColors.surfaceGlass,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.music_note, color: SleepColors.primaryLight, size: 14),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      widget.track.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Consumer<AudioPlayerProvider>(
          builder: (context, audioProvider, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title & Author
                Text(
                  widget.track.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.track.artist,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SleepColors.primaryLight,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Progress Slider
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                  ),
                  child: Slider(
                    value: _isDragging 
                        ? _dragValue 
                        : audioProvider.position.inSeconds.toDouble().clamp(
                            0.0,
                            audioProvider.duration.inSeconds.toDouble().clamp(1.0, double.infinity),
                          ),
                    max: audioProvider.duration.inSeconds.toDouble().clamp(1.0, double.infinity),
                    onChangeStart: (val) {
                      setState(() {
                        _isDragging = true;
                        _dragValue = val;
                      });
                    },
                    onChanged: (val) {
                      setState(() {
                        _dragValue = val;
                      });
                    },
                    onChangeEnd: (val) {
                      audioProvider.seek(Duration(seconds: val.toInt()));
                      setState(() {
                        _isDragging = false;
                      });
                    },
                  ),
                ),
                
                // Time Indicators
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(audioProvider.position),
                        style: const TextStyle(color: SleepColors.textMuted, fontSize: 12),
                      ),
                      Text(
                        _formatDuration(audioProvider.duration),
                        style: const TextStyle(color: SleepColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Playback Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.timer_outlined, color: SleepColors.textSecondary),
                      onPressed: () {}, // Timer setter
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_previous, color: Colors.white, size: 32),
                      onPressed: () {}, // Previous track logic
                    ),
                    
                    // Play/Pause Button
                    GestureDetector(
                      onTap: audioProvider.isLoading ? null : audioProvider.togglePlayPause,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: SleepColors.primary,
                          boxShadow: [
                            BoxShadow(
                              color: SleepColors.primary.withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: audioProvider.isLoading 
                            ? const Padding(
                                padding: EdgeInsets.all(24.0),
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                              )
                            : Icon(
                                audioProvider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 40,
                              ),
                      ),
                    ),
                    
                    IconButton(
                      icon: const Icon(Icons.skip_next, color: Colors.white, size: 32),
                      onPressed: () {}, // Next track logic
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite_border, color: SleepColors.textSecondary),
                      onPressed: () {}, // Favorite toggle
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
