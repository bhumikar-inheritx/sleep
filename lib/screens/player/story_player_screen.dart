import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../config/constants.dart';
import '../../models/sleep_story.dart';
import '../../providers/audio_player_provider.dart';
import '../../widgets/common/glass_card.dart';

class StoryPlayerScreen extends StatefulWidget {
  final SleepStory story;
  final String? heroTag;

  const StoryPlayerScreen({
    super.key,
    required this.story,
    this.heroTag,
  });

  @override
  State<StoryPlayerScreen> createState() => _StoryPlayerScreenState();
}

class _StoryPlayerScreenState extends State<StoryPlayerScreen> {
  bool _showControls = true;
  bool _isDragging = false;
  double _dragValue = 0.0;

  @override
  void initState() {
    super.initState();
    // Start playback when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final audioProvider = Provider.of<AudioPlayerProvider>(context, listen: false);
      
      // Only load and play if it's a different story than what's currently loaded
      if (audioProvider.currentId != widget.story.id) {
        audioProvider.loadAndPlay(
          url: widget.story.audioUrl,
          id: widget.story.id,
          title: widget.story.title,
          type: AudioContentType.story,
          artist: widget.story.narrator,
          category: widget.story.category,
          imageUrl: widget.story.imageUrl,
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
            // Background Image
            Hero(
              tag: widget.heroTag ?? 'story_art_${widget.story.id}',
              child: Image.asset(
                widget.story.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            
            // Background Gradient overlay (darkens when controls are visible)
            AnimatedContainer(
              duration: AppConstants.animFast,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: _showControls 
                      ? [
                          SleepColors.background.withValues(alpha: 0.7),
                          SleepColors.background.withValues(alpha: 0.3),
                          SleepColors.background.withValues(alpha: 0.9),
                        ]
                      : [
                          SleepColors.background.withValues(alpha: 0.2),
                          Colors.transparent,
                          SleepColors.background.withValues(alpha: 0.5),
                        ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),

            // UI Elements
            SafeArea(
              child: AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: AppConstants.animFast,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Bar
                    _buildTopBar(context),
                    
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
                  const Icon(Icons.bedtime, color: SleepColors.primaryLight, size: 14),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      widget.story.category,
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
            onPressed: () {}, // Options menu (timer, sleep settings)
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
                  widget.story.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                Text(
                  'Narrated by ${widget.story.narrator}',
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
                      icon: const Icon(Icons.replay_10, color: Colors.white, size: 32),
                      onPressed: () {
                        audioProvider.seek(audioProvider.position - const Duration(seconds: 10));
                      },
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
                      icon: const Icon(Icons.forward_10, color: Colors.white, size: 32),
                      onPressed: () {
                         audioProvider.seek(audioProvider.position + const Duration(seconds: 10));
                      },
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
