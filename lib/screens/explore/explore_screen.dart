import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/colors.dart';
import '../../config/routes.dart';
import '../../models/sleep_story.dart';
import '../../models/sleep_track.dart';
import '../../providers/auth_provider.dart';
import '../../providers/content_provider.dart';
import '../../screens/player/music_player_screen.dart';
import '../../screens/player/story_player_screen.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/sleep_app_bar.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ContentProvider>(
      builder: (context, content, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: const SleepAppBar(title: 'Explore', transparent: true),
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearch(context),
                  const SizedBox(height: 24),
                  _buildCategories(context),
                  const SizedBox(height: 32),
                  _buildFeaturedHorizontal(
                    context,
                    'Featured Stories',
                    content.stories.take(3).toList(),
                    AppRoutes.stories,
                  ),
                  const SizedBox(height: 32),
                  _buildFeaturedHorizontal(
                    context,
                    'Calming Music',
                    content.music.take(3).toList(),
                    AppRoutes.music,
                  ),
                  const SizedBox(height: 32),
                  _buildGridCategories(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearch(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              color: SleepColors.textSecondary,
            ), // Brightened from textMuted
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search stories, sounds, music...',
                  hintStyle: TextStyle(
                    color: SleepColors.textSecondary,
                  ), // Brightened from textMuted
                  border: InputBorder.none,
                ),
                onSubmitted: (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Search coming soon')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final categories = [
      {'title': 'Stories', 'icon': Icons.menu_book, 'route': AppRoutes.stories},
      {
        'title': 'Meditate',
        'icon': Icons.self_improvement,
        'route': AppRoutes.meditations,
      },
      {
        'title': 'Sounds',
        'icon': Icons.water_drop,
        'route': AppRoutes.soundscapes,
      },
      {'title': 'Music', 'icon': Icons.music_note, 'route': AppRoutes.music},
      {
        'title': 'Breathe',
        'icon': Icons.self_improvement,
        'route': AppRoutes.breathingExercise,
      },
    ];

    return SizedBox(
      height: 48,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 48,
          ),
          child: Row(
            spacing: 20,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: categories.map((cat) {
              return GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, cat['route'] as String),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: SleepColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: SleepColors.primaryLight.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        cat['icon'] as IconData,
                        color: SleepColors.primaryLight,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        cat['title'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedHorizontal(
    BuildContext context,
    String title,
    List<dynamic> items,
    String routeTarget,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, routeTarget),
                child: const Text(
                  'See all',
                  style: TextStyle(color: SleepColors.primaryLight),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final item = items[index];
              return _ContentCard(
                id: item.id,
                title: item.title,
                subtitle: item is! SleepStory
                    ? (item as SleepTrack).artist
                    : item.category,
                imagePath: item.imageUrl,
                onTap: () {
                  if (item is SleepStory) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StoryPlayerScreen(story: item),
                      ),
                    );
                  } else if (item is SleepTrack) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MusicPlayerScreen(track: item),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGridCategories(BuildContext context) {
    final grids = [
      {
        'title': 'Soundscapes',
        'subtitle': 'Mix your environment',
        'icon': Icons.waves,
        'color': const Color(0xFF4A90E2),
        'route': AppRoutes.soundscapes,
      },
      {
        'title': 'Sleep Music',
        'subtitle': 'Piano & Lo-Fi',
        'icon': Icons.piano,
        'color': const Color(0xFF9B51E0),
        'route': AppRoutes.music,
      },
      {
        'title': 'Wind Down',
        'subtitle': 'Guided breathing',
        'icon': Icons.accessibility_new,
        'color': const Color(0xFFF2994A),
        'route': AppRoutes.breathingExercise,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Browse by Category',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: grids.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final g = grids[index];
              return GlassCard(
                onTap: () => Navigator.pushNamed(context, g['route'] as String),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: (g['color'] as Color).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Icon(
                          g['icon'] as IconData,
                          color: g['color'] as Color,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            g['title'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            g['subtitle'] as String,
                            style: const TextStyle(
                              color: SleepColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: SleepColors.textMuted,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final String id;
  final String title;
  final String subtitle;
  final String imagePath;
  final VoidCallback onTap;

  const _ContentCard({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: SleepColors.surfaceLight,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: SleepColors.surfaceLight),
                ),
              ),
              Positioned.fill(
                child: Container(color: Colors.black.withValues(alpha: 0.3)),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    final isFavorite =
                        auth.profile?.favorites.contains(id) ?? false;
                    return GestureDetector(
                      onTap: () => auth.toggleFavorite(id),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: isFavorite
                              ? Colors.redAccent
                              : Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          color: SleepColors.textMuted,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            subtitle,
                            style: const TextStyle(
                              color: SleepColors
                                  .textSecondary, // Brightened from textMuted
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
