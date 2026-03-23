import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/colors.dart';
import '../../config/constants.dart';
import '../../models/meditation.dart';
import '../../providers/auth_provider.dart';
import '../../providers/content_provider.dart';
import '../../widgets/common/app_background.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/mini_player.dart';
import '../../widgets/common/sleep_app_bar.dart';
import '../player/meditation_player_screen.dart';

class MeditationsScreen extends StatefulWidget {
  const MeditationsScreen({super.key});

  @override
  State<MeditationsScreen> createState() => _MeditationsScreenState();
}

class _MeditationsScreenState extends State<MeditationsScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: const SleepAppBar(title: 'Guided Meditations', transparent: true),
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

                  final meditations = contentProvider.getMeditationsByCategory(
                    _selectedCategory,
                  );

                  return Column(
                    children: [
                      _buildCategorySelector(),
                      const SizedBox(height: 16),
                      Expanded(child: _buildMeditationsGrid(meditations)),
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
            children: AppConstants.meditationCategories.map((category) {
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

  Widget _buildMeditationsGrid(List<Meditation> meditations) {
    if (meditations.isEmpty) {
      return Center(
        child: Text(
          'No meditations found in this category.',
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
        bottom: 100.0, // Space for mini player
      ),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
      ),
      itemCount: meditations.length,
      itemBuilder: (context, index) {
        return _MeditationCard(meditation: meditations[index]);
      },
    );
  }
}

class _MeditationCard extends StatelessWidget {
  final Meditation meditation;

  const _MeditationCard({required this.meditation});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MeditationPlayerScreen(meditation: meditation),
          ),
        );
      },
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppConstants.borderRadiusMedium),
                    ),
                    child: Hero(
                      tag: 'meditation_art_${meditation.id}',
                      child: Image.asset(
                        meditation.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: SleepColors.surfaceLight,
                            child: const Icon(
                              Icons.self_improvement,
                              color: SleepColors.textMuted,
                              size: 40,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  // Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
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
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top row: Favorite
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (meditation.isPremium)
                                  const Icon(
                                    Icons.lock_outline,
                                    color: SleepColors.gold,
                                    size: 16,
                                  ),
                              ],
                            ),
                            Consumer<AuthProvider>(
                              builder: (context, auth, _) {
                                final isFavorite = auth.profile?.favorites
                                        .contains(meditation.id) ??
                                    false;
                                return GestureDetector(
                                  onTap: () => auth.toggleFavorite(meditation.id),
                                  child: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
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

                        // Bottom row: Title and Duration
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meditation.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${meditation.formattedDuration} • ${meditation.instructor}',
                              style: const TextStyle(
                                color: SleepColors.textSecondary,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
