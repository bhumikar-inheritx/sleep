import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../config/constants.dart';
import '../../models/meditation.dart';
import '../../providers/audio_player_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/glass_card.dart';

class MeditationPlayerScreen extends StatefulWidget {
  final Meditation meditation;
  final String? heroTag;

  const MeditationPlayerScreen({
    super.key,
    required this.meditation,
    this.heroTag,
  });

  @override
  State<MeditationPlayerScreen> createState() => _MeditationPlayerScreenState();
}

class _MeditationPlayerScreenState extends State<MeditationPlayerScreen> {
  bool _showControls = true;
  bool _isDragging = false;
  double _dragValue = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final audioProvider = Provider.of<AudioPlayerProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Track in history
      authProvider.addToRecentlyPlayed(widget.meditation.id);
      
      if (audioProvider.currentId != widget.meditation.id) {
        audioProvider.loadAndPlay(
          url: widget.meditation.audioUrl,
          id: widget.meditation.id,
          title: widget.meditation.title,
          type: AudioContentType.meditation,
          artist: widget.meditation.instructor,
          category: widget.meditation.category,
          imageUrl: widget.meditation.imageUrl,
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
    if (d.isNegative) d = Duration.zero;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inHours > 0 ? '${d.inHours}:' : ''}$minutes:$seconds';
  }

  void _showTimerSheet(BuildContext context, AudioPlayerProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: SleepColors.surfaceGlass,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final options = [
          {'label': '15 Minutes', 'duration': const Duration(minutes: 15)},
          {'label': '30 Minutes', 'duration': const Duration(minutes: 30)},
          {'label': '45 Minutes', 'duration': const Duration(minutes: 45)},
          {'label': '1 Hour', 'duration': const Duration(hours: 1)},
          {'label': 'End of Session', 'duration': provider.duration - provider.position},
        ];

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Sleep Timer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (provider.isSleepTimerActive)
                ListTile(
                  title: const Text('Turn Off Timer', style: TextStyle(color: Colors.redAccent)),
                  leading: const Icon(Icons.timer_off_outlined, color: Colors.redAccent),
                  onTap: () {
                    provider.cancelSleepTimer();
                    Navigator.pop(context);
                  },
                ),
              ...options.map((opt) => ListTile(
                title: Text(opt['label'] as String, style: const TextStyle(color: Colors.white)),
                leading: const Icon(Icons.timer_outlined, color: SleepColors.textSecondary),
                onTap: () {
                  final dur = opt['duration'] as Duration;
                  if (dur.inSeconds > 0) {
                    provider.setSleepTimer(dur);
                  }
                  Navigator.pop(context);
                },
              )),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: widget.heroTag ?? 'meditation_art_${widget.meditation.id}',
              child: Image.asset(
                widget.meditation.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: SleepColors.surfaceLight,
                    child: const Icon(
                      Icons.self_improvement,
                      color: SleepColors.textMuted,
                      size: 80,
                    ),
                  );
                },
              ),
            ),
            
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

            SafeArea(
              child: AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: AppConstants.animFast,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTopBar(context),
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
                  const Icon(Icons.self_improvement, color: SleepColors.primaryLight, size: 14),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      widget.meditation.category,
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
                Text(
                  widget.meditation.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                Text(
                  'Guided by ${widget.meditation.instructor}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SleepColors.primaryLight,
                  ),
                ),
                
                const SizedBox(height: 32),
                
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
                        audioProvider.isSleepTimerActive 
                          ? '${_formatDuration(audioProvider.sleepTimerRemaining ?? Duration.zero)} (Timer)' 
                          : _formatDuration(audioProvider.duration),
                        style: TextStyle(
                          color: audioProvider.isSleepTimerActive ? SleepColors.primaryLight : SleepColors.textMuted, 
                          fontSize: 12,
                          fontWeight: audioProvider.isSleepTimerActive ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                        icon: Icon(
                          audioProvider.isSleepTimerActive ? Icons.timer : Icons.timer_outlined,
                          color: audioProvider.isSleepTimerActive ? SleepColors.primaryLight : SleepColors.textSecondary,
                        ),
                        onPressed: () => _showTimerSheet(context, audioProvider),
                      ),
                    IconButton(
                      icon: const Icon(Icons.replay_10, color: Colors.white, size: 32),
                      onPressed: () {
                        audioProvider.seek(audioProvider.position - const Duration(seconds: 10));
                      },
                    ),
                    
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
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        final isFavorite = auth.profile?.favorites.contains(widget.meditation.id) ?? false;
                        return IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite
                                ? Colors.redAccent
                                : SleepColors.textSecondary,
                          ),
                          onPressed: () => auth.toggleFavorite(widget.meditation.id),
                        );
                      },
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
