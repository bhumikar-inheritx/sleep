import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../config/constants.dart';
import '../../providers/audio_player_provider.dart';
import '../../providers/content_provider.dart';
import '../../screens/player/music_player_screen.dart';
import '../../screens/player/story_player_screen.dart';

/// A persistent mini player bar that floats above the bottom navigation.
class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerProvider>(
      builder: (context, audioProvider, child) {
        if (!audioProvider.hasAudio) {
          return const SizedBox.shrink();
        }

        if (audioProvider.isPlaying) {
          if (!_pulseController.isAnimating) _pulseController.repeat(reverse: true);
        } else {
          _pulseController.stop();
        }

        return ScaleTransition(
          scale: audioProvider.isPlaying ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
          child: GestureDetector(
            onTap: () {
              if (audioProvider.currentType == AudioContentType.story) {
                final content = Provider.of<ContentProvider>(context, listen: false);
                final story = content.stories.firstWhere((s) => s.id == audioProvider.currentId);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StoryPlayerScreen(story: story)),
                );
              } else if (audioProvider.currentType == AudioContentType.music) {
                final content = Provider.of<ContentProvider>(context, listen: false);
                final track = content.music.firstWhere((t) => t.id == audioProvider.currentId);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MusicPlayerScreen(track: track)),
                );
              }
            },
            child: Container(
              height: 64,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: SleepColors.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                border: Border.all(
                  color: audioProvider.isPlaying 
                      ? SleepColors.primary.withValues(alpha: 0.3) 
                      : Colors.white.withValues(alpha: 0.05),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: audioProvider.isPlaying 
                        ? SleepColors.primary.withValues(alpha: 0.2) 
                        : Colors.black.withValues(alpha: 0.3),
                    blurRadius: audioProvider.isPlaying ? 20 : 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  // Tiny cover art
                  Hero(
                    tag: audioProvider.currentType == AudioContentType.music 
                        ? 'music_art_${audioProvider.currentId}' 
                        : 'story_art_${audioProvider.currentId}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Image.asset(
                          audioProvider.currentImageUrl ?? 'assets/images/placeholder_cover.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(color: SleepColors.surfaceLight),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Track Info
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          audioProvider.currentTitle ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          audioProvider.currentCategory ?? '',
                          style: const TextStyle(
                            color: SleepColors.textSecondary,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Play/Pause Button
                  IconButton(
                    icon: Icon(
                      audioProvider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: audioProvider.isLoading ? null : audioProvider.togglePlayPause,
                  ),
                  
                  // Close/Stop Button
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: SleepColors.textMuted, size: 24),
                    onPressed: audioProvider.stop,
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
