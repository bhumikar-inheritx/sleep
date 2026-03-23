import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/colors.dart';
import '../../config/constants.dart';
import '../../models/sleep_story.dart';
import '../../providers/auth_provider.dart';
import '../../providers/content_provider.dart';
import '../../widgets/common/app_background.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/mini_player.dart';
import '../../widgets/common/sleep_app_bar.dart';
import '../player/story_player_screen.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: const SleepAppBar(title: 'Sleep Stories', transparent: true),
        body: SafeArea(
          child: Stack(
            children: [
              Consumer<ContentProvider>(
                builder: (context, contentProvider, child) {
                  if (contentProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: SleepColors.primary,
                      ),
                    );
                  }

                  final stories = contentProvider.getStoriesByCategory(
                    _selectedCategory,
                  );

                  return Column(
                    children: [
                      _buildCategorySelector(),
                      const SizedBox(height: 16),
                      Expanded(child: _buildStoriesGrid(stories)),
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
            children: AppConstants.storyCategories.map((category) {
              final isSelected = category == _selectedCategory;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: AnimatedContainer(
                  duration: AppConstants.animFast,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? SleepColors.primary
                        : SleepColors.surfaceLight,
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? null
                        : Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                  ),
                  child: Center(
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : SleepColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildStoriesGrid(List<SleepStory> stories) {
    if (stories.isEmpty) {
      return Center(
        child: Text(
          'No stories found in this category.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: SleepColors.textMuted),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 16.0,
        bottom: 100.0,
      ),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75, // Taller cards
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: stories.length,
      itemBuilder: (context, index) {
        final story = stories[index];
        return _StoryCard(story: story);
      },
    );
  }
}

class _StoryCard extends StatelessWidget {
  final SleepStory story;

  const _StoryCard({required this.story});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoryPlayerScreen(story: story),
          ),
        );
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Cover Image
          Hero(
            tag: 'story_art_${story.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
              child: Image.asset(
                story.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: SleepColors.surfaceLight,
                  child: const Icon(
                    Icons.auto_stories,
                    color: SleepColors.primaryLight,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),

          // Dark gradient overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  SleepColors.background.withValues(alpha: 0.8),
                  SleepColors.background,
                ],
                stops: const [0.3, 0.7, 1.0],
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top row: New or Premium badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (story.isPremium)
                          const Icon(
                            Icons.lock_outline,
                            color: SleepColors.gold,
                            size: 16,
                          )
                        else
                          const SizedBox(),
                        if (story.isPremium && story.isNew)
                          const SizedBox(width: 4),
                        if (story.isNew)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: SleepColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        else
                          const SizedBox(),
                      ],
                    ),
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        final isFavorite =
                            auth.profile?.favorites.contains(story.id) ?? false;
                        return GestureDetector(
                          onTap: () {
                            auth.toggleFavorite(story.id);
                          },
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 20,
                            color: isFavorite
                                ? Colors.redAccent
                                : Colors.white70,
                          ),
                        );
                      },
                    ),
                  ],
                ),

                // Bottom texts
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${story.formattedDuration} • ${story.category}',
                      style: const TextStyle(
                        color: SleepColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
