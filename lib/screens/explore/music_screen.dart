import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../config/constants.dart';
import '../../providers/audio_player_provider.dart';
import '../../widgets/common/mini_player.dart';

import '../../models/sleep_track.dart';
import '../../providers/content_provider.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/sleep_app_bar.dart';
import '../player/music_player_screen.dart';
import '../../widgets/common/app_background.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  String _selectedCategory = 'All';

  // Use categories from constants
  final List<String> _musicCategories = AppConstants.musicCategories;

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: const SleepAppBar(
          title: 'Sleep Music',
          transparent: true,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Consumer<ContentProvider>(
                builder: (context, contentProvider, child) {
                  if (contentProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: SleepColors.primary),
                    );
                  }

                  // Filter music by category locally (mock behavior)
                  List<SleepTrack> tracks = contentProvider.music;
                  if (_selectedCategory != 'All') {
                    tracks = tracks
                        .where((t) => t.category == _selectedCategory)
                        .toList();
                  }

                  return Column(
                    children: [
                      _buildCategorySelector(),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _buildMusicList(tracks),
                      ),
                    ],
                  );
                },
              ),
              
              // Floating Mini Player
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: MiniPlayer(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _musicCategories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = _musicCategories[index];
          final isSelected = category == _selectedCategory;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: AnimatedContainer(
              duration: AppConstants.animFast,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? SleepColors.primary : SleepColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: isSelected ? null : Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : SleepColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMusicList(List<SleepTrack> tracks) {
    if (tracks.isEmpty) {
      return Center(
        child: Text(
          'No tracks found in this category.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: SleepColors.textMuted,
              ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0, bottom: 100.0),
      physics: const BouncingScrollPhysics(),
      itemCount: tracks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final track = tracks[index];
        return _MusicCard(track: track);
      },
    );
  }
}

class _MusicCard extends StatelessWidget {
  final SleepTrack track;

  const _MusicCard({required this.track});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MusicPlayerScreen(track: track),
          ),
        );
      },
      child: Row(
        children: [
          // Album Art
          Hero(
            tag: 'music_art_${track.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 72,
                height: 72,
                child: Image.asset(
                  track.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: SleepColors.surfaceLight,
                    child: const Icon(Icons.music_note, color: SleepColors.primaryLight),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  track.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  track.artist,
                  style: const TextStyle(
                    color: SleepColors.textSecondary,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: SleepColors.surfaceGlass,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        track.category,
                        style: const TextStyle(fontSize: 10, color: SleepColors.primaryLight),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      track.formattedDuration,
                      style: const TextStyle(
                        color: SleepColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Play Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SleepColors.primary.withValues(alpha: 0.1),
            ),
            child: const Icon(Icons.play_arrow_rounded, color: SleepColors.primaryLight),
          ),
        ],
      ),
    );
  }
}
